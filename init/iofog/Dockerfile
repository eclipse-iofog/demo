FROM docker:dind

RUN apk add --no-cache curl jq

ADD ./provision.sh /

CMD ["sh", "-c", "/provision.sh; tail -f /dev/null"]
