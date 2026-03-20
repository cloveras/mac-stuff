# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Colors
export CLICOLOR=1
export LSCOLORS=CxFxCxDxBxegedabagaced

# Aliases
alias m='less'
alias ls='ls -GFC'
alias ll='ls -Gl'
alias la='ls -Gla'

alias h='history'
alias hh='history | grep -i'

alias gs='git status'
alias gp='git push'
alias gc='git commit -v'
# Pull from all repos under current directory:
alias gitall='find . -type d -depth 1 -exec git --git-dir={}/.git --work-tree=$PWD/{} pull origin master \;'
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Claude CLI
export PATH="$HOME/.local/bin:$PATH"

# Prompt configuration
# parse_git_branch: returns " [branch-name]" if inside a git repo, empty otherwise
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/'
}
setopt PROMPT_SUBST
# Prompt format: user@host · ~/path [git-branch] $
#   - Bold green username, green @host
#   - Grey · separator
#   - Blue current directory (full path)
#   - Yellow git branch in brackets (only shown inside a git repo)
#   - %(#.#.$): shows # when running as root/sudo, $ for normal user
export PS1='%F{076}%B%n%b%f%F{076}@%m%f%F{246} · %f%F{039}%~%f${$(parse_git_branch):+ }%F{yellow}$(parse_git_branch)%f %(#.#.$)'
