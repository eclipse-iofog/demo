#
# Launch script to run our Smoke Test Suite
#
#!/usr/bin/env sh

echo 'iofog-connector:8080' > test-runner/conf/connector.conf
echo 'iofog-controller:51121' > test-runner/conf/controller.conf
echo 'root@iofog-agent' > test-runner/conf/agents.conf
rm test-runner/conf/id_agent_*
ssh-keygen -t ecdsa -N "" -f test-runner/conf/id_agent_1 -q

docker-compose -f docker-compose.yml -f docker-compose-test.yml up \
    --build \
    --abort-on-container-exit \
    --exit-code-from test-runner

echo $?

docker-compose down