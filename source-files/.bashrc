# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Set umask for security
umask 0077

# update PATH variable
export "PATH=$HOME/bin:$PATH"
