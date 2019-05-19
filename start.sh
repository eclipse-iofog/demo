#!/bin/bash

set -e

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

# Generate SSH keys for Tests to access Agent container
rm conf/id_ecdsa* || true
ssh-keygen -t ecdsa -N "" -f conf/id_ecdsa -q
cp conf/id_ecdsa.pub iofog-agent

# Bring up ioFog services
docker-compose -f docker-compose.yml up --build --detach

# Initialize ioFog services
sed "s|/init/.*|/init/$ENV|g" ./docker-compose-init.yml > /tmp/docker-compose-init.yml
cp /tmp/docker-compose-init.yml .
docker-compose -f docker-compose-init.yml up --build