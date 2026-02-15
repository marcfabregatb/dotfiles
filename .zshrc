# -- Environment --
zmodload zsh/terminfo
# Dynamically find the dotfiles directory (works even if symlinked)
export DOTFILES_DIR="${${(%):-%x}:A:h}"
export PATH="$HOME/.local/bin:$PATH"

# -- Homebrew (Linux) --
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# -- Atuin env (adds ~/.atuin/bin to PATH) --
[[ -f "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"

# -- Plugins --
# 1. Autosuggestions (fish-like ghost text from history, accept with Right Arrow)
[[ -f "$DOTFILES_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# 2. Syntax Highlighting (colors commands as you type; must be loaded last)
[[ -f "$DOTFILES_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$DOTFILES_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# -- Tools --
# fzf (Fuzzy Finder: Ctrl+T for files, Alt+C for cd, completion with **)
if command -v fzf &> /dev/null; then
    [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
    if command -v brew &> /dev/null; then
        [[ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
    fi
fi

# Atuin (visual history search: Up arrow to browse, Ctrl+R to search)
if command -v atuin &> /dev/null; then
    eval "$(atuin init zsh)"
fi

# Zoxide (smart cd replacement)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd="z"
fi

# Oh My Posh prompt
if command -v oh-my-posh &> /dev/null; then
    unset POSH_THEME
    eval "$(oh-my-posh init zsh --config "$DOTFILES_DIR/theme.omp.json")"
fi

# -- Completion --
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# -- History --
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# -- .NET Settings --
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PATH="$PATH:$HOME/.dotnet/tools"
