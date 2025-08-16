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

get_debian_version() {
    if [[ -f /etc/debian_version ]]; then
        local version
        version="$(cat /etc/debian_version | cut -d. -f1)"
        # Handle cases like "trixie/sid" or "13.0"
        if [[ "$version" =~ ^[0-9]+$ ]]; then
            echo "$version"
        elif [[ "$version" == "trixie"* ]]; then
            echo "13"
        elif [[ "$version" == "bookworm"* ]]; then
            echo "12"
        else
            # Try to get version from /etc/os-release as fallback
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
        x86_64) asset="nvim-linux-x86_64.tar.gz" ;;   # <-- updated name
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

install_yazi() {
    say "Installing Yazi ${YAZI_VERSION} ..."
    ensure_dirs

    local arch triple asset url tmp dest_dir root_dir
    arch="$(uname -m)"
    case "$arch" in
        x86_64) triple="x86_64-unknown-linux-gnu" ;;
        aarch64|arm64) triple="aarch64-unknown-linux-gnu" ;;
        *) die "Unsupported arch for Yazi: $arch" ;;
    esac

    asset="yazi-${triple}.zip"
    # use sxyazi/yazi (official releases)
    url="https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/${asset}"
    tmp="$(mktemp -d)"
    curl -fL --retry 3 --retry-delay 2 "$url" -o "$tmp/yazi.zip"
    unzip -q "$tmp/yazi.zip" -d "$tmp/extract"

    root_dir="$(find "$tmp/extract" -maxdepth 2 -type d -name "yazi-${triple}" | head -n1)"
    [[ -n "$root_dir" ]] || die "Failed to locate extracted Yazi folder."

    dest_dir="${OPT_DIR}/yazi"
    rm -rf "$dest_dir"
    mv "$root_dir" "$dest_dir"

    ln -sfn "${dest_dir}/yazi" "${BIN_DIR}/yazi"
    ln -sfn "${dest_dir}/ya"   "${BIN_DIR}/ya"

    rm -rf "$tmp"
    say "Yazi ${YAZI_VERSION} installed; symlinked ${BIN_DIR}/yazi and ${BIN_DIR}/ya"
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

        # The eza binary should be directly in the archive
        if [[ -f "$tmp/eza" ]]; then
            cp "$tmp/eza" "${BIN_DIR}/eza"
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
