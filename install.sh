#!/bin/bash

# Get the absolute path of the dotfiles directory
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "🚀 Starting Dotfiles installation..."
echo "📂 Dotfiles directory: $DOTFILES_DIR"

# 1. Create Plugins directory
mkdir -p "$DOTFILES_DIR/plugins"

# 2. Download Plugins if missing
install_plugin() {
    local name=$1
    local url=$2
    if [ ! -d "$DOTFILES_DIR/plugins/$name" ]; then
        echo "📥 Downloading $name..."
        git clone --depth 1 "$url" "$DOTFILES_DIR/plugins/$name"
    else
        echo "✅ $name already exists."
    fi
}

install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

# 3. Symlink configuration files to Home directory
echo "🔗 Creating symlinks..."
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"

# 4. Attempt to install missing packages (Vim, Zoxide, Zsh, Curl, Git)
if command -v apt &> /dev/null && [ -f /etc/debian_version ]; then
    PACKAGES_TO_INSTALL=()
    for pkg in vim zoxide zsh curl git; do
        if ! command -v "$pkg" &> /dev/null; then
            PACKAGES_TO_INSTALL+=("$pkg")
        fi
    done

    if [ ${#PACKAGES_TO_INSTALL[@]} -ne 0 ]; then
        echo "📦 Installing missing packages: ${PACKAGES_TO_INSTALL[*]}"
        sudo apt update && sudo apt install -y "${PACKAGES_TO_INSTALL[@]}"
    else
        echo "✅ All system packages are already installed."
    fi
fi

# 5. Check for Oh My Posh
if ! command -v oh-my-posh &> /dev/null; then
    echo "⚠️ Oh My Posh is not installed. You might want to install it manually:"
    echo "https://ohmyposh.dev/docs/installation/linux"
fi

echo "✅ Done! Please restart your terminal or run 'source ~/.zshrc'"