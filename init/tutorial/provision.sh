#!/usr/bin/env sh

# TODO finish tutorial setup

set -o errexit -o noclobber -o nounset
cd "$(dirname "$0")"

function waitForController() {
    while true; do
        STATUS=$(curl --request GET --url "${CONTROLLER_HOST}/status" 2>/dev/null | jq -r ".status")
        [[ "${STATUS}" == "online" ]] && break || echo "Waiting for Controller..."
        sleep 2
    done
}

function login() {
    echo -n "Logging in as user user@domain.com... "
    TOKEN=$(curl --request POST --url "${CONTROLLER_HOST}/user/login" \
                 --header 'Content-Type: application/json' \
                 --data '{"email":"user@domain.com","password":"#Bugs4Fun"}' 2>/dev/null \
            | jq -r '.accessToken')
    echo "${TOKEN}"
}

echo "Initializing tutorial. This may take a minute or two."

CONTROLLER_HOST="http://iofog-controller:51121/api/v3"
DEFAULT_FOG="Default Fog"
DEFAULT_FLOW="Default Flow"

waitForController
login
getDemoFogId
getDemoFlowId
startMicroserviceSensors
startMicroserviceApi
routeSensorsToApi
startMicroserviceFreeboard

echo "Successfully initialized tutorial."


echo 'Creating Sensor microservice'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/catalog/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"Sensors","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/sensors:latest","fogTypeId":1}]}' \
    2> /dev/null)
sensorsId=$(echo $item | jq -r .id)

echo 'Creating REST API microservice'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/catalog/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"Rest API","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/freeboard-api:latest","fogTypeId":1}]}' \
    2> /dev/null)
apiId=$(echo $item | jq -r .id)

echo 'Creating Freeboard microservice'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/catalog/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"freeboard","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/freeboard:latest","fogTypeId":1}]}' \
    2> /dev/null)
freeboardId=$(echo $item | jq -r .id)

#echo 'Creating Agent'
#item=$(curl --request POST \
#    --url $CONTROLLER_HOST/iofog \
#    --header "Authorization: $token" \
#    --header 'Content-Type: application/json' \
#    --data '{"name": "Agent 1","fogType": 1}' \
#    2> /dev/null)
#uuid1=$(echo $item | jq -r .uuid)
#
#item=$(curl --request POST \
#    --url $CONTROLLER_HOST/iofog \
#    --header "Authorization: $token" \
#    --header 'Content-Type: application/json' \
#    --data '{"name": "Agent 2","fogType": 1}' \
#    2> /dev/null)
#uuid2=$(echo $item | jq -r .uuid)

#echo 'Creating Flow'
#item=$(curl --request POST \
#    --url $CONTROLLER_HOST/flow \
#    --header "Authorization: $token" \
#    --header 'Content-Type: application/json' \
#    --data '{"name": "Flow","isActivated":true}' \
#    2> /dev/null)
#flowId=$(echo $item | jq -r .id)

echo 'Configuring microservices'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"API","config":"{}","catalogItemId":'"$apiId"',"flowId":'"$flowId"',"iofogUuid":"'"$uuid2"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[{"internal":80,"external":10101,"publicMode":false}],"routes":[]}' \
    2> /dev/null)
apiUUID=$(echo $item | jq -r .uuid)

echo 'Configuring Sensor microservice'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"Sensors","config":"{}","catalogItemId":'"$sensorsId"',"flowId":'"$flowId"',"iofogUuid":"'"$uuid1"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[],"routes":[]}' \
    2> /dev/null)
sensorsUUID=$(echo $item | jq -r .uuid)

echo 'Routing microservices'
item=$(curl -X POST \
    --url "$CONTROLLER_HOST/microservices/$sensorsUUID/routes/$apiUUID" \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    2> /dev/null)

echo 'Configuring Freeboard microservice'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"freeboard","config":"{}","catalogItemId":'"$freeboardId"',"flowId":'"$flowId"',"iofogUuid":"'"$uuid2"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[{"internal":80,"external":10102,"publicMode":false}],"routes":[]}' \
    2> /dev/null)
freeboardUUID=$(echo $item | jq -r .uuid)
