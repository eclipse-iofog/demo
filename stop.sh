#!/usr/bin/env sh
# stop.sh - shut down the Demo docker-compose environment
#
# Usage: stop.sh

set -e

# Import our helper functions
. ./utils.sh

prettyHeader "Spinning down ioFog Demo environment"
docker-compose down -v

prettyTitle "ioFog demo is stopped"