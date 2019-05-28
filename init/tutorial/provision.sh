#!/usr/bin/env sh

# TODO finish tutorial setup
# TODO split --data into multiple lines

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

function getDemoFogId() {
    echo -n "Looking up default fog... "
    FOG_ID=$(curl --request GET --url "${CONTROLLER_HOST}/iofog-list" \
                  --header "Authorization: ${TOKEN}" \
                  --header 'Content-Type: application/json' 2>/dev/null \
             | jq -r ".fogs[] | select(.name == \"${DEFAULT_FOG}\") | .uuid")
    echo "${FOG_ID}"
}

function getDemoFlowId() {
    echo -n "Looking up default flow... "
    FLOW_ID=$(curl --request GET --url "${CONTROLLER_HOST}/flow" \
                              --header "Authorization: ${TOKEN}" \
                              --header 'Content-Type: application/json' 2>/dev/null \
                         | jq -r ".flows[] | select(.name == \"${DEFAULT_FLOW}\") | .id")
    echo "${FLOW_ID}"
}

function startMicroserviceSensors() {
    echo -n 'Registering Sensor microservice in the catalog... '
    SENSORS_CATALOG_ID=$(curl --request POST --url $CONTROLLER_HOST/catalog/microservices \
                              --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' \
                              --data '{"name":"Sensors","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/sensors:latest","fogTypeId":1}]}' \
                         2> /dev/null | jq -r .id)
    echo "${SENSORS_CATALOG_ID}"

    echo -n 'Creating Sensor microservice... '
    SENSORS_UUID=$(curl --request POST --url $CONTROLLER_HOST/microservices \
                        --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' \
                        --data '{"name":"Sensors","config":"{}","catalogItemId":'"${SENSORS_CATALOG_ID}"',"flowId":'"${FLOW_ID}"',"iofogUuid":"'"${FOG_ID}"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[],"routes":[]}' \
                   2> /dev/null | jq -r .uuid)
    echo "${SENSORS_UUID}"
}

function startMicroserviceRestApi() {
    echo -n 'Registering REST API microservice in the catalog... '
    RESTAPI_CATALOG_ID=$(curl --request POST --url $CONTROLLER_HOST/catalog/microservices \
                              --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' \
                              --data '{"name":"Rest API","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/freeboard-api:latest","fogTypeId":1}]}' \
                         2> /dev/null | jq -r .id)
    echo "${RESTAPI_CATALOG_ID}"

    echo -n 'Creating REST API microservice... '
    RESTAPI_UUID=$(curl --request POST --url $CONTROLLER_HOST/microservices \
                        --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' \
                        --data '{"name":"Rest API","config":"{}","catalogItemId":'"${RESTAPI_CATALOG_ID}"',"flowId":'"${FLOW_ID}"',"iofogUuid":"'"${FOG_ID}"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[{"internal":80,"external":10101,"publicMode":false}],"routes":[]}' \
                   2> /dev/null | jq -r .uuid)
    echo "${RESTAPI_UUID}"
}

function startMicroserviceFreeboard() {
    echo -n 'Registering Freeboard microservice in the catalog... '
    FREEBOARD_CATALOG_ID=$(curl --request POST --url $CONTROLLER_HOST/catalog/microservices \
                                --header "Authorization: ${TOKEN}"  --header 'Content-Type: application/json' \
                                --data '{"name":"freeboard","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/freeboard:latest","fogTypeId":1}]}' \
                           2> /dev/null | jq -r .id)
    echo "${FREEBOARD_CATALOG_ID}"

    echo -n 'Configuring Freeboard microservice'
    FREEBOARD_UUID=$(curl --request POST --url $CONTROLLER_HOST/microservices \
                          --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' \
                          --data '{"name":"Freeboard","config":"{}","catalogItemId":'"${FREEBOARD_CATALOG_ID}"',"flowId":'"${FLOW_ID}"',"iofogUuid":"'"${FOG_ID}"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[{"internal":80,"external":10102,"publicMode":false}],"routes":[]}' \
        2> /dev/null | jq -r .uuid)
    echo "${FREEBOARD_UUID}"
}

function routeSensorsToApi() {
    echo 'Creating route between Sensors and REST API microservices...'
    curl --request POST --url "$CONTROLLER_HOST/microservices/${SENSORS_UUID}/routes/${RESTAPI_UUID}" \
         --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' 2> /dev/null
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
startMicroserviceRestApi
routeSensorsToApi
startMicroserviceFreeboard

echo "Successfully initialized tutorial."




