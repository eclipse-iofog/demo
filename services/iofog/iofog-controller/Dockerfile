FROM node:8.16.0-alpine

# Install iofog-controller
RUN npm i -g iofogcontroller --unsafe-perm

ENTRYPOINT [ "sh", "-c", "iofog-controller start && tail -f /dev/null" ]
