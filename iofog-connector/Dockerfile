FROM ubuntu:16.04

RUN apt-get update --fix-missing -qq && \
  apt-get install -qqy sudo && \
  apt-get install -qqy curl

ADD http://www.edgeworx.io/downloads/jdk/jdk-8u211-64.tar.gz /opt
RUN cd /opt && \
  tar xzf jdk-8u211-64.tar.gz && \
  cd /opt/jdk1.8.0_211/ && \
  update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_211/bin/java 1100 && \
  rm -R /opt/jdk-8u211-64.tar.gz && \
  curl -s https://packagecloud.io/install/repositories/iofog/iofog-connector/script.deb.sh | sudo bash && \
  sudo apt-get install iofog-connector && \
  touch /first_run.tmp

COPY . /

ENTRYPOINT [ "/start.sh" ]