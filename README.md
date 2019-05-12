# ioFog Demo

This repository orchestrates ioFog Agent, Controller, and Connector in a Docker Compose environment for the purpose of demonstrating a deployment of the ioFog stack.

# Usage

To spin up Agent, Controller, and Connector containers within a virtual network:
```
./start.sh
```

To verify the services are provisioned correctly:
```
./test.sh
```

To interact with Agent, Controller, and Connector you must exec into each respective container and use the CLI:
```
docker exec -it iofog-controller /bin/bash
iofog-controller help
```

Note that if you would like to use Agent, Controller, and Connector's REST APIs, you will have to modify the Compose environment to deploy with network_mode "host".

When you are finished, it is recommended that you teardown:
```
./stop.sh
```