#!/usr/bin/env bash

if [ -f /first_run.tmp ]; then
    echo '{
      "ports": [
        "6000-9999",
        "30000-49999"
      ],
      "exclude": [],
      "broker":12345,
      "address":"127.0.0.1",
      "dev":true
    }' > /etc/comsat/comsat.conf
    rm /first_run.tmp
fi
service comsat start
tail -f /dev/null