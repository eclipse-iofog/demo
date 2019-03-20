#!/usr/bin/env bash

# Our test suite config
CONTROLLER_HOST="http://iofog-controller:51121"
CONNECTOR_HOST="http://iofog-connector:8080"
TEST_SUITE="tests/demo-test-suite.yml"

#
# Wait until we can connect to a url given in $1
#
function waitFor() {

    # Can we connect?
    until $(curl --output /dev/null --silent --head --connect-to --url ${1}); do
      printf '.'
      sleep 2
    done
}


# Wait until Controller has come up
echo "Waiting for Controller to start"
waitFor ${CONTROLLER_HOST}

echo "Beginning Test Runner Smoke tests.."
python --version
pyresttest ${CONTROLLER_HOST} tests/demo-test-suite.yml

echo "Test Runner Smoke tests Complete"

