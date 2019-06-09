FROM iofog/ubuntu-16.04-java8

# Install all our deps
RUN apt-get update -qq && apt-get install -qqy \
    sudo \
    curl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install iofog-connector (script requires sudo, curl and software-properties-common)
COPY ./install.sh ./install.sh
RUN ./install.sh
RUN rm ./install.sh

# Copy in the connector configuration
COPY iofog-connector.conf /etc/iofog-connector/iofog-connector.conf

ENTRYPOINT [ "sh", "-c", "service iofog-connector start && tail -f /dev/null" ]
