export CLICOLOR=1
export EDITOR="vim"
export GREP_OPTIONS='--color=auto'

[[ -s /usr/local/rvm/scripts/rvm ]] && source /usr/local/rvm/scripts/rvm

if command -v ack-grep >/dev/null; then
  alias ack='ack-grep'
fi

rails_version() {
  which -s rails && rails -v 2>/dev/null | sed 's/Rails //'
}

r() {
  local name="$1"
  shift
  if [[ -z "$name" ]]; then
    echo "Usage: $0 command *args" >&2
    return 1
  fi
  if [[ -x "./script/$name" ]]; then
    ./script/$name $@
  elif [[ -x "./script/rails" ]]; then
    ./script/rails "$name" $@
  elif [[ -n "$(rails_version | grep '^3')" ]]; then
    rails "$name" $@
  else
    echo "Please change to the root of your project first." >&2
    return 1
  fi
}

ss() {
  if [[ -s ./Procfile ]]; then
    if ! command -v foreman >/dev/null; then
      echo "Please run: gem install foreman"
      return 1
    fi
    foreman start
  else
    r server "$@"
  fi
  
}

alias sc="r console"
alias sp='r plugin'
alias sg='r generate'
alias sd="r dbconsole"

# General log utilities etc
alias rr='touch tmp/restart.txt'
alias wl='mkdir -p tmp && tail -n0 -f log/*.log'
alias rwl='rr && wl'
alias rd='rr && touch tmp/debug.txt'
alias rdl='rd && wl'

# General shell options
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi