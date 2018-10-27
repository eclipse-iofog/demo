#!/usr/bin/env sh

cd /src
export NODE_ENV=development

node src/main start
if [ -f /first_run.tmp ]; then
    curl --request POST \
        --url http://localhost:51121/api/v3/user/signup \
        --header 'Content-Type: application/json' \
        --data '{"firstName":"John","lastName":"Doe","email":"user@domain.com","password":"#Bugs4Fun"}'
    node src/main connector add -n iofog-connector -d http://iofog-connector -i 11.0.0.3 -H
    rm /first_run.tmp
fi
tail -f /dev/null