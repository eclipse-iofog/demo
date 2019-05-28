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

# Stop ioFog stack
echoInfo "Stopping all containers..."
docker-compose -f "docker-compose-iofog.yml" -f "docker-compose-tutorial.yml" down -v

# TODO stopping the ioFog stack leaves its microservices running - fix this properly
docker ps -q --filter 'name=iofog*' | xargs --no-run-if-empty docker rm -f

echoNotify "ioFog Demo is stopped"
