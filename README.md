# ioFog Demo

This repository demonstrates the capabilities of ioFog. It spins up the ioFog stack (Agent, Controller, and Connector) on a local machine in a Docker Compose environment. This basic ioFog stack setup constitutes a small, but fully configured Edge Compute Network (ECN).

Optionally, this demo also creates a sample application (microservices deployed on the ioFog stack).

This demo repository is used as supplementary materials for [ioFog quickstart](https://iofog.org/docs/1.0.0/getting-started/core-concepts.html) and [ioFog tutorial](https://iofog.org/docs/1.0.0/tutorial/introduction.html) guides. 


# Prerequisites

The ioFog demo requires one of the following systems and tools to be installed. The scripts in this demo do not install any of these tools, but they check for sufficient versions.

Supported operating systems:

* Linux (kernel v3.10+)
* macOS 10.12+
* Windows 7+

Requires tools:

* Docker 1.10+ ([installation instructions](https://docs.docker.com/install/))
* Docker-compose 1.22+ ([installation instructions](https://docs.docker.com/compose/install/))


# Try ioFog - Simple Edge Compute Network

The main interaction with this demo repository is encapsulated into a set of simple scripts: `start.sh`, `test.sh` and `stop.sh`. Interactions with the ioFog components can be done using a command line interface available in all the services of the stack, or using a REST API.

## Spin Up The ioFog Stack

Spin up the blank ioFog stack (Agent, Controller, and Connector) on the local machine.

```sh
./start.sh
```

Verify the iofog stack is provisioned correctly. The automated tests run a smoke test suite on the blank ioFog stack, testing basic operations.

```sh
./test.sh
```

You can also verify manually that the ioFog stack containers are correctly started.
```sh
docker ps --filter "name=iofog"
```

When you are finished, tear down the ioFog stack and all services deployed on it.

```sh
./stop.sh
```

## Interacting With The ioFog Stack - CLI

The simples way to interact with Agent, Controller, and Connector deployed on a machine you have access to is to use the command line interface. The main interaction point for users is the Controller.

```sh
docker exec -it iofog-controller iofog-controller help
```
_For the purpose of this demo, all ioFog components are spun up in separate Docker containers. The Controller's container is called `iofog-controller` (the first occurrence in the above command) and the executable inside the container is also called `iofog-controller` (the second occurrence).)_

Names for all the containers created in the demo are `iofog-agent`, `iofog-controller` and `iofog-connector`.

The initialization scripts used to setup the ioFog stack / ECN are using the CLI interface. Feel free to refer to these for more inspiration.

Full reference of the CLI for all ioFog stack components is available at the ioFog website:

* https://iofog.org/docs/1.0.0/controllers/cli-usage.html
* https://iofog.org/docs/1.0.0/agents/cli-usage.html
* https://iofog.org/docs/1.0.0/connectors/cli-usage.html

## Interacting With The ioFog Stack - REST API


Full reference of the REST API for all ioFog stack components is available at the ioFog website:

* https://iofog.org/docs/1.0.0/controllers/rest-api.html
* https://iofog.org/docs/1.0.0/agents/local-api.html
* https://iofog.org/docs/1.0.0/connectors/api-reference.html

Note that if you would like to use Agent, Controller, and Connector's REST APIs, you will have to modify the Compose environment to deploy with network_mode "host".


# Try ioFog - Sample Application Deployed On ioFog

First, create all services for a sample ioFog application. This is the same sample application that is used in the ioFog tutorial. You don't have to start the iofog stack manually, it will be created if necessary.

```sh
./start.sh sample
```

Rest if all tutorial services and the ioFog stack are working correctly.
```sh
./test.sh sample
```

When you are done with the tutorial, you can tear down the sample application.
```sh
./stop.sh sample
```

Alternatively, if you want to tear down all the applications and the ioFog stack, simply run `./stop.sh` without arguments.


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