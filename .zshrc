# -- Environment --
zmodload zsh/terminfo
# Dynamically find the dotfiles directory (works even if symlinked)
export DOTFILES_DIR="${${(%):-%x}:A:h}"

# -- Homebrew (Linux) --
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# -- Plugins --
# These paths match the directories created by install.sh
# 1. Autosuggestions
[[ -f "$DOTFILES_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# 2. History Substring Search (Should be before autocomplete/syntax-highlighting)
[[ -f "$DOTFILES_DIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

# 3. Autocomplete (Should be after autosuggestions/history-search and before syntax-highlighting)
[[ -f "$DOTFILES_DIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# 4. Syntax Highlighting (Must be last)
[[ -f "$DOTFILES_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# -- Tools --
# Initialize fzf (Fuzzy Finder)
if command -v fzf &> /dev/null; then
    # Debian/Ubuntu standard paths
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
    # Homebrew paths (if applicable)
    if command -v brew &> /dev/null; then
        [[ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ]] && source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
        [[ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
    fi
fi

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
# Disable internal recent-dirs to prevent recursion with zoxide
zstyle ':autocomplete:*' recent-dirs off

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

# -- Key Bindings --
# Use history substring search
if [[ -f "$DOTFILES_DIR/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
fi

# -- .NET Settings --
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PATH="$PATH:$HOME/.dotnet/tools"