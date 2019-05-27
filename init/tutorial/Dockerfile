FROM alpine:3.8

RUN apk add --no-cache curl jq

ADD ./start.sh /

CMD ["sh", "-c", "/provision.sh"]
