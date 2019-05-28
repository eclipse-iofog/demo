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

startIofog() {
    # Spin up containers for another environment
    echoInfo "Spinning up containers for iofog stack..."
    docker-compose -f "docker-compose-iofog.yml" up --detach --build

    echoInfo "Initializing iofog stack..."
    docker logs -f "iofog-init" # wait for the ioFog stack initialization
    RET=$(docker wait "iofog-init")
    if [[ "$RET" != "0" ]]; then
        echoError "Failed to initialize iofog stack!"
        exit 3
    fi
    echoInfo "Successfully initialized iofog stack."
}

startEnvironment() {
    local ENVIRONMENT="$1"
    local COMPOSE_PARAM="-f docker-compose-${ENVIRONMENT}.yml"

    # Spin up containers for another environment
    echoInfo "Spinning up containers for ${ENVIRONMENT} environment..."
    docker-compose -f "docker-compose-iofog.yml" -f "docker-compose-${ENVIRONMENT}.yml" \
        build "${ENVIRONMENT}-init"
    docker-compose -f "docker-compose-iofog.yml" -f "docker-compose-${ENVIRONMENT}.yml" \
        up --detach --no-recreate "${ENVIRONMENT}-init"

    echoInfo "Initializing ${ENVIRONMENT} environment..."
    docker logs -f "${ENVIRONMENT}-init" # wait for the ioFog stack initialization
    RET=$(docker wait "${ENVIRONMENT}-init")
    if [[ "$RET" != "0" ]]; then
        echoError "Failed to initialize ${ENVIRONMENT} environment!"
        exit 3
    fi
    echoInfo "Successfully setup ${ENVIRONMENT} environment."
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
eval set -- "${OPTIONS}"

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
echoInfo "Creating new ssh key for tests..."
rm -f test/conf/id_ecdsa*
ssh-keygen -t ecdsa -N "" -f test/conf/id_ecdsa -q
cp -f test/conf/id_ecdsa.pub services/iofog/iofog-agent/

# Start ioFog stack
# TODO check if this environment is up or not
startIofog

# Optionally start another environment
if [[ "${ENVIRONMENT}" != "iofog" ]]; then
    # TODO check if this environment is up or not
    startEnvironment "${ENVIRONMENT}";
fi

# Display the running environment
docker ps
echoNotify "ioFog Demo is now running"
