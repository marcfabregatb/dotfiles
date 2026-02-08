# -- Environment --
# Dynamically find the dotfiles directory (works even if symlinked)
export DOTFILES_DIR="${${(%):-%x}:A:h}"

# -- Homebrew (Linux) --
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# -- Plugins --
# These paths match the directories created by install.sh
[[ -f "$DOTFILES_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$DOTFILES_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# -- Tools --
# Initialize Zoxide (Smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd="z"
fi

# Initialize Oh My Posh
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config "$DOTFILES_DIR/theme.omp.json")"
fi

# -- Zsh Settings --
autoload -Uz compinit && compinit
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY # Share history between sessions

# -- .NET Settings --
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PATH="$PATH:$HOME/.dotnet/tools"