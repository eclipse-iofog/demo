#!/usr/bin/bats

CONTAINER_ID=$(docker ps | grep iofog-agent | awk '{print $1}')

@test "Integration Volume Checking" {
  result="$(docker inspect --format='{{.Mounts}}' ${CONTAINER_ID})"
  [[ ${result} ==  ]]
}

