#!/usr/bin/env bash
#
# start.sh - is the main start script for our Demo cluster. Running it will launch a docker-compose environment
# that contains a fully connected ioFog ECN. Optionally, you can launch a different compose, e.g. tutorial.
#
# Usage : ./start.sh -h
#

set -o errexit -o pipefail -o noclobber -o nounset

cd "$(dirname "$0")"

# Import our helper functions
. ./utils.sh

printHelp() {
	echo "Usage:   ./start.sh [opts] [environment]"
	echo "Starts ioFog environments and optionally sets up demo and tutorial environment"
	echo ""
	echo "Options:"
	echo "    -h, --help        print this help / usage"
	echo "    -a, --agent       specify a local agent image"
	echo "    -ct, --controller specify a local controller image"
    echo ""
    echo "Arguments:"
	echo "    [environment]     setup demo application, optional, default: iofog"
	echo "                      supported values: iofog, tutorial"
}

startIofog() {
    # If stack is running, skip
    local CONTROLLER_CONTAINER_ID=$(docker ps -q --filter="name=iofog-controller")
    if ! [[ -z "${CONTROLLER_CONTAINER_ID}"  ]]; then
        return
    fi

    echo "---
apiVersion: iofog.org/v2
kind: LocalControlPlane
metadata:
  name: local-ecn
spec:
  iofogUser:
    name: test
    surname: local
    email: user@domain.com
    password: '#Bugs4Fun'
  controllers:	
  - name: local-controller
    host: localhost
    container:
      image: $CONTROLLER_IMAGE
---
apiVersion: iofog.org/v2
kind: LocalAgent
metadata:
  name: local-agent
spec:
  host: localhost
  container:
    image: $AGENT_IMAGE
" >| init/iofog/local-stack.yaml

    echoInfo "Deploying containers for ioFog stack..."
    iofogctl deploy -f init/iofog/local-stack.yaml -v
}

checkProvisioning() {
    AGENT_UUID=$(docker exec iofog-agent iofog-agent info | grep 'UUID' | awk '{print $4}')

    if [ "$AGENT_UUID" == "not" ]; then
        echoError "Failed to provision the agent"
        return 1
    fi
}

startEnvironment() {
    local ENVIRONMENT="$1"

    echoInfo "Deploying ${ENVIRONMENT} application..."
    iofogctl deploy application -f "init/${ENVIRONMENT}/config.yaml" -v
    echoInfo "It may take a while before ioFog stack creates all ${ENVIRONMENT} microservices."
    echo ""
}

ENVIRONMENT=''
IOFOG_BUILD_NO_CACHE=''
AGENT_IMAGE='docker.io/iofog/agent:2.0.0-rc2'
CONTROLLER_IMAGE='docker.io/iofog/controller:2.0.0-rc2'
while [[ "$#" -ge 1 ]]; do
    case "$1" in
        -h|--help)
            printHelp
            exit 0
            ;;
        -a|--agent)
            AGENT_IMAGE=${2:-$AGENT_IMAGE}
            shift
            shift
            ;;
        -ct|--controller)
            CONTROLLER_IMAGE=${2:-$CONTROLLER_IMAGE}
            shift
            shift
            ;;
        *)
            if [[ -n "${ENVIRONMENT}" ]]; then
                echoError "Cannot specify more than one environment!"
                printHelp
                exit 1
            fi
            ENVIRONMENT=$1
            shift
            ;;
    esac
done

prettyHeader "Starting ioFog Demo"

# Figure out which environment we are going to be starting. By default, setup only the ioFog stack
ENVIRONMENT=${ENVIRONMENT:="iofog"}

echoInfo "Starting \"${ENVIRONMENT}\" demo environment..."

# Start ioFog stack
startIofog
checkProvisioning

# Optionally start another environment
if [[ "${ENVIRONMENT}" != "iofog" ]]; then
    # TODO check if this environment is up or not
    startEnvironment "${ENVIRONMENT}";
fi

# Display the running environment
./status.sh

if [[ "${ENVIRONMENT}" == "tutorial" ]]; then
    echoSuccess "## Visit https://iofog.org/docs/2.0.0/tutorial/introduction.html to continue with the ioFog tutorial."
fi
