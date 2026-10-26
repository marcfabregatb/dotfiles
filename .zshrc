# -- Environment --
export DOTFILES_DIR="${${(%):-%x}:A:h}"
export PATH="$HOME/.local/bin:$PATH"
export COLORTERM=truecolor

# -- Prompt (Oh My Posh) --
if command -v oh-my-posh &> /dev/null; then
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

# -- Plugins (installed via apt; loaded last so they see every widget) --
# Autosuggestions (fish-like ghost text, accept with Right Arrow)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax Highlighting (colors commands as you type; must stay last in this file)
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
