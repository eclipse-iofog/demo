FROM jpetazzo/dind

RUN apt-get update -qq
RUN apt-get install -qqy sudo
RUN apt-get install -qqy curl
RUN apt-get install -qqy software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update -qq
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
RUN apt-get install -y oracle-java8-installer
RUN curl -s https://packagecloud.io/install/repositories/iofog/iofog/script.deb.sh | sudo bash
RUN sudo apt-get install iofog-dev
RUN touch /first_run.tmp

COPY . /
COPY config.xml /etc/iofog/config.xml

ENTRYPOINT [ "/start.sh" ]
