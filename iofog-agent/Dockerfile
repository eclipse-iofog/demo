FROM iofog/ubuntu-16.04-java8 as javaSource
FROM jpetazzo/dind

# Set up Java
COPY --from=javaSource /usr/lib/jvm/java-8-oracle /usr/lib/jvm/java-8-oracle
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-oracle/bin/java 1

# Install our deps
RUN apt-get update -qq && apt-get install -qqy \
    sudo \
    curl \
    jq \
    software-properties-common

RUN curl -s https://packagecloud.io/install/repositories/computology/apt-backport/script.deb.sh | sudo bash
RUN sudo apt-get install -y apt=1.2.10

# Install iofog-agent
RUN curl -s https://packagecloud.io/install/repositories/iofog/iofog-agent/script.deb.sh | sudo bash
RUN sudo apt-get install iofog-agent
RUN touch /first_run.tmp

# Copy our config and start scripts
COPY start.sh /start.sh
COPY config.xml /etc/iofog-agent/config.xml

ENTRYPOINT [ "/start.sh" ]