prompt=$'Load from tmux session: \n'
prompt+=$(tmux list-sessions)
prompt+=$'\nsession name: (n) '
read -e -r -p "$prompt" -t 15 -i 'main' session || session='n'

# https://stackoverflow.com/questions/14366390/check-if-an-element-is-present-in-a-bash-array
if [[ ' n no q quit ' == *" $session "* ]]
then
    echo -e "\nNot loading any tmux session :("
else
    tmux a -t $session
    success=$?

    if [ $success -ne 0 ]
    then
        read -p 'tmux session not found!! Creating a new one ? (y/n) ' create || create=n
        if [[ ' y yes ' == *" $create "* ]]
        then
            tmux new -s $session
        else
            echo -e "\nNot loading any tmux session :("
        fi
    fi
fi

