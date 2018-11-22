#!/usr/bin/env sh

CONTROLLER_HOST="http://localhost:54421/api/v3"

iofog-controller start
if [ -f /first_run.tmp ]; then
    iofog-controller user add -f John -l Doe -e user@domain.com -p "#Bugs4Fun"

    connector_ip=$(getent hosts iofog-connector | awk '{ print $1 }')
    iofog-controller connector add -n iofog-connector -d $connector_ip -i $connector_ip -H

    while true; do
        item=$(curl --request POST \
            --url http://iofog-connector:8080/api/v2/status \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --data mappingid=all)
        status=$(echo $item | jq -r .status)

        if [ "$status" == "running" ]; then
            break
        fi
        sleep .5
    done

    login=$(curl --request POST \
        --url $CONTROLLER_HOST/user/login \
        --header 'Content-Type: application/json' \
        --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
    token=$(echo $login | jq -r .accessToken)

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/catalog/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"Sensors","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/sensors:latest","fogTypeId":1}]}')
    sensorsId=$(echo $item | jq -r .id)

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/catalog/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"Rest API","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/freeboard-api:latest","fogTypeId":1}]}')
    apiId=$(echo $item | jq -r .id)

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/catalog/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"freeboard","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/freeboard:latest","fogTypeId":1}]}')
    freeboardId=$(echo $item | jq -r .id)

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/iofog \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name": "Agent 1","fogType": 1}')
    uuid1=$(echo $item | jq -r .uuid)

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/iofog \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name": "Agent 2","fogType": 1}')
    uuid2=$(echo $item | jq -r .uuid)

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/flow \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name": "Flow","isActivated":true}')
    flowId=$(echo $item | jq -r .id)

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"API","config":"{}","catalogItemId":'"$apiId"',"flowId":'"$flowId"',"iofogUuid":"'"$uuid2"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[{"internal":80,"external":10101,"publicMode":false}],"routes":[]}')
    apiUUID=$(echo $item | jq -r .uuid)

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"Sensors","config":"{}","catalogItemId":'"$sensorsId"',"flowId":'"$flowId"',"iofogUuid":"'"$uuid1"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[],"routes":[]}')
#        --data '{"name":"Sensors","config":"{}","catalogItemId":'"$sensorsId"',"flowId":'"$flowId"',"iofogUuid":"'"$uuid1"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[],"routes":["'"$apiUUID"'"]}')
    sensorsUUID=$(echo $item | jq -r .uuid)
    item=$(curl -X POST \
        --url "$CONTROLLER_HOST/microservices/$sensorsUUID/routes/$apiUUID" \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json')

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"freeboard","config":"{}","catalogItemId":'"$freeboardId"',"flowId":'"$flowId"',"iofogUuid":"'"$uuid2"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[{"internal":80,"external":10102,"publicMode":false}],"routes":[]}')
    freeboardUUID=$(echo $item | jq -r .uuid)

    rm /first_run.tmp

    touch /ready
fi
tail -f /dev/null