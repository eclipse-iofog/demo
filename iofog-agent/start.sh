#!/usr/bin/env bash
CONTROLLER_HOST="http://iofog-controller:51121/api/v3"
function wait() {
    while true; do
        str=`eval "$1"`
        if [[ ! $str =~ $2 ]]; then
            break
        fi
        sleep .5
    done
}

service iofog start
if [ -f /first_run.tmp ]; then
    wait "iofog status" "iofog is not running."
    iofog config -idc off
    iofog config -a $CONTROLLER_HOST

    rm /first_run.tmp
fi
tail -f /dev/null