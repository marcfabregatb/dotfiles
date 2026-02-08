#!/bin/bash

# Get the absolute path of the dotfiles directory
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Check if running in a Dev Container
IN_CONTAINER=false
if [ -f /.dockerenv ] || [ -n "$REMOTE_CONTAINERS" ]; then
    IN_CONTAINER=true
fi

echo "🚀 Starting Dotfiles installation (Debian/Ubuntu)..."
[ "$IN_CONTAINER" = true ] && echo "🐳 Detected Dev Container environment"

# 1. Create Plugins directory
mkdir -p "$DOTFILES_DIR/plugins"

# 2. Download Plugins
install_plugin() {
    local name=$1
    local url=$2
    if [ ! -d "$DOTFILES_DIR/plugins/$name" ]; then
        echo "📥 Downloading $name..."
        git clone --depth 1 "$url" "$DOTFILES_DIR/plugins/$name"
    fi
}

install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
install_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search"

# 3. Symlink configuration
echo "🔗 Creating symlinks..."
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"

# 4. Install Core Packages (Skip in container if already present)
if [ "$IN_CONTAINER" = false ]; then
    echo "📦 Installing system packages..."
    sudo apt update
    sudo apt install -y vim zoxide zsh curl git build-essential
fi

# 5. Install Homebrew for Linux (Only if Oh My Posh is missing)
if ! command -v oh-my-posh &> /dev/null && ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew for Linux..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# 6. Install Oh My Posh (if missing)
if ! command -v oh-my-posh &> /dev/null; then
    if command -v brew &> /dev/null; then
        brew install oh-my-posh
    else
        echo "📥 Installing Oh My Posh via direct binary..."
        sudo curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
fi

# 7. Install Docker (Only if NOT in a container)
if [ "$IN_CONTAINER" = false ] && ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    sudo usermod -aG docker "$USER"
fi

echo "✅ Done! Please restart your terminal or run 'source ~/.zshrc'"
