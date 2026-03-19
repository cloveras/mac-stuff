# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Aliases
alias m='less'
export CLICOLOR=1
export LSCOLORS=CxFxCxDxBxegedabagaced
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
# export PS1='%F{076}%n@%m%f:%F{076}%~%f%F{yellow}$(parse_git_branch)%f %# '
export PS1='%F{076}%B%n%b%f%F{076}@%m%f%F{246} · %f%F{039}%~%f${$(parse_git_branch):+ }%F{yellow}$(parse_git_branch)%f %#'
