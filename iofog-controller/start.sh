#!/usr/bin/env sh

cd /src
export NODE_ENV=development

CONTROLLER_HOST="http://localhost:51121/api/v3"

node src/main start
if [ -f /first_run.tmp ]; then
    # create new user
    node src/main user add -f John -l Doe -e user@domain.com -p "#Bugs4Fun"
    # add connector
    connector_ip=$(getent hosts iofog-connector | awk '{ print $1 }')
    node src/main connector add -n iofog-connector -d http://iofog-connector -i $connector_ip -H

    login=$(curl --request POST \
        --url $CONTROLLER_HOST/user/login \
        --header 'Content-Type: application/json' \
        --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
    token=$(echo $login | jq -r .accessToken)

    curl --request POST \
        --url $CONTROLLER_HOST/catalog/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"Sensors","category": "DEMO","publisher":"Saeid","registryId":1,"images":[{"containerImage":"baghbidi/public:sensors","fogTypeId":1}]}'

    curl --request POST \
        --url $CONTROLLER_HOST/catalog/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"Rest API","category": "DEMO","publisher":"Saeid","registryId":1,"images":[{"containerImage":"baghbidi/public:freeboard-api","fogTypeId":1}]}'

    curl --request POST \
        --url $CONTROLLER_HOST/catalog/microservices \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name":"freeboard","category": "DEMO","publisher":"Saeid","registryId":1,"images":[{"containerImage":"baghbidi/public:freeboard","fogTypeId":1}]}'

    rm /first_run.tmp
fi
tail -f /dev/null