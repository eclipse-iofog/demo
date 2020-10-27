# ioFog Demo

This repository demonstrates the capabilities of ioFog. It spins up the ioFog stack (Agent, Controller, and Connector) on a local machine in a Docker Compose environment. This basic ioFog stack setup constitutes a small, but fully configured Edge Compute Network (ECN).

Optionally, this demo also creates a sample application (microservices deployed on the ioFog stack).

This demo repository is used as supplementary materials for [ioFog quickstart](https://iofog.org/docs/1.0.0/getting-started/core-concepts.html) and [ioFog tutorial](https://iofog.org/docs/1.0.0/tutorial/introduction.html) guides. 


# Prerequisites

The ioFog demo requires one of the following systems and tools to be installed. The scripts in this demo do not install any of these tools, but they check for sufficient versions.

Supported operating systems:

* Linux (kernel v3.10+)
* macOS 10.12+

Requires tools:

* Docker 1.10+ ([installation instructions](https://docs.docker.com/install/))
* iofogctl 2.0.2 ([installation instructions](https://github.com/eclipse-iofog/iofogctl/tree/release/2.0#install))


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

## Build from local images

If you have a local image version of the Agent, Controller and Connector, you can chose to build the containers using those local images.
To do so, you will need a docker image for the Agent, the Connector and the Controller.
You can provide `start.sh` with an option for each local package you want to use.

### Example

Command:
```sh
./start.sh -a gcr.io/focal-freedom-236620/agent:latest -cn gcr.io/focal-freedom-236620/connector:latest -ct gcr.io/focal-freedom-236620/controller:latest
```

## ECN Status

```sh
./status.sh # Will show you all iofog-related containers currently running.
```

## Interacting With The ioFog Stack - CLI

The simplest way to interact with Agent, Controller, and Connector deployed on a machine you have access to is to use the command line interface `iofogctl`.

```sh
iofogctl help
```

For the purpose of this demo, all ioFog components are spun up in separate Docker containers. The Controller's container is called `iofog-controller`.

Names for all the containers created in the demo are `iofog-agent`, `iofog-controller` and `iofog-connector`.

The initialization scripts used to setup the ioFog stack / ECN are using the CLI interface. Feel free to refer to these for more inspiration.

Full reference of the CLI is available at the iofogctl github repository:

* https://github.com/eclipse-iofog/iofogctl/tree/release/2.0#usage

## Interacting With The ioFog Stack - REST API


Full reference of the REST API for all ioFog stack components is available at the ioFog website:

* https://iofog.org/docs/2/reference-controller/rest-api.html
* https://iofog.org/docs/2/reference-agent/rest-api.html

You can try using the REST API directly on your machine with the ioFog stack running.
```sh
curl --url 'http://0.0.0.0:51121/api/v3/status' 
```


# Try ioFog - Tutorial Application Deployed On ioFog

Apart from creating just the ioFog stack, we can also deploy an ioFog application on the stack. Here we demonstrate it on the tutorial application from the ioFog website.

First, create all services for a tutorial ioFog application. You don't have to start the iofog stack manually, it will be created if necessary.

```sh
./start.sh tutorial
```

When you are done with the tutorial, you can tear down the sample application together with the ioFog stack.

```sh
./stop.sh
```

if you only wish to delete the tutorial application:

```sh
iofogctl delete application tutorial
```

# Structure Of This Repository
```text
* services                  # Service Dockerfiles and customization files
    - iofog
        + iofog-agent       # Agent service files - part of the iofog stack
        + iofog-controller  # Controller service files - part of the iofog stack
* init
    - iofog                 # plain ioFog stack initialization yaml file        
    - tutorial              # tutorial initialization yaml file
* test
    + conf                  # generated test configuration files 
* azure-pipelines.yml
* docker-compose-iofog.yml
* docker-compose-tutorial.yml
* docker-compose-test.yml
* start.sh
* stop.sh
* test.sh
* utils.sh
```
