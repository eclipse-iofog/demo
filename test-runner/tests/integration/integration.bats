#!/usr/bin/bats

# Import Agents from our agents.conf file we generate when building
function importAgents() {
    AGENTS=()
    while IFS= read -r HOST
    do
        AGENTS+="$HOST"
    done < conf/agents.conf
}

# Import our config stuff, so we aren't hardcoding the variables we're testing for. Add to this if more tests are needed
function importConfig() {
    config=$(cat config.json)
    ports=$(echo ${config} | json select '.ports')
    envVariable=$(echo ${config} | json select '.environment')
    volumeFile=$(echo ${config} | json select '.volumeFile')
}

# SSH into our agent containers, so we can run local commands
function sshAgent() {
    AGENT=$1
    IDX=$2
    CMD=$3
    echo "SSH into $AGENT"
    ssh -i conf/id_agent_"$IDX" -o StrictHostKeyChecking=no "$AGENT" "${CMD}"

}
CONTAINER_ID=$(docker ps | grep iofog-agent | awk '{print $1}')
importAgents
importConfig

# Test that the SSH connection to Agents is Valid
@test "Integration SHH Into Agents Checking" {
  IDX=1
  finalResult=0
  CMD="echo 'Successfully connected to $AGENT via SSH'"

  for AGENT in "${AGENTS[@]}"; do
      result=$(sshAgent "${AGENT}" "${IDX}" "${CMD}")
      if [[ "${result}" -ne "0" ]]; then
          finalResult=${result}
      fi
      IDX=$((IDX+1))
  done

  [[ ${finalResult} -eq 0 ]]
}

# Test that Volumes have been mapped across correctly
@test "Integration Volume Checking" {
    IDX=1
    finalResult=0
    CMD="test -f FILENAME"

    for AGENT in "${AGENTS[@]}"; do
        result=$(sshAgent "${AGENT}" "${IDX}" "${CMD}")
        if [[ ${result} -ne 0 ]]; then
            finalResult=${result}
        fi
    done
    [[ ${finalResult} -eq 0 ]]
}

@test "Integration Port Checking" {
    IDX=1
    finalResult=0
    CMD="telnet localhost ${ports}"

    for AGENT in "${AGENTS[@]}"; do
        result=$(sshAgent "${AGENT}" "${IDX}" "${CMD}")
        if [[ ${result} -ne 0 ]]; then
            finalResult=${result}
        fi
    done
  [[ ${finalResult} -eq 0 ]]
}

@test "Integration Routes Checking" {
    IDX=1
    finalResult=0
    CMD="cat /etc"
    for AGENT in "${AGENTS[@]}"; do
        result=$(sshAgent "${AGENT}" "${IDX}" "${CMD}")
        if [[ ${result} -ne 0 ]]; then
            finalResult=${result}
        fi
    done
  [[ ${finalResult} -eq 0 ]]
}

@test "Integration Privileged Checking" {
    IDX=1
    finalResult=0
    CMD="telnet localhost ${ports}"
    for AGENT in "${AGENTS[@]}"; do
        result=$(sshAgent "${AGENT}" "${IDX}" "${CMD}")
        result="$(docker inspect --format='{{json .Config.ExposedPorts }}' ${CONTAINER_ID})"
        if [[ ${result} -ne 0 ]]; then
            finalResult=${result}
        fi
    done
  [[ ${finalResult} -eq 0 ]]
}

@test "Integration Environment Variables Checking" {
    IDX=1
    finalResult=0
    CMD="[ ! -z '$envVariable' ]"
    for AGENT in "${AGENTS[@]}"; do
        result=$(sshAgent "${AGENT}" "${IDX}" "${CMD}")
        if [[ "${result}" -ne 0 ]]; then
            finalResult=${result}
        fi
    done
    [[ ${finalResult} -eq 0 ]]
}

