#!/usr/bin/env bats

CONTAINER_ID=$(docker ps | grep iofog-agent | awk '{print $1}')
PREFIX_CMD="docker exec ${CONTAINER_ID}

@test "addition within container" {
  result="$(${PREFIX_CMD} echo 2+2)"
  [ "${result} -eq 4 ]
}