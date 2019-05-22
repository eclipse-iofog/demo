#!/usr/bin/env bash
CONTROLLER_HOST="http://iofog-controller:51121/api/v3"

token=""
uuid=""

function wait() {
    while true; do
        str=`eval "$1"`
        if [[ ! $str =~ $2 ]]; then
            break
        fi
        sleep .5
    done
}

function login() {
    echo 'Logging in'
    login=$(curl --request POST \
        --url $CONTROLLER_HOST/user/login \
        --header 'Content-Type: application/json' \
        --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
    echo "$login"
    token=$(echo $login | jq -r .accessToken)
}

function provision() {
    echo 'Getting nodes list'
    while true; do
        item=$(curl --request GET \
            --url $CONTROLLER_HOST/iofog-list \
            --header "Authorization: $token" \
            --header 'Content-Type: application/json')
        uuid=$(echo $item | jq -r '.fogs[] | select(.name == "Agent") | .uuid')

        if [ ! -z "$uuid" ]; then
            echo "$item"
            break
        fi
        sleep .5
    done

    echo 'Provisioning'
    provisioning=$(curl --request GET \
        --url $CONTROLLER_HOST/iofog/$uuid/provisioning-key \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json')
    echo "$provisioning"
    key=$(echo $provisioning | jq -r .key)

    iofog-agent provision $key
}

service iofog-agent start
if [ -f /first_run.tmp ]; then
    wait "iofog-agent status" "ioFog Agent is not running."
    iofog-agent config -idc off
    iofog-agent config -a $CONTROLLER_HOST

    wait "curl --request GET --url $CONTROLLER_HOST/status" "Failed"

    docker exec iofog-controller sh -c "ls /ready" > /dev/null 2>&1
    while [ `echo $?` != 0 ]; do
        sleep .5
        docker exec iofog-controller sh -c "ls /ready" > /dev/null 2>&1
    done

    login
    provision
    rm /first_run.tmp
fi

tail -f /dev/null