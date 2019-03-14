FROM node:alpine

# Install all our deps
RUN apk add curl jq python bash

# Install iofog-controller
RUN npm i -g iofogcontroller --unsafe-perm

RUN touch /first_run.tmp

# Copy in the files we need
COPY start.sh /start.sh

ENTRYPOINT [ "/start.sh" ]
