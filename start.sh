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

! getopt -T
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echoError 'Your getopts version is insufficient!'
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

if [[ "${ENVIRONMENT}" != "iofog" ]]; then
    COMPOSE_SERVICES_FILE="docker-compose-${ENVIRONMENT}.yml"
    COMPOSE_INIT_FILE="docker-compose-${ENVIRONMENT}-init.yml"
    if [[ ! -f "${COMPOSE_SERVICES_FILE}" ]] || [[ ! -f "${COMPOSE_INIT_FILE}" ]]; then
        echoError "Environment configuration for \"${ENVIRONMENT}\" does not exist!"
        exit 2
    fi
fi

# Create a new ssh key and copy it into Agent
echoInfo "Adding new ssh key pair to Agent..."
rm -f init/iofog/id_ecdsa*
ssh-keygen -t ecdsa -N "" -f init/iofog/id_ecdsa -q
cp init/iofog/id_ecdsa.pub iofog-agent

# Spin up contianers for iofog environment
echoInfo "Spinning up containers for ioFog environment..."
echo docker-compose -f "docker-compose-iofog.yml" up --build --detach

# Initialize iofog environment
echoInfo "Initializing ioFog environment..."
echo docker-compose -f "docker-compose-iofog-init.yml" run --build

# Optionally add another environment
if [[ "${ENVIRONMENT}" != "iofog" ]]; then
    # Spin up contianers for another environment
    echoInfo "Spinning up containers for ${ENVIRONMENT} environment..."
    echo docker-compose -f "${COMPOSE_SERVICES_FILE}" up --build --detach

    # Initialize iofog environment
    echoInfo "Initializing ${ENVIRONMENT} environment..."
    echo docker-compose -f "${COMPOSE_INIT_FILE}" run --build
fi

# Display the running environment
docker ps
echoNotify "ioFog Demo is now running"
