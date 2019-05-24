#!/usr/bin/env bash

set -e

CONTROLLER_HOST="http://iofog-controller:51121/api/v3"

function wait() {
    while true; do
        str=`eval "$1"`
        if [[ ! $str =~ $2 ]]; then
            break
        fi
        sleep .5
    done
}

echo 'Waiting for Agent'
wait "docker exec iofog-agent-1 iofog-agent status" "ioFog Agent is not running."
docker exec iofog-agent-1 iofog-agent config -idc off
docker exec iofog-agent-1 iofog-agent config -a $CONTROLLER_HOST

echo 'Waiting for Controller'
wait "curl --request GET --url $CONTROLLER_HOST/status 2> /dev/null" "Failed"

token=""
while true; do
    login=$(curl --request POST \
        --url $CONTROLLER_HOST/user/login \
        --header 'Content-Type: application/json' \
        --data '{"email":"user@domain.com","password":"#Bugs4Fun"}' \
        2> /dev/null)
    token=$(echo $login | jq -r .accessToken)

    if [ ! -z "$token" ]; then
        break
    fi
    sleep .5
done

uuid=""
while true; do
    item=$(curl --request GET \
        --url $CONTROLLER_HOST/iofog-list \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        2> /dev/null)
    #echo $item
    uuid=$(echo $item | jq -r '.fogs[] | select(.name == "ioFog Node") | .uuid')

    if [ ! -z "$uuid" ]; then
        break
    fi
    sleep .5
done

provisioning=$(curl --request GET \
    --url $CONTROLLER_HOST/iofog/$uuid/provisioning-key \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    2> /dev/null)
key=$(echo $provisioning | jq -r .key)

docker exec iofog-agent-1 iofog-agent provision $key