FROM node:alpine

RUN apk add curl jq python bash
RUN npm i -g iofogcontroller --unsafe-perm

RUN touch /first_run.tmp

COPY start.sh /

ENTRYPOINT [ "/start.sh" ]
