#!/usr/bin/env bash

#
# Wait until we can connect to a url given in $1
#
function waitFor() {
    echo "Waiting for $1"
    until $(curl --output /dev/null --silent --head --connect-to --url ${1}); do
      sleep 2
    done
    echo "$1 is up"
}

#
# Read all agents from config file
#
function importAgents() {
    AGENTS=()
    while IFS= read -r HOST
    do
        AGENTS+="$HOST"
    done < conf/agents.conf
}

# Read Controller, Connector, and Agents from config files
CONTROLLER=$(cat conf/controller.conf | tr -d '\n')
CONNECTOR=$(cat conf/connector.conf | tr -d '\n')
importAgents
echo "---------- CONFIGURATION ----------
[CONTROLLER]
$CONTROLLER

[CONNECTOR]
$CONNECTOR

[AGENTS]
${AGENTS[@]}
---------- ------------- ----------"

# Wait until Controller has come up
for HOST in http://"$CONTROLLER" http://"$CONNECTOR"; do
  waitFor "$HOST"
done

echo "Beginning Smoke Tests.."
pyresttest http://"$CONTROLLER" tests/smoke/controller.yml
pyresttest http://"$CONNECTOR" tests/smoke/connector.yml

echo "Test Runner Smoke tests Complete"

echo "Beginning Integration Tests"
