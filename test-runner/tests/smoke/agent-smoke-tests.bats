#!/usr/bin/env bats

CONTAINER_ID=$(docker ps | grep iofog-agent | awk '{print $1}')
PREFIX_CMD="docker exec ${CONTAINER_ID}"

@test "iofog-agent status" {
  result="$(${PREFIX_CMD} iofog-agent status)"
  [[ ${result} -eq 4 ]]
}

@test "iofog-agent network_interface" {
  result="$(${PREFIX_CMD} nano /etc/iofog-agent/config.xml | grep '<network_interface>dynamic</network_interface>' )"
  [[ "${result}" == *'dynamic'* ]]
}

@test "iofog-agent version" {
  result="$(${PREFIX_CMD} iofog-agent version)"
  [[ "${result}" == *'1.0.'* ]]
}

@test "iofog-agent info" {
  result="$(${PREFIX_CMD} iofog-agent info )"
  [[ "${result}" == *'Iofog UUID'* ]]
}

@test "iofog-agent provision BAD" {
  result="$(${PREFIX_CMD} iofog-agent provision 'asd')"
  [[ "${result}" == *'Invalid Provisioning Key'* ]]
}

@test "iofog-agent config INVALID RAM" {
  result="$(${PREFIX_CMD} iofog-agent config -m 50)"
  [[ "${result}" == *'Memory limit range'* ]]
}

@test "iofog-agent config RAM string" {
  result="$(${PREFIX_CMD} iofog-agent config -m test)"
  [[ "${result}" == *'invalid value'* ]]
}

@test "iofog-agent config VALID RAM" {
  result="$(${PREFIX_CMD} iofog-agent config -m 80)"
  [[ "${result}" == *'New Value'* ]]
}
