#!/bin/bash

# Usage: setup.sh

set_cygwin_home_to_windows_home() {
    # Usually USERPROFILE is already set when you open a new Cygwin terminal
    if [ -z "$USERPROFILE" ]; then
        local windows_user=$(id -un)
        USERPROFILE="C:\\Users\\$windows_user"
    fi
    # Windows path to Cygwin home directory: $(cygpath -w ~) e.g. C:\cygwin64\home\jonathan
    local cygwin_home=$(cygpath ~)
    local windows_home=$(cygpath $USERPROFILE)

    if [ "$cygwin_home" == "$windows_home" ]; then
        # signal that cygwin restart is not required
        return 1
    fi

    #local username=$(whoami)
    local dotfiles=".bash_profile .bashrc .gitconfig .inputrc .profile"
    for dotfile in $dotfiles
    do
        if [ ! -f $windows_home/$dotfile ] && [ -f $cygwin_home/$dotfile ]; then
            mv $cygwin_home/$dotfile $windows_home/
        fi
    done

    # This change will take effect after cygwin restart.
    # Ref: https://stackoverflow.com/questions/1494658/how-can-i-change-my-cygwin-home-folder-after-installation
    if grep -e '^db_home' /etc/nsswitch.conf; then
        # signal that cygwin restart is not required
        return 1
    fi
    echo -e "\ndb_home: windows\n" >> /etc/nsswitch.conf
    # signal that restart is required
    return 0
    #echo HOME=$HOME  
}

restart_cygwin() {
    # The changes from set_cygwin_home_to_windows_home will take effect for new terminal sessions.
    # Here we reset value of $HOME to the new location for current session (but only works if this script is sourced)
    local windows_home=$(cygpath $USERPROFILE)
    export HOME=$windows_home
    echo
    echo "Action required: close and re-open Cygwin terminal"
    echo
}

set_cygwin_home_to_windows_home && restart_cygwin
