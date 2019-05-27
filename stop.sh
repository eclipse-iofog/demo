#!/bin/bash

set -o errexit -o pipefail -o noclobber -o nounset
cd "$(dirname "$0")"

# Import our helper functions
. ./utils.sh

printHelp() {
	echo "Usage:   ./stop.sh"
	echo "Stops ioFog environments and optionally sets up demo and tutorial environment"
	echo ""
	echo "Arguments:"
	echo "    -h, --help        print this help / usage"
}

stopEnvironment() {
    local ENVIRONMENT="$1"
    local COMPOSE_FILE="docker-compose-${ENVIRONMENT}.yml"

    # Spin up contianers for another environment
    echoInfo "Stopping containers from ${ENVIRONMENT} environment..."
    docker-compose -f "${COMPOSE_FILE}" down -v
}

! getopt -T
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echoError 'Your getopt version is insufficient!'
    exit 2
fi

! OPTIONS=$(getopt --options="h" --longoptions="help" --name "$0" -- $@)
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    printHelp
    exit 1
fi
eval set -- "$OPTIONS"

while [[ "$#" -ge 1 ]]; do
    case "$1" in
        -h|--help)
            printHelp
            exit 0
            ;;
        --)
            shift
            ;;
        *)
            echoError "Unrecognized argument!"
    esac
done

prettyHeader "Stopping ioFog Demo..."

# Stop tutorial application
#stopEnvironment "tutorial"

# Stop ioFog stack
stopEnvironment "iofog"

echoNotify "ioFog Demo is stopped"
