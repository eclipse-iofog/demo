FROM mlaccetti/docker-oracle-java8-ubuntu-16.04 as javaSource
FROM jpetazzo/dind

COPY --from=javaSource /usr/lib/jvm/java-8-oracle /usr/lib/jvm/java-8-oracle
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-oracle/bin/java 1

RUN apt-get update -qq
RUN apt-get install -qqy sudo
RUN apt-get install -qqy curl
RUN apt-get install -qqy jq
RUN apt-get install -qqy software-properties-common
RUN curl -s https://packagecloud.io/install/repositories/iofog/iofog-agent/script.deb.sh | sudo bash
RUN sudo apt-get install iofog-agent
RUN touch /first_run.tmp

COPY start.sh /start.sh
COPY config.xml /etc/iofog-agent/config.xml

ENTRYPOINT [ "/start.sh" ]
