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


# Wait until Controller has come up
for HOST in http://iofog-controller:51121 http://iofog-connector:8080 http://iofog-agent:54321 ; do
  waitFor "$HOST"
done

echo "Beginning Test Runner Smoke tests.."
python --version
pyresttest http:// tests/demo-test-suite.yml

echo "Test Runner Smoke tests Complete"