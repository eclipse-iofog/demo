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

service iofog start
if [ -f /first_run.tmp ]; then
    sleep 5
    iofog config -idc off
    sleep 5
    iofog config -a $CONTROLLER_HOST
    provision
    rm /first_run.tmp
fi
tail -f /dev/null