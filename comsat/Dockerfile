FROM openjdk:8-jre-slim

RUN apt-get update
RUN apt-get install -y sudo
RUN apt-get install -y curl
RUN curl -s https://packagecloud.io/install/repositories/iofog/comsat/script.deb.sh | sudo bash
RUN sudo apt-get install comsat

COPY . /

ENTRYPOINT [ "/start.sh" ]