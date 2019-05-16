#!/usr/bin/env sh

set -e

CONTROLLER_HOST="http://iofog-controller:51121/api/v3"

echo 'Creating user'
docker exec iofog-controller sh -c "iofog-controller user add -f John -l Doe -e user@domain.com -p '#Bugs4Fun'" > /dev/null 2>&1

connector_ip=$(getent hosts iofog-connector | awk '{ print $1 }')
echo "Adding Connector: $connector_ip"
docker exec iofog-controller sh -c "iofog-controller connector add -n iofog-connector -d $connector_ip -i $connector_ip -H"

echo 'Waiting for Connector'
while true; do
    item=$(curl --request POST \
        --url http://iofog-connector:8080/api/v2/status \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --data mappingid=all)
    echo "$item"
    status=$(echo "$item" | jq -r .status)

    if [ "$status" = "running" ]; then
        break
    fi
    sleep .5
done

echo 'Logging in'
login=$(curl --request POST \
    --url $CONTROLLER_HOST/user/login \
    --header 'Content-Type: application/json' \
    --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
token=$(echo $login | jq -r .accessToken)

echo 'Creating Sensor microservice'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/catalog/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"Sensors","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/sensors:latest","fogTypeId":1}]}')
sensorsId=$(echo $item | jq -r .id)

echo 'Creating REST API microservice'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/catalog/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"Rest API","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/freeboard-api:latest","fogTypeId":1}]}')
apiId=$(echo $item | jq -r .id)

echo 'Creating Freeboard microservice'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/catalog/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"freeboard","category": "DEMO","publisher":"Edgeworx","registryId":1,"images":[{"containerImage":"iofog/freeboard:latest","fogTypeId":1}]}')
freeboardId=$(echo $item | jq -r .id)

echo 'Creating Agent'
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

echo 'Creating Flow'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/flow \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name": "Flow","isActivated":true}')
flowId=$(echo $item | jq -r .id)

echo 'Configuring microservices'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"API","config":"{}","catalogItemId":'"$apiId"',"flowId":'"$flowId"',"iofogUuid":"'"$uuid2"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[{"internal":80,"external":10101,"publicMode":false}],"routes":[]}')
apiUUID=$(echo $item | jq -r .uuid)

echo 'Configuring Sensor microservice'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"Sensors","config":"{}","catalogItemId":'"$sensorsId"',"flowId":'"$flowId"',"iofogUuid":"'"$uuid1"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[],"routes":[]}') \
sensorsUUID=$(echo $item | jq -r .uuid)

echo 'Routing microservices'
item=$(curl -X POST \
    --url "$CONTROLLER_HOST/microservices/$sensorsUUID/routes/$apiUUID" \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json')

echo 'Configuring Freeboard microservice'
item=$(curl --request POST \
    --url $CONTROLLER_HOST/microservices \
    --header "Authorization: $token" \
    --header 'Content-Type: application/json' \
    --data '{"name":"freeboard","config":"{}","catalogItemId":'"$freeboardId"',"flowId":'"$flowId"',"iofogUuid":"'"$uuid2"'","rootHostAccess":false,"logSize":5,"volumeMappings":[],"ports":[{"internal":80,"external":10102,"publicMode":false}],"routes":[]}')
freeboardUUID=$(echo $item | jq -r .uuid)