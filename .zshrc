# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Early PATH setup
typeset -U path  # Ensure unique entries
path=(
    /opt/homebrew/bin
    /opt/homebrew/opt/postgresql@17/bin
    /snap/bin
    /opt/nvim-linux64/bin
    $HOME/go/bin
    $HOME/.local/scripts
    $HOME/.local/bin
    $HOME/Library/Python/3.9/bin
    $HOME/.spicetify
    $path
)

# Homebrew setup
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Zinit setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Load essential theme first
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Turbo mode for plugins (load in background)
zinit wait"0a" lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    Aloxaf/fzf-tab \
    zsh-users/zsh-syntax-highlighting \
    blockf \
    zsh-users/zsh-completions \
    atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-history-substring-search

# History substring search (prefix only)
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
HISTORY_SUBSTRING_SEARCH_PREFIXED=1
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=#83a598,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=#ea6962,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND+=' underline'

HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt EXTENDED_HISTORY

# Key bindings for command prefix completion with arrows
bindkey "$terminfo[kcuu1]" history-search-backward
bindkey "$terminfo[kcud1]" history-search-forward

# Completion system
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons=always --git --color=always $realpath'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 80 20					# apply to all command
zstyle ':fzf-tab:complete:diff:*' popup-min-size 80 12	# only apply to 'diff'
zstyle ':fzf-tab:*' redraw-prompt true
zstyle ':fzf-tab:*' fzf-flags --color=fg:-1,fg+:-1,bg:-1,bg+:#262626 --color=hl:#689d6a,hl+:#8ec07c,info:#d4be98,marker:#d3869b --color=prompt:#83a598,spinner:#83a598,pointer:#8ec07c,header:#83a598 --color=gutter:-1,border:#ddc7a1,preview-fg:#d4be98,label:#aeaeae --color=query:#d4be98 --border-label="" --preview-window="border-rounded" --prompt=" " --marker="" --pointer="" --separator="─" --scrollbar="│" --info="right"

# Aliases
alias l='eza --icons=always -l --git'
alias ls='eza --icons=always'
alias la='eza --icons=always -la --git'
alias lt='eza --icons=always -l --tree --git --level 3'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias vim='nvim'
alias ld='lazydocker'
alias pipes='pipes.sh -t 1 -f 100 -r 4000 -R -s 15 -p 4'
alias fortune='clear && fortune | cowsay -f stegosaurus | lolcat'
alias .='nvim .'
alias kssh="kitty +kitten ssh"

# Fortune widget with ctrl+f
fortune_widget() {
    fortune
    zle reset-prompt
}
zle -N fortune_widget
bindkey '^F' fortune_widget

# y for yazi to cd into dir
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Change cursor shape for different vi modes.
function zle-keymap-select () {
	case $KEYMAP in
	vicmd) echo -ne '\e[1 q';; # block
	viins|main) echo -ne '\e[6 q';; # beam
	esac
}
zle -N zle-keymap-select
zle-line-init() {
	echo -ne "\e[6 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[6 q' ;} # Use beam shape cursor for each new prompt.

export EDITOR="nvim"
export XDG_CONFIG_HOME=~/.config/
export MANPAGER='nvim +Man!'
export MANWIDTH=999

# Fzf preview theme
export FZF_DEFAULT_OPTS='
--color=fg:-1,fg+:-1,bg:-1,bg+:#262626
--color=hl:#689d6a,hl+:#8ec07c,info:#d4be98,marker:#d3869b
--color=prompt:#83a598,spinner:#83a598,pointer:#8ec07c,header:#83a598
--color=gutter:-1,border:#ddc7a1,preview-fg:#d4be98,label:#aeaeae
--color=query:#d4be98
--border-label="" --preview-window="border-rounded" --prompt=" "
--marker="" --pointer="" --separator="─" --scrollbar="│"
--info="right"'


# Fzf history search
COLOR_LINE_NUM="\033[36m"     # Cyan for line number
COLOR_TIMESTAMP="\033[33m"    # Yellow for timestamp
COLOR_RESET="\033[0m"
fzf-history-widget() {
    local selected raw_line

    # Use awk to colorize line number and timestamp
    # History line format: N YYYY-MM-DD HH:MM:SS command...
    selected="$(
        history -i 0 \
            | awk -v cnum="$COLOR_LINE_NUM" -v ctime="$COLOR_TIMESTAMP" -v cre="$COLOR_RESET" '
          {
            line_num = $1
            date = $2
            time = $3
            # Rebuild the rest of the command
            cmd = ""
            for (i = 4; i <= NF; i++) cmd = cmd " " $i
            # Print colored line number and timestamp, then the command
            printf("%s%s%s %s%s %s%s%s\n", cnum, line_num, cre, ctime, date, time, cre, cmd)
          }
        ' \
            | fzf --tac --ansi --height 50% --reverse --border --prompt='history  '
    )"

    if [[ -n "$selected" ]]; then
        # Strip ANSI escape codes before extracting the command fields
        raw_line=$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g')

        # Now extract just the command, removing the first three fields
        # Fields after stripping ANSI codes: N YYYY-MM-DD HH:MM:SS command...
        LBUFFER=$(echo "$raw_line" | awk '{ $1=""; $2=""; $3=""; sub(/^ +/, ""); print }')
        zle end-of-line
    fi
    zle redisplay
}

zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# fix home-end keys
bindkey -M viins '^[[1~' beginning-of-line
bindkey -M viins '^[[4~' end-of-line
bindkey -M vicmd '^[[1~' beginning-of-line
bindkey -M vicmd '^[[4~' end-of-line
# fix delete key
bindkey -M viins '^[[3~' delete-char
bindkey -M vicmd '^[[3~' delete-char

# delete word with ctrl + backspace
bindkey -M viins '^H' backward-delete-word
bindkey -M vicmd '^H' backward-delete-word
# delete forward word with ctrl + del
bindkey -M viins '^[[3;5~' delete-word
bindkey -M vicmd '^[[3;5~' delete-word

# SDKMAN (lazy-loaded)
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    function sdk() {
        unfunction sdk
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        sdk "$@"
    }
fi

# Load p10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
