#!/usr/bin/env sh

set -e

# Output the config for our Test suite config
echo 'iofog-connector:8080' > conf/connector.conf
echo 'iofog-controller:51121' > conf/controller.conf
echo 'root@iofog-agent-1' > conf/agents.conf
echo 'root@iofog-agent-2' >> conf/agents.conf

docker-compose -f docker-compose-test.yml pull test-runner
docker-compose -f docker-compose-test.yml up \
    --build \
    --abort-on-container-exit \
    --exit-code-from test-runner \
    --force-recreate \
    --renew-anon-volumes