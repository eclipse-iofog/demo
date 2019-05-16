#!/usr/bin/env sh

set -e

function finish {
    echo "Error on line $1"
    docker-compose down
    docker-compose -f docker-compose-init.yml down
}
trap finish ERR

# Generate SSH keys for Tests to access Agent container
rm conf/id_ecdsa* || true
ssh-keygen -t ecdsa -N "" -f conf/id_ecdsa -q
cp conf/id_ecdsa.pub iofog-agent

# Bring up ioFog services
docker-compose -f docker-compose.yml up --build --detach
# Initialize ioFog services
docker-compose -f docker-compose-init.yml up --build