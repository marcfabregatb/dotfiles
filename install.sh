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

# 4. Install Core Packages (Install if missing, even in container)
install_packages() {
    local pkgs=()
    for pkg in "$@"; do
        if ! command -v "$pkg" &> /dev/null; then
            pkgs+=("$pkg")
        fi
    done

    if [ ${#pkgs[@]} -gt 0 ]; then
        echo "📦 Installing missing packages: ${pkgs[*]}..."
        if [ "$IN_CONTAINER" = true ]; then
            sudo apt update && sudo apt install -y "${pkgs[@]}"
        else
            sudo apt update && sudo apt install -y "${pkgs[@]}"
        fi
    else
        echo "✅ All core packages (vim, zoxide, zsh, fzf) are already installed."
    fi
}

install_packages vim zoxide zsh curl git build-essential fzf

# 5. Install Homebrew for Linux (If missing and not in container)
# We usually avoid brew in devcontainers to keep them slim, but let's be flexible
if ! command -v brew &> /dev/null && [ "$IN_CONTAINER" = false ]; then
    echo "🍺 Installing Homebrew for Linux..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# 6. Install Oh My Posh (if missing)
if ! command -v oh-my-posh &> /dev/null; then
    if command -v brew &> /dev/null; then
        echo "📥 Installing Oh My Posh via brew..."
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

# 8. Check current shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "⚠️  Warning: Your default shell is currently $SHELL, not zsh."
    echo "👉 To change it to zsh, run: chsh -s \$(which zsh)"
    echo "👉 Or, if in a Dev Container, ensure 'terminal.integrated.defaultProfile.linux' is set to 'zsh' in your settings.json."
fi
