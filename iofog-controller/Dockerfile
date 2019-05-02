FROM iofog/node-alpine-x86:8.16.0

# Install all our deps
RUN apk add curl jq bash && \
# Install iofog-controller
  npm i -g iofogcontroller --unsafe-perm && \
  touch /first_run.tmp

# Copy in the files we need
COPY start.sh /start.sh

ENTRYPOINT [ "/start.sh" ]
