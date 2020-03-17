#!/usr/bin/env bash
#
# test.sh - will pull and run the TestRunner suite against an already Demo compose cluster.
#
# Usage : ./test.sh -h
#

set -o errexit -o pipefail -o noclobber -o nounset
cd "$(dirname "$0")"

# Import our helper functions
. ./utils.sh

printHelp() {
	echo "Usage:   ./test.sh"
	echo "Tests ioFog environment"
	echo ""
	echo "Arguments:"
	echo "    -h, --help        print this help / usage"
}

if [[ $# -gt 0 ]]; then
    printHelp
    exit 1
fi

prettyHeader "Running Test Runner Suite"

# Check to see if we are already running the Demo
IOFOG_RUNNING=$(docker inspect -f '{{.State.Running}}' iofog-agent iofog-connector iofog-controller | tr -d "[:space:]")
if [[ "${IOFOG_RUNNING}" == "truetruetrue" ]]; then
    echoInfo "ioFog stack is running"
else
    echoError 'ioFog stack is not running! Please run `./start.sh` first'
    exit 2
fi

# Create a new ssh key
echoInfo "Creating new ssh key for tests..."
rm -f test/conf/id_ecdsa*
ssh-keygen -t ecdsa -N "" -f test/conf/id_ecdsa -q

# SSH Magic
# Allows the test's container "test-runner" access to iofog-agent, due to the agent's lack of REST API
AGENT_CONTAINER_ID=$(docker ps -q --filter="name=iofog-agent")

# Configuring ssh on the agent
echoInfo "Configuring ssh on the Agent"
# Init log file
CONFIGURE_SSH_LOG_FILE=/tmp/configure_ssh.log
if [[ -f "${CONFIGURE_SSH_LOG_FILE}" ]]; then
    rm "${CONFIGURE_SSH_LOG_FILE}"
fi
echo '' > "${CONFIGURE_SSH_LOG_FILE}"
{
    echo 'Updating apt-get' >> "${CONFIGURE_SSH_LOG_FILE}"
    SECONDS=1
    until docker exec iofog-agent apt-get update -y  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1; do
        if [ $SECONDS -gt 60 ]; then
            exit 1
        fi
        sleep 1
        SECONDS=$((SECONDS+1))
    done
    echo 'Installing Openssh-server' >> "${CONFIGURE_SSH_LOG_FILE}"
    docker exec iofog-agent apt-get install -y --fix-missing openssh-server  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
    echo 'Running apt-get install -fy' >> "${CONFIGURE_SSH_LOG_FILE}"
    docker exec iofog-agent apt-get install -fy  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
    echo 'Creating ~/.ssh' >> "${CONFIGURE_SSH_LOG_FILE}"
    docker exec iofog-agent mkdir -p /root/.ssh  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
    docker exec iofog-agent chmod 700 /root/.ssh  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
    echo 'Copying public key to ~/.ssh/authorized_keys' >> "${CONFIGURE_SSH_LOG_FILE}"
    docker cp test/conf/id_ecdsa.pub "$AGENT_CONTAINER_ID:/root/.ssh/authorized_keys"  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
    docker exec iofog-agent chmod 644 /root/.ssh/authorized_keys  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
    docker exec iofog-agent chown root:root /root/.ssh/authorized_keys  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
    echo 'Creating /var/run/.sshd' >> "${CONFIGURE_SSH_LOG_FILE}"
    docker exec iofog-agent mkdir -p /var/run/sshd  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
    echo 'Updating /etc/pam.d/sshd' >> "${CONFIGURE_SSH_LOG_FILE}"
    docker exec iofog-agent sudo sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
    echo 'Updating /etc/ssh/sshd_config' >> "${CONFIGURE_SSH_LOG_FILE}"
    docker exec iofog-agent sudo sed 's@#AuthorizedKeysFile	%h/.ssh/authorized_keys@AuthorizedKeysFile	%h/.ssh/authorized_keys@g' -i /etc/ssh/sshd_config  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
    echo 'Restarting ssh service' >> "${CONFIGURE_SSH_LOG_FILE}"
    docker exec iofog-agent /bin/bash -c 'service ssh restart'  >> "${CONFIGURE_SSH_LOG_FILE}" 2>&1
} || {
    echoError "Failed to configure ssh on agent container"
    cat "${CONFIGURE_SSH_LOG_FILE}"
    exit 1
}

echoInfo "Running Test Runner..."
docker run --rm --name test-runner --network local-iofog-network \
    -v "$(pwd)/test/conf/id_ecdsa:/root/.ssh/id_ecdsa" \
    -e CONTROLLER="iofog-controller:51121" \
    -e AGENTS="root@iofog-agent:22" \
    iofog/test-runner:2.0

echoNotify "## Test Runner Tests complete"
