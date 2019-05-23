#!/bin/bash

set -e

# Import our helper functions
. ./utils.sh

prettyHeader "Starting ioFog Demo environment"

ENV='blank'
if [ ! -z "$1" ]; then
    if [[ "$1" == *help* ]]; then
        echo 'Usage:                ./start.sh [Environment]'
        echo 'Arguments:            Environment - Compose environment to start. Optional. Defalut is "demo"'
        exit 0
    fi
    ENV="$1"
fi

echo "Starting up $ENV environment"

# Clean up any artifacts from a previous run
rm conf/id_ecdsa* || true

# Create a new ssh key and copy it into Agent
echoInfo "Adding new ssh key pair to Agent"
ssh-keygen -t ecdsa -N "" -f conf/id_ecdsa -q
cp conf/id_ecdsa.pub iofog-agent

# Spin up our Docker compose environment
echoInfo "Building and Starting Docker Compose environment"
docker-compose -f docker-compose.yml up --build --detach

# Initialize ioFog services
# echoInfo "Initializing ioFog Services"
# sed "s|/init/.*|/init/$ENV|g" ./docker-compose-init.yml > /tmp/docker-compose-init.yml
# cp /tmp/docker-compose-init.yml .
# docker-compose -f docker-compose-init.yml up --build

# Display the running environment
docker ps
echoNotify "ioFog Demo is now running"
