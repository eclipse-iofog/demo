FROM jpetazzo/dind

RUN apt-get update -qq && apt-get install -qqy \
    sudo \
    curl \
    software-properties-common \
    jq

ADD ./start.sh /

CMD ["/start.sh"]