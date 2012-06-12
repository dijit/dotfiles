# support colors in less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

function promptcommand
{
    # This function is executed after each prompt command

    EXIT_STATUS="$?"

    # Bash 4 and up yield 130 for Ctrl+C on blank lines. Older shells do
    # not have this feature. For the newer shells, we do not show the exit
    # status for Ctrl+C as it gets annoying to see an exit status indicator
    # just for hitting Ctrl+C.
    CTRL_C="130" && [[ "${BASH_VERSINFO[0]}" -lt 4 ]] && CTRL_C="-1"

    if [[ "${EXIT_STATUS}" -eq "0" || "${EXIT_STATUS}" -eq "${CTRL_C}" ]]
    then
        if [[ "${HISTFILE+defined}" ]]
        then
            TERMINATOR=" ${OFF}[${BLUE}\!${OFF}]"
        else
            TERMINATOR=" ${OFF}[${BLUE}*${OFF}]"
        fi
    else
        TERMINATOR=" ${OFF}[${RED}${EXIT_STATUS}${OFF}]"
    fi

    title "$PWD"
    export PS1="${OFF}${WHITE}\h${OFF}:${GRAY}\W${TERMINATOR}\$${OFF} "
    history -a
    history -n
    pwd > $LASTDIRFILE
}
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
#    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# some more ls aliases
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'
alias release='cat /etc/debian_version'
 
# fun
lookofdissaproval(){
echo "ಠ_ಠ";
}

