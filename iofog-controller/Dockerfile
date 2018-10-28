FROM node:alpine

COPY src/package.json /src/package.json
COPY src/src /src/src
RUN apk add curl jq
RUN cd /src && \
    npm i >> /dev/null && \
    sh ./src/sequelize/rebuild_dev_db.sh >> /dev/null

RUN touch /first_run.tmp

COPY start.sh /

ENTRYPOINT [ "/start.sh" ]
