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
NEOVIM_VERSION="v0.11.3"
YAZI_VERSION="v25.5.31"
EZA_VERSION="v0.23.0"

APT_PACKAGES=(
    git curl wget ca-certificates
    zsh tmux stow fzf
    unzip xz-utils tar
    gcc fortune
    build-essential
)

INSTALL_PREFIX="/usr/local"
BIN_DIR="${INSTALL_PREFIX}/bin"
OPT_DIR="${INSTALL_PREFIX}/opt"

### ──────────────────────────────
### HELPERS
### ──────────────────────────────
say()  { printf "\n\033[1;36m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*" >&2; }
die()  { printf "\n\033[1;31m[err]\033[0m %s\n" "$*" >&2; exit 1; }

need_root() {
    if [[ $(id -u) -ne 0 ]]; then
        die "Please run with sudo/root (e.g., sudo $0)"
    fi
}

get_debian_version() {
    if [[ -f /etc/debian_version ]]; then
        local version
        version="$(cut -d. -f1 < /etc/debian_version)"
        if [[ "$version" =~ ^[0-9]+$ ]]; then
            echo "$version"
        elif [[ "$version" == "trixie"* ]]; then
            echo "13"
        elif [[ "$version" == "bookworm"* ]]; then
            echo "12"
        else
            if [[ -f /etc/os-release ]]; then
                local version_id
                version_id="$(grep '^VERSION_ID=' /etc/os-release | cut -d'"' -f2 | cut -d. -f1)"
                echo "${version_id:-unknown}"
            else
                echo "unknown"
            fi
        fi
    else
        echo "unknown"
    fi
}

get_glibc_version() {
    local v
    v="$(ldd --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' | tail -n1 || true)"
    echo "${v:-0}"
}

ensure_apt_packages() {
    need_root
    say "Refreshing apt and installing packages..."
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}"
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

install_neovim() {
    say "Installing Neovim ${NEOVIM_VERSION} ..."
    ensure_dirs

    local arch asset url tmp tar_dir dest_dir
    arch="$(uname -m)"
    case "$arch" in
        x86_64) asset="nvim-linux-x86_64.tar.gz" ;;
        aarch64|arm64) asset="nvim-linux-arm64.tar.gz" ;;
        *) die "Unsupported arch for Neovim: $arch" ;;
    esac

    url="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/${asset}"
    tmp="$(mktemp -d)"
    curl -fL --retry 3 --retry-delay 2 "$url" -o "$tmp/nvim.tar.gz"

    tar -C "$tmp" -xzf "$tmp/nvim.tar.gz"
    tar_dir="$(find "$tmp" -maxdepth 1 -type d -name 'nvim-*' | head -n1)"
    [[ -d "$tar_dir" ]] || die "Failed to extract Neovim."

    dest_dir="${OPT_DIR}/neovim"
    rm -rf "$dest_dir"
    mv "$tar_dir" "$dest_dir"
    ln -sfn "${dest_dir}/bin/nvim" "${BIN_DIR}/nvim"

    rm -rf "$tmp"
    say "Neovim ${NEOVIM_VERSION} installed; symlinked ${BIN_DIR}/nvim"
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

    # Verify it actually runs (catches GLIBC mismatches).
    if ! "${BIN_DIR}/yazi" --version >/dev/null 2>&1; then
        rm -f "${BIN_DIR}/yazi" "${BIN_DIR}/ya"
        rm -rf "$dest_dir" "$tmp"
        return 1
    fi

    rm -rf "$tmp"
    say "Yazi ${YAZI_VERSION} installed from prebuilt (${triple})."
    return 0
}

install_yazi() {
    say "Installing Yazi ${YAZI_VERSION} ..."
    ensure_dirs

    local arch triple_gnu triple_musl glibc_ver tried triples_tried
    arch="$(uname -m)"
    case "$arch" in
        x86_64)
            triple_gnu="x86_64-unknown-linux-gnu"
            triple_musl="x86_64-unknown-linux-musl"
            ;;
        aarch64|arm64)
            triple_gnu="aarch64-unknown-linux-gnu"
            triple_musl="aarch64-unknown-linux-musl"
            ;;
        *)
            warn "Unsupported arch for Yazi: $arch — skipping Yazi."
            return 0
            ;;
    esac

    glibc_ver="$(get_glibc_version)"
    say "Detected glibc ${glibc_ver}"

    tried=0
    triples_tried=()

    # Prefer GNU if glibc >= 2.39; otherwise MUSL.
    if dpkg --compare-versions "$glibc_ver" ge "2.39"; then
        triples_tried+=("$triple_gnu")
        if try_install_yazi_release "$triple_gnu"; then
            return 0
        fi
        tried=1
        triples_tried+=("$triple_musl")
        if try_install_yazi_release "$triple_musl"; then
            return 0
        fi
    else
        triples_tried+=("$triple_musl")
        if try_install_yazi_release "$triple_musl"; then
            return 0
        fi
        tried=1
        triples_tried+=("$triple_gnu")
        if try_install_yazi_release "$triple_gnu"; then
            return 0
        fi
    fi

    warn "Unable to install a prebuilt Yazi binary (tried: ${triples_tried[*]}). Skipping Yazi installation."
    return 0
}

install_eza() {
    local debian_version
    debian_version="$(get_debian_version)"

    if [[ "$debian_version" -ge 13 ]] 2>/dev/null; then
        say "Installing eza from apt (Debian $debian_version) ..."
        need_root
        DEBIAN_FRONTEND=noninteractive apt-get install -y eza
        say "eza installed via apt"
    else
        say "Installing eza ${EZA_VERSION} from GitHub releases (Debian $debian_version) ..."
        ensure_dirs

        local arch asset url tmp
        arch="$(uname -m)"
        case "$arch" in
            x86_64) asset="eza_x86_64-unknown-linux-gnu.tar.gz" ;;
            aarch64|arm64) asset="eza_aarch64-unknown-linux-gnu.tar.gz" ;;
            *) die "Unsupported arch for eza: $arch" ;;
        esac

        url="https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/${asset}"
        tmp="$(mktemp -d)"
        curl -fL --retry 3 --retry-delay 2 "$url" -o "$tmp/eza.tar.gz"

        tar -C "$tmp" -xzf "$tmp/eza.tar.gz"

        if [[ -f "$tmp/eza" ]]; then
            cp "$tmp/eza" "${BIN_DIR}/eza"
            chmod +x "${BIN_DIR}/eza"
        elif [[ -f "$tmp/bin/eza" ]]; then
            cp "$tmp/bin/eza" "${BIN_DIR}/eza"
            chmod +x "${BIN_DIR}/eza"
        else
            die "Failed to find eza binary in extracted archive."
        fi

        rm -rf "$tmp"
        say "eza ${EZA_VERSION} installed to ${BIN_DIR}/eza"
    fi
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
    ensure_apt_packages

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
