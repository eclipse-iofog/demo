#!/usr/bin/env sh
# test.sh - Run the iofog Test Runner suite against the Demo environment
#
# Usage: test.sh

set -e

# Import our helper functions
. ./utils.sh

prettyHeader "Running Test Runner Suite"

# Output the config for our Test suite config
echo 'iofog-connector:8080' > conf/connector.conf
echo 'iofog-controller:51121' > conf/controller.conf
echo 'root@iofog-agent' > conf/agents.conf

# Check to see if we are already running the Demo
NUM_CONTAINERS=$(docker-compose ps | grep iofog | grep Up | wc -l | awk '{print $1}')

if [ "$NUM_CONTAINERS" -eq "3" ]; then
    echoInfo "Demo compose environment is already running"
else
    echoInfo "Spinning up Demo compose environment"
    docker-compose -f docker-compose.yml up
fi

echoInfo "Pulling Test Runner Image"
docker-compose -f docker-compose-test.yml pull test-runner

echoInfo "Running Test Runner suite"
docker-compose -f docker-compose-test.yml up \
    --build \
    --abort-on-container-exit \
    --exit-code-from test-runner \
    --force-recreate \
    --renew-anon-volumes

echoNotify "## Test Runner Tests complete"