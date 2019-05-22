#!/usr/bin/env sh
# stop.sh - shut down the Demo docker-compose environment
#
# Usage: stop.sh

set -e

# Import our helper functions
. ./utils.sh

prettyHeader "Spinning down iofog Demo environment"
docker-compose down -v

echoInfo "ioFog demo is stopped"