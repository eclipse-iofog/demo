#!/bin/sh

# If local agent provided, install from local package, otherwise go to packagecloud
if [ ! -z "$1" ] && [ ! "$1" = "./install.sh" ]; then
  echo "============> Installing local agent"
  dpkg -i /opt/iofog-agent/"$1"
  rm -f /opt/iofog-agent/"$1"
else
  wget -q -O - https://packagecloud.io/install/repositories/iofog/iofog-agent/script.deb.sh | bash
  apt-get install iofog-agent
fi