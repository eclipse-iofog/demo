#!/usr/bin/bats

function importAgents() {
    AGENTS=()
    while IFS= read -r HOST
    do
        AGENTS+="$HOST"
    done < conf/agents.conf
}

function sshAgent() {
    AGENT=$1
    IDX=$2
    echo "SSH into $AGENT"
    ssh -i conf/id_agent_"$IDX" -o StrictHostKeyChecking=no "$AGENT" echo "Successfully connected to $AGENT via SSH"

}
CONTAINER_ID=$(docker ps | grep iofog-agent | awk '{print $1}')
importAgents

@test "Integration SHH Into Agents Checking" {
  IDX=1
  finalResult=0

  for AGENT in "${AGENTS[@]}"; do
      result=$(sshAgent "${AGENT}" "${IDX}")
      if [[ "${result}" -ne "0" ]]; then
          finalResult=${result}
          skip
      fi
      IDX=$((IDX+1))
  done

  [[ ${finalResult} -eq 0 ]]
}

@test "Integration Volume Checking" {

  result="$(docker inspect --format='{{.Mounts}}' ${CONTAINER_ID})"
  [[ ${result} ==  ]]
}

@test "Integration Port Checking" {
  result="$(docker inspect --format='{{json .Config.ExposedPorts }}' ${CONTAINER_ID})"
  [[ ${result} ==  ]]
}


@test "Integration Routes Checking" {
  result="$()" #Need to decide on what we're sending over, to see valid routes
  [[ ${result} ==  ]]
}


@test "Integration Privileged Checking" {
  result="$(docker inspect --format='{{.HostConfig.Privileged}}' ${CONTAINER_ID})"
  [[ ${result} ==  ]]
}

@test "Integration Environment Variables Checking" {
  result="$(docker exec ${CONTAINER_ID} bash -c 'echo "${ENV_VAR}"')"
  [[ ${result} ==  ]]
}

