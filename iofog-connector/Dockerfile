FROM iofog/ubuntu-16.04-java8

# Install all our deps
RUN apt-get update -qq && apt-get install -qqy \
    sudo \
    curl \
    software-properties-common

# Install iofog-connector
RUN curl -s https://packagecloud.io/install/repositories/iofog/iofog-connector/script.deb.sh | sudo bash
RUN sudo apt-get install iofog-connector
RUN touch /first_run.tmp

# Copy in the files we need
COPY start.sh /start.sh

ENTRYPOINT [ "/start.sh" ]