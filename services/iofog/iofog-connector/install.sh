#!/bin/sh

# If local connector provided, install from local package, otherwise go to packagecloud
if [ ! -z "$1" ] && [ ! "$1" = "./install.sh" ]; then
  echo "============> Installing local connector"
  dpkg -i /opt/iofog-connector/"$1"
  rm -f /opt/iofog-connector/"$1"
else
  wget -q -O - https://packagecloud.io/install/repositories/iofog/iofog-connector/script.deb.sh | bash
  apt-get install iofog-connector
fi