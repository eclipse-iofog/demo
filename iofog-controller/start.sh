#!/usr/bin/env sh

export NODE_ENV=development

CONTROLLER_HOST="http://localhost:51121/api/v3"

cd /usr/local/lib/node_modules/iofogcontroller/src/sequelize
if [ ! -f ./dev_database.sqlite ]; then
    sh ./rebuild_dev_db.sh
fi

iofog-controller start
if [ -f /first_run.tmp ]; then
    iofog-controller user add -f John -l Doe -e user@domain.com -p "#Bugs4Fun"

    connector_ip=$(getent hosts iofog-connector | awk '{ print $1 }')
    iofog-controller connector add -n iofog-connector -d $connector_ip -i $connector_ip -H

    login=$(curl --request POST \
        --url $CONTROLLER_HOST/user/login \
        --header 'Content-Type: application/json' \
        --data '{"email":"user@domain.com","password":"#Bugs4Fun"}')
    token=$(echo $login | jq -r .accessToken)

    item=$(curl --request POST \
        --url $CONTROLLER_HOST/iofog \
        --header "Authorization: $token" \
        --header 'Content-Type: application/json' \
        --data '{"name": "ioFog Node","fogType": 1}')

    rm /first_run.tmp
fi
tail -f /dev/null