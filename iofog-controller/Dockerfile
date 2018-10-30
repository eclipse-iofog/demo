FROM node:alpine

RUN apk add curl jq python bash
RUN npm i -g iofogcontroller@0.9.5 --unsafe-perm
RUN cd /usr/local/lib/node_modules/iofogcontroller && \
  sh ./src/sequelize/rebuild_dev_db.sh

RUN touch /first_run.tmp

COPY start.sh /

ENTRYPOINT [ "/start.sh" ]
