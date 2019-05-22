# ioFog Demo

This repository orchestrates ioFog Agent, Controller, and Connector in a Docker Compose environment for the purpose of demonstrating a deployment of the ioFog stack.

# Usage

The main interaction with this demo repository is encapsulated into set of simple scritps: `start.sh`, `test.sh` and `stop.sh`. Interactions with the ioFog components can be done using a command line interface available in all the services of the stack, or using a REST API.

## Spin Up The ioFog Stack

Spin up the blank ioFog stack (Agent, Controller, and Connector) with two agents on the local machine.

```
./start.sh iofog
```

Verify the iofog stack is provisioned correctly. This can be run at any time, the script will automatically test all deployed components.

```
./test.sh iofog
```

To interact with Agent, Controller, and Connector you must exec into each respective container and use the CLI.

When you are finished, tear down the ioFog stack and all services deployed on it.

```
./stop.sh
```

## Interacting With The ioFog Stack - CLI

The container names are `iofog-agent-1`, `iofog-agent-2`, `iofog-controller` and `iofog-connector`. The main interaction point for users is the Controller.

```
docker exec -it iofog-controller iofog-controller help
```

## Interacting With The ioFog Stack - REST API

Note that if you would like to use Agent, Controller, and Connector's REST APIs, you will have to modify the Compose environment to deploy with network_mode "host".

## Spin Up Tutorial Services

First, create all services for the purpose of ioFog tutorial. You don't have to start the iofog stack manually, it will be created if necessary.

```
./start.sh tutorial
```

Rest if all tutorial services and the ioFog stack are working correctly.
```
./test.sh tutorial
```

# Structure Of This Repository

* services                  # Service Dockerfiles and customization files
    - iofog
        + iofog-agent       # part of iofog stack
            * Dockerfile
            * config.xml
            * supervisord.conf
        + iofog-connector   # part of iofog stack
            * Dockerfile
        + iofog-controller  # part of iofog stack
            * Dockerfile
    - tutorial
        + core-networking   # tutorial -        
            * Dockerfile
        + freeboard         # tutorial -
            * Dockerfile
        + sensors           # tutorial -
            * Dockerfile
    - another-demo-1
        + ...
    - another-demo-2
        + ...
* init                  # iofog-controller setup containers and scritps
    - iofog
        + Dockerfile
    - tutorial          # sets up everything for the environment
        + Dockerfile
        + init.sh       # anything that calls the controller API
    - another-demo
        + ...
* test                  # test contianers for all scenarios
    - iofog
        + Dockerfile
    - tutorial
        + Dockerfile
    - another-demo
        + ...
* conf # supporting configuration files 
* docker-compose-iofog.yml
* docker-compose-iofog-test.yml
* docker-compose-tutorial.yml
* docker-compose-tutorial-test.yml
* docker-compose-another-demo.yml
* docker-compose-another-demo-test.yml
* azure-pipelines.yml