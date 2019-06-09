FROM node:8.16.0-alpine

# Install iofog-controller
COPY ./install.sh ./install.sh
RUN ./install.sh
RUN rm ./install.sh

ENTRYPOINT [ "sh", "-c", "iofog-controller start && tail -f /dev/null" ]
