#!/bin/bash

set -o errexit -o pipefail -o noclobber -o nounset
cd "$(dirname "$0")"

# Import our helper functions
. ./utils.sh

printHelp() {
	echo "Usage:   ./start.sh [environment]"
	echo "Starts ioFog environments and optionally sets up demo and tutorial environment"
	echo ""
	echo "Arguments:"
	echo "    -h, --help        print this help / usage"
	echo "    [environment]     setup demo application, optional, default: iofog"
	echo "                      supported values: iofog, tutorial"
}

checkComposeFile() {
    local ENVIRONMENT="$1"
    local COMPOSE_FILE="docker-compose-${ENVIRONMENT}.yml"
    if [[ ! -f "${COMPOSE_FILE}" ]]; then
        echoError "Environment configuration for \"${ENVIRONMENT}\" does not exist!"
        exit 2
    fi
}

startEnvironment() {
    local ENVIRONMENT="$1"
    local COMPOSE_FILE="docker-compose-${ENVIRONMENT}.yml"

    # Spin up contianers for another environment
    echoInfo "Spinning up containers for ${ENVIRONMENT} environment..."
    docker-compose -f "${COMPOSE_FILE}" up --detach
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

ENVIRONMENT=''
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
            if [[ -n "${ENVIRONMENT}" ]]; then
                echoError "Cannot specify more than one environment!"
                printHelp
                exit1
            fi
            ENVIRONMENT=$1
            shift
            ;;
    esac
done
ENVIRONMENT=${ENVIRONMENT:="iofog"} # by default, setup only the ioFog stack

prettyHeader "Starting ioFog Demo (\"${ENVIRONMENT}\" environment)..."

checkComposeFile "iofog"
if [[ "${ENVIRONMENT}" != "iofog" ]]; then checkComposeFile "${ENVIRONMENT}"; fi

# Create a new ssh key
echoInfo "Adding new ssh key pair to Agent..."
rm -f services/iofog/iofog-agent/id_ecdsa*
ssh-keygen -t ecdsa -N "" -f services/iofog/iofog-agent/id_ecdsa -q

# Start ioFog stack
startEnvironment "iofog"
# Optionally start another environment
if [[ "${ENVIRONMENT}" != "iofog" ]]; then startEnvironment "${ENVIRONMENT}"; fi

# Display the running environment
docker ps
echoNotify "ioFog Demo is now running"
