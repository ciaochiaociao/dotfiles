prompt=$'Load from tmux session: \n'
prompt+=$(tmux list-sessions)
prompt+=$'\nsession name: (n for not loading tmux session) '
read "session?$prompt? " || session='n'

# https://stackoverflow.com/questions/14366390/check-if-an-element-is-present-in-a-bash-array
if [[ 'n' == "$session" ]]
then
    echo -e "\nNot loading any tmux session :("
else
    tmux a -t $session
    success=$?

    if [ $success -ne 0 ]
    then
        prompt='tmux session not found!! Creating a new one ? (y/n) '  
        read "create?$prompt? " || create=n
        if [[ ' y yes ' == *" $create "* ]]
        then
            tmux new -s $session
        else
            echo -e "\nNot loading any tmux session :("
        fi
    fi
fi

