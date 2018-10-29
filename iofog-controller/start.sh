#!/usr/bin/env sh

cd /src
export NODE_ENV=development

node src/main start
if [ -f /first_run.tmp ]; then
    node src/main user add -f John -l Doe -e user@domain.com -p "#Bugs4Fun"

    connector_ip=$(getent hosts iofog-connector | awk '{ print $1 }')
    node src/main connector add -n iofog-connector -d $connector_ip -i $connector_ip -H

    rm /first_run.tmp
fi
tail -f /dev/null