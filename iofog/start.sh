#!/usr/bin/env bash

iofog config -gps off
service iofog start
if [ -f /first_run.tmp ]; then
    sleep 5
    iofog config -idc off
    iofog config -dev on
    iofog config -a http://fogcontroller.iofog.org:54421/api/v2
    rm /first_run.tmp
fi
tail -f /dev/null