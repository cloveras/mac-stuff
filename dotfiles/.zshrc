# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Aliases
alias m='less'
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
alias ls='ls -GFC'
alias ll='ls -Gl'
alias la='ls -Gla'

alias gs='git status'
alias gp='git push'
alias gc='git commit -v'
# Pull from all repos under current directory:
alias gitall='find . -type d -depth 1 -exec git --git-dir={}/.git --work-tree=$PWD/{} pull origin master \;'
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Claude CLI
export PATH="$HOME/.local/bin:$PATH"

# Git branch in prompt
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/'
}
setopt PROMPT_SUBST
export PS1='%B%F{cyan}%n@%m%f%b:%B%F{cyan}%~%f%b%F{yellow}$(parse_git_branch)%f %# '
