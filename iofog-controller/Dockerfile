FROM iofog/node-alpine-x86:8.16.0

RUN apk add curl jq bash && \
  npm i -g iofogcontroller --unsafe-perm && \
  touch /first_run.tmp

COPY start.sh /

ENTRYPOINT [ "/start.sh" ]