#!/usr/bin/env bash
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

service iofog-agent start
if [ -f /first_run.tmp ]; then
    wait "iofog-agent status" "ioFog Agent is not running."
    iofog-agent config -idc off
    iofog-agent config -a $CONTROLLER_HOST
    wait "curl --request GET --url $CONTROLLER_HOST/status" "Failed"

    sleep 10
    token=""
    while true; do
        login=$(curl --request POST \
            --url $CONTROLLER_HOST/user/login \
            --header 'Content-Type: application/json' \
            --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
        token=$(echo $login | jq -r .accessToken)

        if [ ! -z "$token" ]; then
            break
        fi
        sleep .5
    done

    uuid=""
    echo "Waiting for ioFog Controller..."
    while true; do
        item=$(curl --request GET \
            --url $CONTROLLER_HOST/iofog-list \
            --header "Authorization: $token" \
            --header 'Content-Type: application/json')
        echo $item
        uuid=$(echo $item | jq -r '.fogs[] | select(.name == "ioFog Node") | .uuid')

        if [ ! -z "$uuid" ]; then
            break
        fi
        sleep .5
    done

    provisioning=$(curl --request GET \
        --url $CONTROLLER_HOST/iofog/$uuid/provisioning-key \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json')
    key=$(echo $provisioning | jq -r .key)

    iofog-agent provision $key

    rm /first_run.tmp
fi
tail -f /dev/null