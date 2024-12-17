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
    /usr/local/go/bin
	$HOME/.local/scripts
	$HOME/.local/bin
    $HOME/Library/Python/3.9/bin
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
	joshskidmore/zsh-fzf-history-search \
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
zstyle ':fzf-tab:*' fzf-flags --color=fg:-1,fg+:-1,bg:-1,bg+:#262626 --color=hl:#689d6a,hl+:#8ec07c,info:#d4be98,marker:#d3869b --color=prompt:#83a598,spinner:#83a598,pointer:#8ec07c,header:#83a598 --color=gutter:-1,border:#ddc7a1,preview-fg:#d4be98,label:#aeaeae --color=query:#d4be98 --border-label="" --preview-window="border-rounded" --prompt="❯ " --marker="❯" --pointer="❯" --separator="─" --scrollbar="│" --info="right"

# Aliases
alias l='eza --icons=always -l --git'
alias ls='eza --icons=always'
alias la='eza --icons=always -la --git'
alias lt='eza --icons=always -l --tree --git --level 3'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias vim='nvim'
alias xx='exit'
alias pipes='pipes.sh -t 3'
alias fortune='fortune | cowsay -f stegosaurus'

export EDITOR="nvim"
export XDG_CONFIG_HOME=~/.config/

# Fzf preview theme: not working right now
export FZF_DEFAULT_OPTS='
  --color=fg:-1,fg+:-1,bg:-1,bg+:#262626
  --color=hl:#689d6a,hl+:#8ec07c,info:#d4be98,marker:#d3869b
  --color=prompt:#83a598,spinner:#83a598,pointer:#8ec07c,header:#83a598
  --color=gutter:-1,border:#ddc7a1,preview-fg:#d4be98,label:#aeaeae
  --color=query:#d4be98
  --border-label="" --preview-window="border-rounded" --prompt="❯ "
  --marker="❯" --pointer="❯" --separator="─" --scrollbar="│"
  --info="right"'

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

