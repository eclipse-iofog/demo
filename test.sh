#!/bin/bash

set -o errexit -o pipefail -o noclobber -o nounset
cd "$(dirname "$0")"

# Import our helper functions
. ./utils.sh

printHelp() {
	echo "Usage:   ./test.sh"
	echo "Tests ioFog environment"
	echo ""
	echo "Arguments:"
	echo "    -h, --help        print this help / usage"
}

if [[ $# -gt 0 ]]; then
    printHelp
    exit 1
fi

prettyHeader "Running Test Runner Suite"

# Check to see if we are already running the Demo
IOFOG_RUNNING=$(docker inspect -f '{{.State.Running}}' iofog-agent iofog-connector iofog-controller | tr -d "[:space:]")
if [[ "${IOFOG_RUNNING}" == "truetruetrue" ]]; then
    echoInfo "ioFog stack is running"
else
    echoError 'ioFog stack is not running! Please run `./start.sh iofog` first'
    exit 2
fi

echoInfo "Retrieving endpoints for ioFog stack"
AGENT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iofog-agent)
CONTROLLER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iofog-controller)
CONNECTOR_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iofog-connector)
# Output the config for our Test suite config
echo "${CONNECTOR_IP}:8080" >| test/conf/connector.conf
echo "${CONTROLLER_IP}:51121" >| test/conf/controller.conf
echo "root@${AGENT_IP}" >| test/conf/agents.conf

echoInfo "Pulling Test Runner Image"
docker-compose -f docker-compose-test.yml pull test-runner

echoInfo "Running Test Runner suite"
docker-compose -f docker-compose-test.yml up \
    --build \
    --abort-on-container-exit \
    --exit-code-from test-runner \
    --force-recreate \
    --renew-anon-volumes

echoNotify "Test Runner Tests complete"
