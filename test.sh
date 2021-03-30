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
IOFOG_RUNNING=$(docker inspect -f '{{.State.Running}}' iofog-agent iofog-controller | tr -d "[:space:]")
if [[ "${IOFOG_RUNNING}" == "truetrue" ]]; then
    echoInfo "ioFog stack is running"
else
    echoError 'ioFog stack is not running! Please run `./start.sh` first'
    exit 2
fi

echoInfo "Running Test Runner..."
# Testing local agent, need mounted docker socket to sue legacy agent commands
docker run --rm --name test-runner --network host \
    -v ~/.iofog/:/root/.iofog/ \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gcr.io/focal-freedom-236620/test-runner:3.0.0-dev

echoNotify "## Test Runner Tests complete"
