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

while [[ "$#" -ge 1 ]]; do
    case "$1" in
        -h|--help)
            printHelp
            exit 0
            ;;
        *)
            echoError "Unrecognized argument: \"$1\""
            printHelp
            exit 1
            ;;
    esac
done

prettyHeader "Stopping ioFog Demo..."

# Stop ioFog stack
echoInfo "Stopping all containers..."
docker-compose -f "docker-compose-iofog.yml" -f "docker-compose-tutorial.yml" down -v

# TODO stopping the ioFog stack leaves its microservices running - fix this properly
REMAINING_MSVC=`docker ps -q --filter 'name=iofog*'`

if [ ! -z "${REMAINING_MSVC}" ]; then
    docker rm -f ${REMAINING_MSVC}
fi

# Remove generated files
find test/conf -type f -not -name ".gitignore" -exec rm -f {} \;
rm -f "services/iofog/iofog-agent/id_ecdsa.pub"

prettyTitle "ioFog demo is stopped"
