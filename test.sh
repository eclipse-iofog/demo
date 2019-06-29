#!/usr/bin/env bash
#
# test.sh - will pull and run the TestRunner suite against an already Demo compose cluster.
#
# Usage : ./test.sh -h
#

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

echoInfo "Running Test Runner..."
docker run --rm --name test-runner --network bridge \
    -v ~/edgeworx/demo/test/conf/id_ecdsa:/root/.ssh/id_ecdsa \
    -e CONTROLLER="${CONTROLLER_IP}:51121" \
    -e CONNECTOR="${CONNECTOR_IP}:8080" \
    -e AGENTS="root@${AGENT_IP}:22" \
    iofog/test-runner:1.1.0

echoNotify "## Test Runner Tests complete"
