FROM mlaccetti/docker-oracle-java8-ubuntu-16.04

RUN apt-get update -qq
RUN apt-get install -qqy sudo
RUN apt-get install -qqy curl
RUN apt-get install -qqy software-properties-common
RUN curl -s https://packagecloud.io/install/repositories/iofog/iofog-connector/script.deb.sh | sudo bash
RUN sudo apt-get install iofog-connector
RUN touch /first_run.tmp

COPY . /

ENTRYPOINT [ "/start.sh" ]