
# Set Zinit home directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Plugin Loading (Lazy load)
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt extended_history appendhistory sharehistory hist_ignore_space hist_ignore_dups

# Completion settings
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Aliases
alias ls='ls --color=auto -hF --group-directories-first'
alias vim='nvim'
alias c='clear'
alias open='xdg-open'
alias cd='z'
# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Fzf Preview
fzfp() { fzf --preview "bat --style=header,grid --color=always --line-range :500 {}" }

prompt off
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

export PATH="$HOME/.local/bin:$PATH"
