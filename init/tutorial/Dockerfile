FROM jpetazzo/dind

RUN apt-get update -qq && apt-get install -qqy \
    sudo \
    curl \
    software-properties-common \
    jq

ADD ./catalog.sh /
ADD ./provision.sh /

CMD ["sh", "-c", "./catalog.sh && ./provision.sh"]