FROM iofog/ubuntu-16.04-java8

ARG LOCAL_CONNECTOR_PACKAGE
# Copy local package, or default install script (No conditional copy in docker)
COPY ./install.sh ${LOCAL_CONNECTOR_PACKAGE} /opt/iofog-connector/

# Install all our deps
RUN apt-get update -qq && apt-get install -qqy \
    sudo \
    curl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install iofog-connector (script requires sudo, curl and software-properties-common)
RUN /opt/iofog-connector/install.sh ${LOCAL_CONNECTOR_PACKAGE}
RUN rm /opt/iofog-connector/install.sh

# Copy in the connector configuration
COPY iofog-connector.conf /etc/iofog-connector/iofog-connector.conf

ENTRYPOINT [ "sh", "-c", "service iofog-connector start && tail -f /dev/null" ]
