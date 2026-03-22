# -- Environment --
export DOTFILES_DIR="${${(%):-%x}:A:h}"
export PATH="$HOME/.local/bin:$PATH"
export COLORTERM=truecolor

# -- Prompt (Oh My Posh) --
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config "$DOTFILES_DIR/theme.omp.json")"
fi

# -- Plugins --
# Autosuggestions (fish-like ghost text, accept with Right Arrow)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
[[ -f "$DOTFILES_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$DOTFILES_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax Highlighting (colors commands as you type; must load last among plugins)
[[ -f "$DOTFILES_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$DOTFILES_DIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

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
