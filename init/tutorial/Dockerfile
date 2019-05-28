FROM alpine:3.9

RUN apk add --no-cache curl jq

ADD ./provision.sh /

CMD ["sh", "-c", "/provision.sh"]
