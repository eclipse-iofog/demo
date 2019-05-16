#!/usr/bin/env bash

set -e

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
    AGENT="$1"
    echo 'Getting nodes list'
    while true; do
        item=$(curl --request GET \
            --url $CONTROLLER_HOST/iofog-list \
            --header "Authorization: $token" \
            --header 'Content-Type: application/json')
        echo "$item"
        uuid=$(echo $item | jq -r '.fogs[] | select(.name == "Agent '"$AGENT"'") | .uuid')

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

    docker exec iofog-agent-"$AGENT" sh -c "iofog-agent provision $key"
}

echo 'Waiting for Controller'
wait "curl --request GET --url $CONTROLLER_HOST/status" "Failed"

login

for AGENT in 1 2; do
    echo "Waiting for Agent $AGENT"
    wait "docker exec iofog-agent-$AGENT iofog-agent status" "ioFog Agent is not running."
    docker exec iofog-agent-"$AGENT" sh -c "iofog-agent config -idc off"
    docker exec iofog-agent-"$AGENT" sh -c "iofog-agent config -a $CONTROLLER_HOST"

    provision "$AGENT"
done