#!/bin/sh

# If local controller provided, install from local package, otherwise go to npm repository
if [ ! -z "$1" ] && [ ! "$1" = "./install.sh" ]; then
  echo "============> Installing local controller"
  npm install --unsafe-perm -g /opt/iofog-controller/"$1"
  rm -f /opt/iofog-controller/"$1"
else
  npm i -g iofogcontroller@1.2 --unsafe-perm
fi