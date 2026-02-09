# -- Environment --
# Dynamically find the dotfiles directory (works even if symlinked)
export DOTFILES_DIR="${${(%):-%x}:A:h}"

# -- Homebrew (Linux) --
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# -- Plugins --
# These paths match the directories created by install.sh
[[ -f "$DOTFILES_DIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
[[ -f "$DOTFILES_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$DOTFILES_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# -- Tools --
# Initialize Zoxide (Smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd="z"
fi

# Initialize Oh My Posh with our specific theme
if command -v oh-my-posh &> /dev/null; then
    # Clear any previous theme set by devcontainer features
    unset POSH_THEME
    eval "$(oh-my-posh init zsh --config "$DOTFILES_DIR/theme.omp.json")"
fi

# -- Zsh Settings --
# autoload -Uz compinit && compinit # Managed by zsh-autocomplete
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # Case-insensitive completion
zstyle ':completion:*' menu select                 # Visual menu for completion
setopt AUTO_LIST                                  # Automatically list choices on ambiguous completion
setopt AUTO_MENU                                  # Show menu after second tab press

# -- zsh-autocomplete Configuration --
# Start with history search (like PSReadLine PredictionSource History)
zstyle ':autocomplete:*' default-context history-incremental-search-backward

# Only show the list after typing at least 1 character
zstyle ':autocomplete:*' min-input 1

# Limit list to 50% of screen height, and hide it if the buffer is empty
zstyle -e ':autocomplete:*:*' list-lines '[[ -n $BUFFER ]] && reply=( $(( LINES / 2 )) ) || reply=( 0 )'

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY # Share history between sessions
setopt HIST_IGNORE_ALL_DUPS # Do not record a line that has been recorded before
setopt HIST_FIND_NO_DUPS    # Do not display a line previously found

# -- .NET Settings --
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PATH="$PATH:$HOME/.dotnet/tools"