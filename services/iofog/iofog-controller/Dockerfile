FROM node:8.16.0-alpine

ARG LOCAL_CONTROLLER_PACKAGE
# Copy local package, or default install script (No conditional copy in docker)
COPY ./install.sh ${LOCAL_CONTROLLER_PACKAGE}* /opt/iofog-controller/

# Install iofog-controller
RUN /opt/iofog-controller/install.sh ${LOCAL_CONTROLLER_PACKAGE}
RUN rm /opt/iofog-controller/install.sh

ENTRYPOINT [ "sh", "-c", "iofog-controller start && tail -f /dev/null" ]
