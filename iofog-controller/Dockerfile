FROM node:alpine

RUN apk add curl jq python bash
RUN npm i -g iofogcontroller --unsafe-perm
RUN cd /usr/local/lib/node_modules/iofogcontroller

RUN touch /first_run.tmp

COPY start.sh /

ENTRYPOINT [ "/start.sh" ]
