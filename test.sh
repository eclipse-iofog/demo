#!/usr/bin/env sh

set -e

AGENT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iofog-agent)
CONTROLLER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iofog-controller)
CONNECTOR_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iofog-connector)

# Output the config for our Test suite config
echo "${CONNECTOR_IP}:8080" > conf/connector.conf
echo "${CONTROLLER_IP}:51121" > conf/controller.conf
echo "root@${AGENT_IP}" > conf/agents.conf

docker-compose -f docker-compose-test.yml pull test-runner
docker-compose -f docker-compose-test.yml up \
    --build \
    --abort-on-container-exit \
    --exit-code-from test-runner \
    --force-recreate \
    --renew-anon-volumes