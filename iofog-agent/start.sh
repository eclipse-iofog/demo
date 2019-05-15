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

if [ -f /first_run.tmp ]; then
    docker exec iofog-controller sh -c "ls /ready" > /dev/null 2>&1
    while [ `echo $?` != 0 ]; do
        sleep .5
        docker exec iofog-controller sh -c "ls /ready" > /dev/null 2>&1
    done

    echo 'Logging in'
    login=$(curl --request POST \
        --url $CONTROLLER_HOST/user/login \
        --header 'Content-Type: application/json' \
        --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
    echo "$login"
    token=$(echo $login | jq -r .accessToken)

    echo 'Listing nodes'
    item=$(curl --request GET \
        --url $CONTROLLER_HOST/iofog-list \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json')
    echo "$item"
    uuid=$(echo $item | jq -r '.fogs[] | select(.name == "'"$NODE_NAME"'") | .uuid')

    echo 'Provisioning'
    provisioning=$(curl --request GET \
        --url $CONTROLLER_HOST/iofog/$uuid/provisioning-key \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json')
    echo "$provisioning"
    key=$(echo $provisioning | jq -r .key)

    service iofog-agent start
    wait "iofog-agent status" "ioFog Agent is not running."
    iofog-agent config -idc off
    iofog-agent config -a $CONTROLLER_HOST

    iofog-agent provision $key

    rm /first_run.tmp
fi
tail -f /dev/null