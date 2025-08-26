#!/usr/bin/env bash
set -euo pipefail

### ──────────────────────────────
### CONFIG — EDIT THESE
### ──────────────────────────────
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

DOTFILES_REPO="https://github.com/marcosalvi-01/dotfiles.git"
DOTFILES_DIR="${REAL_HOME}/dotfiles"

# Pin exact versions (include the "v" prefix used by releases)
NEOVIM_VERSION="v0.11.3"      # kept for reference; Alpine installs via apk
YAZI_VERSION="v25.5.31"
EZA_VERSION="v0.23.0"         # used only if apk eza is unavailable

APK_PACKAGES=(
    git curl wget ca-certificates
    zsh tmux stow fzf
    unzip xz tar
    build-base           # toolchain; harmless
    shadow               # provides chsh/usermod
    pkgconf              # pkg-config equivalent
    sudo                 # for 'sudo -u'
    neovim               # prefer repo nvim on Alpine
    eza                  # prefer repo eza on Alpine (fallback to GitHub if missing)
)

INSTALL_PREFIX="/usr/local"
BIN_DIR="${INSTALL_PREFIX}/bin"
OPT_DIR="${INSTALL_PREFIX}/opt"

### ──────────────────────────────
### HELPERS
### ──────────────────────────────
say()  { printf "\n\033[1;36m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*" >&2; }
die()  { printf "\033[1;31m[err]\033[0m %s\n" "$*" >&2; exit 1; }

need_root() {
    if [[ $(id -u) -ne 0 ]]; then
        die "Please run with sudo/root (e.g., sudo $0)"
    fi
}

ensure_apk_packages() {
    need_root
    say "Refreshing apk index and installing packages..."
    apk update
    apk add --no-cache "${APK_PACKAGES[@]}"
    # optional goodies that might not exist in all Alpine variants
    apk add --no-cache fortune-mod || warn "fortune-mod not available — skipping"
}

clone_or_update_repo() {
    local repo_url="$1" dest="$2"
    if [[ -d "$dest/.git" ]]; then
        say "Dotfiles repo exists, pulling latest..."
        sudo -u "$REAL_USER" git -C "$dest" pull --ff-only
    else
        say "Cloning dotfiles to $dest ..."
        rm -rf "$dest"
        sudo -u "$REAL_USER" git clone --depth=1 "$repo_url" "$dest"
    fi
}

change_default_shell_to_zsh() {
    local zsh_path
    zsh_path="$(command -v zsh || true)"
    [[ -x "$zsh_path" ]] || die "zsh not found in PATH after install."
    if [[ "$(getent passwd "$REAL_USER" | cut -d: -f7)" == "$zsh_path" ]]; then
        say "Default shell already set to zsh for $REAL_USER"
        return
    fi
    say "Changing default shell to zsh for $REAL_USER ..."
    chsh -s "$zsh_path" "$REAL_USER" || warn "chsh may require relogin to take effect."
}

ensure_dirs() {
    need_root
    mkdir -p "$BIN_DIR" "$OPT_DIR"
}

# On Alpine we prefer the repo neovim; symlink to /usr/local/bin for consistency
install_neovim() {
    say "Ensuring Neovim is installed via apk ..."
    if ! command -v nvim >/dev/null 2>&1; then
        die "neovim should have been installed by apk earlier but isn't. Check your repositories."
    fi
    ensure_dirs
    ln -sfn "/usr/bin/nvim" "${BIN_DIR}/nvim"
    say "Neovim installed; symlinked ${BIN_DIR}/nvim -> /usr/bin/nvim"
}

# Try to install a Yazi prebuilt archive for the given target triple.
# Returns 0 on success; 1 on failure (without aborting the whole script).
try_install_yazi_release() {
    local triple="$1"
    local asset="yazi-${triple}.zip"
    local url="https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/${asset}"
    local tmp root_dir dest_dir

    tmp="$(mktemp -d)"
    if ! curl -fL --retry 3 --retry-delay 2 "$url" -o "$tmp/yazi.zip"; then
        rm -rf "$tmp"
        return 1
    fi
    if ! unzip -q "$tmp/yazi.zip" -d "$tmp/extract"; then
        rm -rf "$tmp"
        return 1
    fi

    root_dir="$(find "$tmp/extract" -maxdepth 2 -type d -name "yazi-${triple}" | head -n1 || true)"
    if [[ -z "$root_dir" ]]; then
        rm -rf "$tmp"
        return 1
    fi

    dest_dir="${OPT_DIR}/yazi"
    rm -rf "$dest_dir"
    mv "$root_dir" "$dest_dir"

    ln -sfn "${dest_dir}/yazi" "${BIN_DIR}/yazi"
    ln -sfn "${dest_dir}/ya"   "${BIN_DIR}/ya"

    if ! "${BIN_DIR}/yazi" --version >/dev/null 2>&1; then
        rm -f "${BIN_DIR}/yazi" "${BIN_DIR}/ya"
        rm -rf "$dest_dir" "$tmp"
        return 1
    fi

    rm -rf "$tmp"
    say "Yazi ${YAZI_VERSION} installed from prebuilt (${triple})."
    return 0
}

# Alpine is musl-based. Prefer apk repo; fall back to musl prebuilt. No source builds.
install_yazi() {
    say "Installing Yazi on Alpine ..."
    ensure_dirs

    # 1) Prefer the official Alpine package
    if apk add --no-cache yazi >/dev/null 2>&1; then
        ln -sfn "/usr/bin/yazi" "${BIN_DIR}/yazi"
        if [[ -x "/usr/bin/ya" ]]; then
            ln -sfn "/usr/bin/ya" "${BIN_DIR}/ya"
        else
            warn "'ya' helper not found in package — continuing with 'yazi' only."
        fi
        if ! "${BIN_DIR}/yazi" --version >/dev/null 2>&1; then
            warn "Installed Yazi from apk but it failed to run."
        else
            say "Yazi installed via apk; symlinked to ${BIN_DIR}."
            return 0
        fi
    else
        warn "apk yazi not available (maybe enable community repo). Trying prebuilt musl ${YAZI_VERSION} ..."
    fi

    # 2) Fallback: official release musl prebuilt
    local arch triple_musl
    arch="$(uname -m)"
    case "$arch" in
        x86_64)        triple_musl="x86_64-unknown-linux-musl" ;;
        aarch64|arm64) triple_musl="aarch64-unknown-linux-musl" ;;
        *)
            warn "Unsupported arch for Yazi on Alpine: $arch — skipping Yazi."
            return 0
            ;;
    esac

    if try_install_yazi_release "$triple_musl"; then
        return 0
    fi

    warn "Unable to install Yazi (apk and musl prebuilt both unavailable/failed). Skipping Yazi installation."
    return 0
}

install_eza() {
    ensure_dirs
    say "Installing eza on Alpine ..."
    if command -v eza >/dev/null 2>&1 || apk add --no-cache eza >/dev/null 2>&1; then
        ln -sfn "/usr/bin/eza" "${BIN_DIR}/eza"
        say "eza available via apk; symlinked ${BIN_DIR}/eza -> /usr/bin/eza"
        return 0
    fi

    # Fallback to GitHub release (musl build)
    warn "apk eza not available; falling back to GitHub release ${EZA_VERSION} (musl)."
    local arch asset url tmp
    arch="$(uname -m)"
    case "$arch" in
        x86_64)        asset="eza_x86_64-unknown-linux-musl.tar.gz" ;;
        aarch64|arm64) asset="eza_aarch64-unknown-linux-musl.tar.gz" ;;
        *)
            warn "Unsupported arch for eza: $arch — skipping eza."
            return 0
            ;;
    esac

    url="https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/${asset}"
    tmp="$(mktemp -d)"
    if ! curl -fL --retry 3 --retry-delay 2 "$url" -o "$tmp/eza.tar.gz"; then
        rm -rf "$tmp"
        warn "Failed to download eza musl prebuilt — skipping."
        return 0
    fi

    if ! tar -C "$tmp" -xzf "$tmp/eza.tar.gz"; then
        rm -rf "$tmp"
        warn "Failed to extract eza archive — skipping."
        return 0
    fi

    if [[ -f "$tmp/eza" ]]; then
        cp "$tmp/eza" "${BIN_DIR}/eza"
    elif [[ -f "$tmp/bin/eza" ]]; then
        cp "$tmp/bin/eza" "${BIN_DIR}/eza"
    else
        rm -rf "$tmp"
        warn "Could not find eza binary in release archive — skipping."
        return 0
    fi

    chmod +x "${BIN_DIR}/eza"
    rm -rf "$tmp"
    say "eza ${EZA_VERSION} installed to ${BIN_DIR}/eza"
}

install_tpm() {
    say "Cloning Tmux Plugin Manager (TPM) ..."
    sudo -u "$REAL_USER" mkdir -p "${REAL_HOME}/.tmux/plugins"
    sudo -u "$REAL_USER" git clone --depth=1 https://github.com/tmux-plugins/tpm \
        "${REAL_HOME}/.tmux/plugins/tpm" || warn "TPM already exists — skipping clone"
}

### ──────────────────────────────
### MAIN
### ──────────────────────────────
main() {
    ensure_apk_packages

    clone_or_update_repo "$DOTFILES_REPO" "$DOTFILES_DIR"

    say "Stowing dotfiles..."
    pushd "$DOTFILES_DIR" >/dev/null
    sudo -u "$REAL_USER" stow -v -R --target "$REAL_HOME" .
    popd >/dev/null

    install_tpm
    change_default_shell_to_zsh
    install_neovim
    install_yazi
    install_eza

    say "Done! Start tmux and press prefix+I to install plugins."
}

main "$@"
