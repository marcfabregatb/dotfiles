#!/bin/bash

REPO_URL="https://github.com/marcfabregatb/dotfiles.git"
TARGET_DIR="$HOME/dotfiles"

# Bootstrap: if run via curl|bash, clone the repo first
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "bash" ] || [[ "${BASH_SOURCE[0]}" == /dev/* ]] || [[ "${BASH_SOURCE[0]}" == /proc/* ]]; then
    echo "Cloning dotfiles..."
    command -v git &> /dev/null || { sudo apt-get update && sudo apt-get install -y git; }
    git clone "$REPO_URL" "$TARGET_DIR" 2>/dev/null || git -C "$TARGET_DIR" pull
    exec bash "$TARGET_DIR/install.sh"
fi

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "Starting dotfiles installation..."

rm -f "$HOME"/.zcompdump*

# Plugins now come from apt; remove clones left by older installs
rm -rf "$DOTFILES_DIR/plugins"

# -- Install apt packages (only missing ones) --
apt_packages=(zsh curl git unzip zsh-autosuggestions zsh-syntax-highlighting)
missing=()
for pkg in "${apt_packages[@]}"; do
    dpkg -s "$pkg" &> /dev/null || missing+=("$pkg")
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing[*]}..."
    sudo apt-get update && sudo apt-get install -y "${missing[@]}"
fi

# -- Symlink config files --
echo "Creating symlinks..."
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

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

echo "Done! Run 'zsh' to start your new shell or restart your terminal."
