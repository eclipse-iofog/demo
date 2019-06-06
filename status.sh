#!/usr/bin/env sh
#
# status.sh - Print the status of the Demo cluster and it's components
#
# Usage: ./status.sh
#

set -e

# Import our helper functions
. ./utils.sh

# Display the running environment
prettyTitle "ioFog Demo Environment Status"
echoInfo "  $(docker ps)"
echo
echoSuccess "## iofog-controller is running at http://localhost:$(docker port iofog-controller | awk '{print $1}' | cut -b 1-5)"
