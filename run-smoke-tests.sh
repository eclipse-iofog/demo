#
# Launch script to run our Smoke Test Suite
#
#!/usr/bin/env sh

docker-compose -f docker-compose.yml -f docker-compose-test.yml up \
    --build \
    --abort-on-container-exit \
    --exit-code-from test-runner

echo $?

docker-compose down