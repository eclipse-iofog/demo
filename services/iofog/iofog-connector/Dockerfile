FROM iofog/ubuntu-16.04-java8

# Install all our deps
RUN apt-get update -qq && apt-get install -qqy \
    sudo \
    curl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install iofog-connector
RUN curl -s https://packagecloud.io/install/repositories/iofog/iofog-connector/script.deb.sh | sudo bash
RUN sudo apt-get install iofog-connector

# Copy in the connector configuration
COPY iofog-connector.conf /etc/iofog-connector/iofog-connector.conf

ENTRYPOINT [ "sh", "-c", "service iofog-connector start && tail -f /dev/null" ]