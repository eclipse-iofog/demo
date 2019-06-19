#!/usr/bin/env bash
#
# status.sh - Print the status of the Demo cluster and its components
#
# Usage: ./status.sh
#

set -e
cd "$(dirname "$0")"

# Import our helper functions
. ./utils.sh

# Display the running environment
prettyTitle "ioFog Demo Environment Status"
echoInfo "  $(docker ps --filter 'name=iofog')"
echo

CONTROLLER_PORT="$(docker port iofog-controller | awk '{print $1}' | cut -b 1-5)"

if [ ! -z ${CONTROLLER_PORT} ]; then
    echoSuccess "## iofog-controller is running at http://localhost:${CONTROLLER_PORT}"
else
    echoError "No iofog-controller container was found"
fi
