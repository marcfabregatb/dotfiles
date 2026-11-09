# -- Environment --
export DOTFILES_DIR="${${(%):-%x}:A:h}"
export PATH="$HOME/.local/bin:$PATH"
export COLORTERM=truecolor

# -- Prompt (native zsh, no external binaries; user@host turns red as root) --
autoload -Uz vcs_info add-zsh-hook

# Glyphs: Nerd Font icons under a UTF-8 locale, plain ASCII otherwise (e.g. LANG=C on a
# minimal VM). Without UTF-8, zsh aborts this file at the first $'\u...' escape, so every
# icon stays inside the UTF-8 branch and the probe uses raw bytes (U+276F is 3 chars in C).
_prompt_os_id="$(. /etc/os-release 2>/dev/null; echo "${ID:-linux}")"
case $_prompt_os_id in
    ubuntu) _prompt_os=(ubuntu '#E95420') ;;
    debian) _prompt_os=(debian '#A80030') ;;
    *)      _prompt_os=("$_prompt_os_id" '#FCC624') ;;
esac

typeset -gA _pg
_pg_probe=$'\xe2\x9d\xaf'
if (( ${#_pg_probe} == 1 )); then
    _pg=(cap $'' sep $'' dir $' ' git $' ' err $' '
         root $' ' char $'❯' unstaged $' ' staged $' ')
    case $_prompt_os_id in
        ubuntu) _prompt_os[1]=$'' ;;
        debian) _prompt_os[1]=$'' ;;
        *)      _prompt_os[1]=$'' ;;
    esac
else
    _pg=(cap '' sep '' dir '' git '' err 'exit ' root '' char '%(!.#.>)'
         unstaged ' *' staged ' +')
fi
unset _pg_probe

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr "${_pg[unstaged]}"
zstyle ':vcs_info:git:*' stagedstr "${_pg[staged]}"
zstyle ':vcs_info:git:*' formats '%b%u%c'
zstyle ':vcs_info:git:*' actionformats '%b|%a%u%c'

_prompt_precmd() {
    local code=$?
    vcs_info

    local sep=${_pg[sep]} last
    local host_bg='#3A86FF'
    [[ $HOST == *-dev* ]] && host_bg='#9A00D7'
    (( EUID == 0 )) && host_bg='#D70000'

    local p="%F{${_prompt_os[2]}}${_pg[cap]}%K{${_prompt_os[2]}}%F{#ffffff} ${_prompt_os[1]} "
    p+="%K{$host_bg}%F{${_prompt_os[2]}}$sep%F{#ffffff} %n@%m "
    p+="%K{#0000ff}%F{$host_bg}$sep%F{#ffffff} ${_pg[dir]}%2~ "
    last='#0000ff'

    if [[ -n $vcs_info_msg_0_ ]]; then
        local git_bg='#FFFB38'
        [[ $vcs_info_msg_0_ == *"${_pg[unstaged]}"* || $vcs_info_msg_0_ == *"${_pg[staged]}"* ]] && git_bg='#ffeb95'
        p+="%K{$git_bg}%F{$last}$sep%F{#011627} ${_pg[git]}$vcs_info_msg_0_ "
        last=$git_bg
    fi

    if (( code )); then
        p+="%K{#f1184c}%F{$last}$sep%F{#ffffff} ${_pg[err]}$code "
        last='#f1184c'
    fi

    PROMPT=$'\n'"$p%k%F{$last}$sep%f"$'\n'"%(!.%F{#ffff66}${_pg[root]}.)%(?.%F{#ffffff}.%F{#ff0000})${_pg[char]}%f "
}
add-zsh-hook precmd _prompt_precmd
RPROMPT='%F{#007ACC}%*%f'

# -- Aliases --
# Debian/Ubuntu ship bat as `batcat` (another package owns the `bat` name)
(( $+commands[batcat] && ! $+commands[bat] )) && alias bat=batcat

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
