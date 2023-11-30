#! /bin/bash

# color define
RED_COLOR='\E[0;31m'
GREEN_COLOR='\E[0;32m'
YELLOW_COLOR='\E[0;33m'
RESET='\E[0m'

function echo_red() {
    echo -e "${RED_COLOR}${1}${RESET}"
}

function echo_green() {
    echo -e "${GREEN_COLOR}${1}${RESET}"
}

function command_exist() {
    if command -v $1 >/dev/null 2>&1; then 
        echo_green "check <$1> pass"
    else
        echo_red "command <$1> does not exists"
        exit 1
    fi
}

function exit_on_err() {
    echo "Execute command: $1"
    eval "$1" 2>&1 >/dev/null
    if [[ 0 -ne $? ]]; then
        if [[ -z "$2" ]]; then
            echo_red "`date '+%F %T'` `caller 0 | awk '{print "("$1")"}'`run command failed: $1"
        else
            echo_red "`date '+%F %T'` `caller 0 | awk '{print "("$1")"}'` $2"
        fi
        exit 1
    fi
}

# necessary checking
command_exist "helm"
command_exist "helm-schema-gen"
command_exist "helm-docs"

# generate [values.schema.json] and [README.md]
exit_on_err "helm-schema-gen values.yaml > values.schema.json"
exit_on_err "helm-docs"
