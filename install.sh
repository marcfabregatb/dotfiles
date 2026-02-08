#!/bin/bash

# Get the absolute path of the dotfiles directory
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "🚀 Starting Dotfiles installation..."
echo "📂 Dotfiles directory: $DOTFILES_DIR"

# 1. Create Plugins directory and ensure permissions
mkdir -p "$DOTFILES_DIR/plugins"
chmod -R 755 "$DOTFILES_DIR/plugins"

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

# 4. Install Core Packages via apt
echo "📦 Updating system and installing core packages..."
sudo apt update
sudo apt install -y vim zoxide zsh curl git build-essential

# 5. Install Homebrew (needed for Oh My Posh and other tools)
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew for Linux..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    echo "✅ Homebrew is already installed."
fi

# 6. Install Oh My Posh via brew
if ! command -v oh-my-posh &> /dev/null; then
    echo "✨ Installing Oh My Posh..."
    brew install oh-my-posh
else
    echo "✅ Oh My Posh is already installed."
fi

# 7. Install Docker and Docker Compose
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    sudo usermod -aG docker "$USER"
    echo "👤 Added $USER to docker group. Please re-login or run 'newgrp docker'."
else
    echo "✅ Docker is already installed: $(docker --version)"
fi

# Ensure Docker Compose plugin is installed
if ! docker compose version &> /dev/null; then
    echo "📥 Installing Docker Compose plugin..."
    sudo apt-get update && sudo apt-get install -y docker-compose-plugin
fi

echo "✅ Done! Please restart your terminal or run 'source ~/.zshrc'"