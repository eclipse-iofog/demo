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
    login=$(curl --request POST \
        --url $CONTROLLER_HOST/user/login \
        --header 'Content-Type: application/json' \
        --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
    token=$(echo $login | jq -r .accessToken)
}

function microservices() {
    echo ">>>>>>>>> get catalog items ids"
    item=""
    while true; do
        item=$(curl --request GET \
            --url $CONTROLLER_HOST/catalog/microservices \
            --header "Authorization: $token" \
            --header 'Content-Type: application/json')

        sensorsId=$(echo $item | jq -r '.[] | select(.name == "Sensors") | .id')
        apiId=$(echo $item | jq -r '.[] | select(.name == "Rest API") | .id')
        freeboardId=$(echo $item | jq -r '.[] | select(.name == "freeboard") | .id')

        if [ ! -z "$sensorsId" ] && [ ! -z "$apiId" ] && [ ! -z "$freeboardId" ]; then
            break
        fi
        sleep .5
    done

    echo ">>>>>>>>> create iofog node"
    item=$(curl --request POST \
        --url $CONTROLLER_HOST/iofog \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name": "Agent '"$NODE_NUMBER"'","fogType": 1}')
    uuid=$(echo $item | jq -r .uuid)
    echo $uuid

    echo ">>>>>>>>> create flow"
    item=$(curl --request POST \
        --url $CONTROLLER_HOST/flow \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name": "Flow '"$NODE_NUMBER"'","isActivated":true}')
    flowId=$(echo $item | jq -r .id)
    echo $flowId

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"API","config":"{}","catalogItemId":'"$apiId"',"flowId":'"$flowId"',"ioFogNodeId":"'"$uuid"'","rootHostAccess":false,"logLimit":5,"volumeMappings":[],"ports":[{"internal":80,"external":'"$NODE_NUMBER"'0101,"publicMode":false}],"routes":[]}')
    apiUUID=$(echo $item | jq -r .uuid)
    item=$(curl --request POST \
        --url $CONTROLLER_HOST/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"Sensors","config":"{}","catalogItemId":'"$sensorsId"',"flowId":'"$flowId"',"ioFogNodeId":"'"$uuid"'","rootHostAccess":false,"logLimit":5,"volumeMappings":[],"ports":[],"routes":["'"$apiUUID"'"]}')
    sensorsUUID=$(echo $item | jq -r .uuid)
    item=$(curl --request POST \
        --url $CONTROLLER_HOST/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"freeboard","config":"{}","catalogItemId":'"$freeboardId"',"flowId":'"$flowId"',"ioFogNodeId":"'"$uuid"'","rootHostAccess":false,"logLimit":5,"volumeMappings":[],"ports":[{"internal":80,"external":'"$NODE_NUMBER"'0102,"publicMode":false}],"routes":[]}')
    freeboardUUID=$(echo $item | jq -r .uuid)
    echo $apiUUID
    echo $sensorsUUID
    echo $freeboardUUID
}

function provision() {
    provisioning=$(curl --request GET \
        --url $CONTROLLER_HOST/iofog/$uuid/provisioning-key \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json')
    key=$(echo $provisioning | jq -r .key)

    iofog provision $key
}

service iofog start
if [ -f /first_run.tmp ]; then
    wait "iofog status" "iofog is not running."
    iofog config -idc off
    iofog config -a $CONTROLLER_HOST
    wait "curl --request GET --url $CONTROLLER_HOST/status" "Failed"
    sleep 3
    login
    microservices
    provision
    rm /first_run.tmp
fi
tail -f /dev/null