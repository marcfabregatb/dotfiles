#!/bin/bash

REPO_URL="${DOTFILES_REPO:-https://github.com/marcfabregatb/dotfiles.git}"
# Branch or tag to install; set DOTFILES_REF to pin a server to a specific tag
REF="${DOTFILES_REF:-main}"
TARGET_DIR="$HOME/dotfiles"

# Run privileged commands directly when already root (minimal VMs often have no sudo)
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    command -v sudo &> /dev/null || { echo "Error: not root and sudo is not installed." >&2; exit 1; }
    SUDO="sudo"
fi

# Bootstrap: if run via curl|bash, clone the repo first
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "bash" ] || [[ "${BASH_SOURCE[0]}" == /dev/* ]] || [[ "${BASH_SOURCE[0]}" == /proc/* ]]; then
    echo "Fetching dotfiles ($REF)..."
    command -v git &> /dev/null || { $SUDO apt-get update && $SUDO apt-get install -y git; } || exit 1
    if [ -d "$TARGET_DIR/.git" ]; then
        git -C "$TARGET_DIR" fetch -q --tags origin || exit 1
        if git -C "$TARGET_DIR" show-ref -q --verify "refs/remotes/origin/$REF"; then
            # REF is a branch: move to it and fast-forward
            git -C "$TARGET_DIR" checkout -q "$REF" && git -C "$TARGET_DIR" merge -q --ff-only "origin/$REF" || exit 1
        else
            git -C "$TARGET_DIR" checkout -q "$REF" || exit 1
        fi
    else
        git clone -q --branch "$REF" "$REPO_URL" "$TARGET_DIR" || exit 1
    fi
    exec bash "$TARGET_DIR/install.sh"
fi

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "Starting dotfiles installation..."

rm -f "$HOME"/.zcompdump*

# Plugins now come from apt; remove clones left by older installs
rm -rf "$DOTFILES_DIR/plugins"

# -- Install apt packages (only missing ones) --
apt_packages=(zsh curl git zsh-autosuggestions zsh-syntax-highlighting bat)
missing=()
for pkg in "${apt_packages[@]}"; do
    # dpkg -s also succeeds for removed packages whose config remains ("rc"), so check the status
    dpkg-query -W -f='${Status}' "$pkg" 2> /dev/null | grep -q "ok installed" || missing+=("$pkg")
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing[*]}..."
    $SUDO apt-get update && $SUDO apt-get install -y "${missing[@]}" || {
        echo "Error: package installation failed; leaving config files untouched." >&2
        exit 1
    }
fi

# -- Symlink config files --
# link_file <repo path> <destination>: symlink, first backing up anything at the
# destination that isn't already our symlink (backup names never overwrite each other)
link_file() {
    local src="$DOTFILES_DIR/$1" dest="$2" base backup n=1
    mkdir -p "$(dirname "$dest")" || exit 1
    if { [ -e "$dest" ] || [ -L "$dest" ]; } && [ "$(readlink "$dest")" != "$src" ]; then
        base="$dest.bak.$(date +%Y%m%d-%H%M%S)"
        backup="$base"
        while [ -e "$backup" ] || [ -L "$backup" ]; do backup="$base.$n"; n=$((n + 1)); done
        mv -n "$dest" "$backup" && [ ! -e "$dest" ] && [ ! -L "$dest" ] || {
            echo "Error: could not back up $dest." >&2; exit 1;
        }
        echo "Backed up existing $dest to $backup"
    fi
    ln -sfn "$src" "$dest" || exit 1
}

echo "Creating symlinks..."
link_file .zshrc "$HOME/.zshrc"
link_file .nanorc "$HOME/.nanorc"
link_file bat/config "${XDG_CONFIG_HOME:-$HOME/.config}/bat/config"

# -- Set zsh as default shell --
# Read the real login shell from passwd ($SHELL is inherited and unreliable after su/sudo),
# and compare resolved paths so /bin/zsh and /usr/bin/zsh count as the same on usrmerge systems
user="$(id -un)"
zsh_path="$(command -v zsh)"
login_shell="$(getent passwd "$user" | cut -d: -f7)"
if [ "$(id -u)" -eq 0 ]; then
    echo "Running as root: leaving root's login shell unchanged (run 'zsh' to use it)."
elif [ "$(readlink -f "$login_shell")" != "$(readlink -f "$zsh_path")" ]; then
    echo "Setting zsh as default shell..."
    $SUDO chsh -s "$zsh_path" "$user"
fi

echo "Done! Run 'zsh' to start your new shell or restart your terminal."
