#!/bin/bash

REPO_URL="https://github.com/marcfabregatb/dotfiles.git"
TARGET_DIR="$HOME/dotfiles"

# Bootstrap: if run via curl|bash, clone the repo first
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "bash" ]; then
    echo "📥 Cloning dotfiles..."
    command -v git &> /dev/null || { sudo apt update && sudo apt install -y git; }
    git clone "$REPO_URL" "$TARGET_DIR" 2>/dev/null || git -C "$TARGET_DIR" pull
    exec bash "$TARGET_DIR/install.sh"
fi

# Get the absolute path of the dotfiles directory
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Check if running in a Dev Container
IN_CONTAINER=false
if [ -f /.dockerenv ] || [ -n "$REMOTE_CONTAINERS" ]; then
    IN_CONTAINER=true
fi

echo "🚀 Starting Dotfiles installation (Debian/Ubuntu)..."
[ "$IN_CONTAINER" = true ] && echo "🐳 Detected Dev Container environment"

# 1. Clean up old plugins/caches from previous installs
ACTIVE_PLUGINS=("zsh-autosuggestions" "zsh-syntax-highlighting")

if [ -d "$DOTFILES_DIR/plugins" ]; then
    for dir in "$DOTFILES_DIR/plugins"/*/; do
        plugin_name=$(basename "$dir")
        found=false
        for active in "${ACTIVE_PLUGINS[@]}"; do
            [ "$plugin_name" = "$active" ] && found=true
        done
        if [ "$found" = false ]; then
            echo "🧹 Removing old plugin: $plugin_name"
            rm -rf "$dir"
        fi
    done
fi

rm -f "$HOME"/.zcompdump*

mkdir -p "$DOTFILES_DIR/plugins"

# 2. Download Plugins
install_plugin() {
    local name=$1
    local url=$2
    local target="$DOTFILES_DIR/plugins/$name"
    if [ ! -d "$target" ] || [ -z "$(ls -A "$target")" ]; then
        rm -rf "$target"
        echo "📥 Downloading $name..."
        git clone --depth 1 "$url" "$target"
    fi
}

install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

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

# 7. Install Atuin (visual shell history with Up arrow navigation)
if ! command -v atuin &> /dev/null; then
    echo "📥 Installing Atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    # Source the env so atuin is available for the rest of the script
    [ -f "$HOME/.atuin/bin/env" ] && source "$HOME/.atuin/bin/env"
fi

# 8. Install Docker (Only if NOT in a container)
if [ "$IN_CONTAINER" = false ] && ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    sudo usermod -aG docker "$USER"
fi

# 9. Install Claude Code CLI
if ! command -v claude &> /dev/null; then
    echo "🤖 Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

echo "✅ Done! Please restart your terminal or run 'source ~/.zshrc'"

# 10. Check current shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "⚠️  Warning: Your default shell is currently $SHELL, not zsh."
    echo "👉 To change it to zsh, run: chsh -s \$(which zsh)"
    echo "👉 Or, if in a Dev Container, ensure 'terminal.integrated.defaultProfile.linux' is set to 'zsh' in your settings.json."
fi
