#!/usr/bin/env sh

set -e

rm conf/id_ecdsa* || true
ssh-keygen -t ecdsa -N "" -f conf/id_ecdsa -q
cp conf/id_ecdsa.pub iofog-agent

docker-compose -f docker-compose.yml up --build --detach