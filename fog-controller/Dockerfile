FROM node:8.11.4

RUN npm install -g --unsafe-perm iofogcontroller
RUN touch /first_run.tmp

COPY . /

ENTRYPOINT [ "/start.sh" ]
