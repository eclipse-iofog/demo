#!/usr/bin/env sh

set -o errexit -o noclobber -o nounset
cd "$(dirname "$0")"

function waitForController() {
    while true; do
        STATUS=$(curl --request GET --url "${CONTROLLER_HOST}/status" 2>/dev/null | jq -r ".status")
        [[ "${STATUS}" == "online" ]] && break || echo "Waiting for Controller..."
        sleep 2
    done
}

function waitForAgent() {
    while true; do
        STATUS=$(docker exec iofog-agent iofog-agent status | awk -F': ' '/ioFog daemon/{print $2}')
        [[ "${STATUS}" == "RUNNING" ]] && break || echo "Waiting for Agent..."
        sleep 2
    done
}

function waitForConnector() {
    while true; do
        STATUS=$(curl --request POST --url "${CONNECTOR_HOST}/status" \
                      --header 'Content-Type: application/x-www-form-urlencoded' --data mappingid=all 2>/dev/null \
                 | jq -r '.status')
        [[ "${STATUS}" == "running" ]] && break || echo "Waiting for Connector..."
        sleep 2
    done
}

function createUser() {
    echo -n "Creating user John Doe... "
    local RET=$(curl --request POST --url "${CONTROLLER_HOST}/user/signup" \
                     --header 'Content-Type: application/json' \
                     --data '{"email":"user@domain.com","firstName":"John","lastName":"Doe","password":"#Bugs4Fun"}' \
                     2>/dev/null)
    local RET_MSG=$(echo $RET | jq -r '.message')
    local RET_UID=$(echo $RET | jq -r '.userId')
    [[ "${RET_MSG}" == "null" ]] && echo "${RET_UID}" || echo "${RET_MSG}"
}

function login() {
    echo -n "Logging in as user user@domain.com... "
    TOKEN=$(curl --request POST --url "${CONTROLLER_HOST}/user/login" \
                 --header 'Content-Type: application/json' \
                 --data '{"email":"user@domain.com","password":"#Bugs4Fun"}' 2>/dev/null \
            | jq -r '.accessToken')
    echo "${TOKEN}"
}

function createDefaultFog() {
    # Delete all fogs with the same default fog name. This is in case the script is run repeatedly.
    local DEFAULT_FOGS=$(curl --request GET --url "${CONTROLLER_HOST}/iofog-list" \
                              --header "Authorization: ${TOKEN}" \
                              --header 'Content-Type: application/json' 2>/dev/null \
                         | jq -r ".fogs[] | select(.name == \"${DEFAULT_FOG}\") | .uuid")
    for FOG_UUID in ${DEFAULT_FOGS}; do
        echo "Deleting pre-existing default fog: ${FOG_UUID}..."
        curl --request DELETE --url "${CONTROLLER_HOST}/iofog/${FOG_UUID}" \
             --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' 2>/dev/null
    done

    # Wait for all the deleted fogs to be actually delete.
    while true; do
        DEFAULT_FOGS=$(curl --request GET --url "${CONTROLLER_HOST}/iofog-list" \
                            --header "Authorization: ${TOKEN}" \
                            --header 'Content-Type: application/json' 2>/dev/null \
                       | jq -r ".fogs[] | select(.name == \"${DEFAULT_FOG}\") | .uuid")
        [[ -z "${DEFAULT_FOGS}" ]] && break || echo "Waiting for pre-existing default fogs to be deleted..."
        sleep 2
    done

    echo -n "Creating default fog... "
    curl --request POST --url "${CONTROLLER_HOST}/iofog" \
         --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' \
         --data "{\"name\": \"${DEFAULT_FOG}\",\"fogType\": 1}" 2> /dev/null 1>&2
    echo "${DEFAULT_FOG}"

    echo -n 'Retrieving UUID of default fog... '
    FOG_UUID=$(curl --request GET --url "${CONTROLLER_HOST}/iofog-list" \
                --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' 2> /dev/null \
                | jq -r ".fogs[] | select(.name == \"${DEFAULT_FOG}\") | .uuid")
    echo "${FOG_UUID}"
}

function configureAgent() {
    echo "Configuring Agent..."
    docker exec iofog-agent iofog-agent config -idc off > /dev/null
    docker exec iofog-agent iofog-agent config -a "${CONTROLLER_HOST}" > /dev/null
}

function configureController() {
    echo "Configuring Controller..."
    CONNECTOR_IP=$(getent hosts iofog-connector | awk '{ print $1 }')
    # TODO this is the only "docker exec" for controller - needs to be replaced with REST API
    docker exec iofog-controller \
        iofog-controller connector add -n iofog-connector -d "${CONNECTOR_IP}" -i "${CONNECTOR_IP}" -H
}

function provisionAgent() {
    echo -n "Retrieving provisioning key for default fog... "
    PROVISION_KEY=$(curl --request GET --url "${CONTROLLER_HOST}/iofog/${FOG_UUID}/provisioning-key" \
                         --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' 2> /dev/null \
                         | jq -r .key)
    echo "${PROVISION_KEY}"

    docker exec iofog-agent iofog-agent provision "${PROVISION_KEY}"
}

function createDefaultFlow() {
    echo -n "Creating default flow... "
    curl --request POST --url "${CONTROLLER_HOST}/flow" \
         --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' \
         --data "{\"name\": \"${DEFAULT_FLOW}\",\"isActivated\":true}" 2> /dev/null 1>&2

    # Retrieve just created flow's id
    FLOW_ID=$(curl --request GET --url "${CONTROLLER_HOST}/flow" \
             --header "Authorization: ${TOKEN}" --header 'Content-Type: application/json' 2> /dev/null \
             | jq -r ".flows[] | select(.name == \"${DEFAULT_FLOW}\") | .id")
    echo "${FLOW_ID}"
}

echo "Initializing ioFog stack. This may take a minute or two."

docker --version # Check if docker is available. Needs docker socket mapped in order to talk to the Agent
CONTROLLER_HOST="http://iofog-controller:51121/api/v3"
CONNECTOR_HOST="http://iofog-connector:8080/api/v2"
DEFAULT_FOG="Default Fog"
DEFAULT_FLOW="Default Flow"

waitForConnector
waitForController
waitForAgent
configureController
createUser
login
createDefaultFog
configureAgent
provisionAgent
createDefaultFlow

echo "Successfully initialized ioFog stack."
