# -- Environment --
export DOTFILES_DIR="${${(%):-%x}:A:h}"
export PATH="$HOME/.local/bin:$PATH"
export COLORTERM=truecolor

# -- Prompt (native zsh, no external binaries; user@host turns red as root) --
autoload -Uz vcs_info add-zsh-hook

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr $' \uf044'
zstyle ':vcs_info:git:*' stagedstr $' \uf046'
zstyle ':vcs_info:git:*' formats '%b%u%c'
zstyle ':vcs_info:git:*' actionformats '%b|%a%u%c'

# OS segment icon and color, read once
case "$(. /etc/os-release 2>/dev/null; echo "$ID")" in
    ubuntu) _prompt_os=($'\uf31b' '#E95420') ;;
    debian) _prompt_os=($'\uf306' '#A80030') ;;
    *)      _prompt_os=($'\uf17c' '#FCC624') ;;
esac

_prompt_precmd() {
    local code=$?
    vcs_info

    local sep=$'\ue0b0' last
    local host_bg='#3A86FF'
    [[ $HOST == *-dev* ]] && host_bg='#9A00D7'
    (( EUID == 0 )) && host_bg='#D70000'

    local p="%F{${_prompt_os[2]}}"$'\ue0b6'"%K{${_prompt_os[2]}}%F{#ffffff} ${_prompt_os[1]} "
    p+="%K{$host_bg}%F{${_prompt_os[2]}}$sep%F{#ffffff} %n@%m "
    p+="%K{#0000ff}%F{$host_bg}$sep%F{#ffffff} "$'\ue5ff'" %2~ "
    last='#0000ff'

    if [[ -n $vcs_info_msg_0_ ]]; then
        local git_bg='#FFFB38'
        [[ $vcs_info_msg_0_ == *$'\uf044'* || $vcs_info_msg_0_ == *$'\uf046'* ]] && git_bg='#ffeb95'
        p+="%K{$git_bg}%F{$last}$sep%F{#011627} "$'\ue725'" $vcs_info_msg_0_ "
        last=$git_bg
    fi

    if (( code )); then
        p+="%K{#f1184c}%F{$last}$sep%F{#ffffff} "$'\ue23a'" $code "
        last='#f1184c'
    fi

    PROMPT=$'\n'"$p%k%F{$last}$sep%f"$'\n'"%(!.%F{#ffff66}"$'\uf0e7'" .)%(?.%F{#ffffff}.%F{#ff0000})❯%f "
}
add-zsh-hook precmd _prompt_precmd
RPROMPT='%F{#007ACC}%*%f'

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
