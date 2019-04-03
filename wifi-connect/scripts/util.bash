#!/bin/bash
# from https://serverfault.com/a/880885
# handles multiple lines, can be piped to
# modified to use our date format
echolog() {
    if [ $# -eq 0 ]; then 
        cat - | while read -r message
        do
            echo "$(date +'[%Y-%m-%d %6N]') $message"
        done
    else
        echo "$(date +'[%Y-%m-%d %T.%6N]') $*"
    fi
}
