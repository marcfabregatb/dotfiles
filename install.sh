#!/bin/bash

REPO_URL="https://github.com/marcfabregatb/dotfiles-lite.git"
TARGET_DIR="$HOME/dotfiles-lite"

# Bootstrap: if run via curl|bash, clone the repo first
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "bash" ] || [[ "${BASH_SOURCE[0]}" == /dev/* ]] || [[ "${BASH_SOURCE[0]}" == /proc/* ]]; then
    echo "Cloning dotfiles-lite..."
    command -v git &> /dev/null || { sudo apt-get update && sudo apt-get install -y git; }
    git clone "$REPO_URL" "$TARGET_DIR" 2>/dev/null || git -C "$TARGET_DIR" pull
    exec bash "$TARGET_DIR/install.sh"
fi

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "Starting dotfiles-lite installation..."

rm -f "$HOME"/.zcompdump*
mkdir -p "$DOTFILES_DIR/plugins"

# -- Install apt packages (only missing ones) --
apt_packages=(zsh curl git)
missing=()
for pkg in "${apt_packages[@]}"; do
    command -v "$pkg" &> /dev/null || missing+=("$pkg")
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing[*]}..."
    sudo apt-get update && sudo apt-get install -y "${missing[@]}"
fi

# -- Symlink config files --
echo "Creating symlinks..."
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# -- Clone zsh plugins --
install_plugin() {
    local name=$1 url=$2
    local target="$DOTFILES_DIR/plugins/$name"
    if [ ! -d "$target" ] || [ -z "$(ls -A "$target" 2>/dev/null)" ]; then
        rm -rf "$target"
        echo "Downloading $name..."
        git clone --depth 1 "$url" "$target"
    fi
}

install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

# -- Install Oh My Posh (direct binary, no Homebrew needed) --
if ! command -v oh-my-posh &> /dev/null; then
    echo "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/local/bin
    oh-my-posh font install CaskaydiaCove
fi

# -- Set zsh as default shell --
if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "Setting zsh as default shell..."
    sudo chsh -s "$(command -v zsh)" "$(whoami)"
fi

echo "Done! Restart your terminal or run: source ~/.zshrc"
