#!/usr/bin/env sh
# start.sh - is the entry point to the Demo. It will setup an conf needed and spin up a docker-compose
# environment of a fully configured ioFog ECN.
#
# Usage: start.sh

set -e

# Import our helper functions
. ./utils.sh

prettyHeader "Starting ioFog Demo environment"

# Clean up any artifacts from a previous run
rm conf/id_ecdsa* || true

# Create a new ssh key and copy it into Agent
echoInfo "Adding new ssh key pair to Agent"
ssh-keygen -t ecdsa -N "" -f conf/id_ecdsa -q
cp conf/id_ecdsa.pub iofog-agent

# Spin up our Docker compose environment
echoInfo "Building and Starting Docker Compose environment"
docker-compose -f docker-compose.yml up --build --detach

# Display the running environment
docker ps
echoNotify "ioFog Demo is now running"