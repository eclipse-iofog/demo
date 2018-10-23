#!/usr/bin/env bash

if [ -f /first_run.tmp ]; then
    fog-controller config -add email_activation off
    fog-controller user -add user@domain.com John Doe "#Bugs4Fun"

    fog-controller comsat -add localcomsat comsat 10.0.0.3
    rm /first_run.tmp
fi
fog-controller start
tail -f /dev/null