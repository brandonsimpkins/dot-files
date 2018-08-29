# .bash_profile

# Source the user .bashrc file
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

# Set color escape variables
export color_bold_black="\[\033[1;30m\]"
export color_bold_red="\[\033[1;31m\]"
export color_bold_green="\[\033[1;32m\]"
export color_bold_blue="\[\033[1;34m\]"
export color_bold_magenta="\[\033[1;35m\]"
export color_black="\[\033[0;30m\]"
export color_red="\[\033[0;31m\]"
export color_green="\[\033[0;32m\]"
export color_blue="\[\033[0;34m\]"
export color_magenta="\[\033[0;35m\]"
export color_reset="\[\033[0m\]"

# Determine if host is local or not
if [ "$(hostname -s)" == "8c8590968aad" ]; then
  current_host="${color_green}MacBook${color_reset}"
else
  current_host="${color_red}$(hostname -s)${color_reset}"
fi

# Set the prompt

export "PS1=[${color_blue}\u${color_reset}@${current_host}${color_magenta} \W${color_reset}]\$ "

# Set Aliases
if [ "$(uname)" == "Linux" ]; then
  alias ll='ls -lah --color=auto'
elif [ "$(uname)" == "Darwin" ]; then
  alias ll='ls -lahG'
else
  echo "Warning: failed to set 'll' alias for '$(uname)' OS."
fi
alias dim='echo Terminal Dimensions: $(tput cols) columns x $(tput lines) rows'


# Set SVN related settings
alias propset='svn propset svn:externals -F svn.externals .'
alias propget='svn propget svn:externals .'
export SVN_EDITOR='vim'

# Set Git related settings
export EDITOR='vim'

# Declare local functions
function bfind
{
  find ./ \( -path '*ntcss-sybase' -o -path '*h/NTCSSS/spool/pipes' \) \
    -prune -o -print | grep -v '.svn' | xargs grep -En "$1" 2>/dev/null
}

function bstat()
{
  svn status $@ | grep -Ev "^Perform|^X|^$"
}

function gdiff()
{
  git diff $@ > changes.$$.patch && vim changes.$$.patch && rm -f changes.$$.patch
}


# Frickin Amazon Linux....
# unset PYTHON_INSTALL_LAYOUT
