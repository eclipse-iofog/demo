#
# Launch script to run our Smoke Test Suite
#
#!/usr/bin/env sh

echo 'iofog-connector:8080' > conf/connector.conf
echo 'iofog-controller:51121' > conf/controller.conf
echo 'root@iofog-agent' > conf/agents.conf
rm conf/id_ecdsa*
ssh-keygen -t ecdsa -N "" -f conf/id_ecdsa -q
cp conf/id_ecdsa.pub iofog-agent

docker-compose -f docker-compose-test.yml pull test-runner
docker-compose -f docker-compose.yml -f docker-compose-test.yml up \
    --build \
    --abort-on-container-exit \
    --exit-code-from test-runner \
    --force-recreate \
    --renew-anon-volumes

ERR="$?"

docker-compose down -v

exit "$ERR"