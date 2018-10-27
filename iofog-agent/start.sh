#!/usr/bin/env bash
CONTROLLER_HOST="http://iofog-controller:51121/api/v3"

function provision() {
    login=$(curl --request POST \
        --url $CONTROLLER_HOST/user/login \
        --header 'Content-Type: application/json' \
        --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
    token=$(echo $login | jq -r .accessToken)
    
    node=$(curl --request POST \
        --url $CONTROLLER_HOST/iofog \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name": "Agent $NODE_NUMBER","fogType": 1}')
    uuid=$(echo $node | jq -r .uuid)
    
    provisioning=$(curl --request GET \
        --url $CONTROLLER_HOST/iofog/$uuid/provisioning-key \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json')
    key=$(echo $provisioning | jq -r .key)

    iofog provision $key
}

function wait() {
    while true; do
        str=`eval "$1"`
        if [[ ! $str =~ $2 ]]; then
            break
        fi
        sleep .5
    done
}

service iofog start
if [ -f /first_run.tmp ]; then
    wait "iofog status" "iofog is not running."
    iofog config -idc off
    iofog config -a $CONTROLLER_HOST
    wait "curl --request GET --url $CONTROLLER_HOST/status" "Failed"
    provision
    rm /first_run.tmp
fi
tail -f /dev/null