# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Set umask for security
umask 0077

# Set server hostname variables
export "bender=ec2-18-188-2-38.us-east-2.compute.amazonaws.com"

# update PATH variable
export "PATH=$HOME/bin:$PATH"
