cdn () {
    pushd . 
    for ((i=1; i<=$1; i++))
    do
        cd ..
    done
    pwd
}
cdu () {
    cd "${PWD%/$1/*}/$1"
}
alias 51="ssh 140.109.19.51"
alias 191="ssh 140.109.19.191"
