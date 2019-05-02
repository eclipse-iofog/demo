FROM iofog/java-ubuntu-x86:8u211

RUN apt-get update --fix-missing -qq && \
  apt-get install -qqy sudo curl && \
  curl -s https://packagecloud.io/install/repositories/iofog/iofog-connector/script.deb.sh | sudo bash && \
  sudo apt-get install iofog-connector && \
  touch /first_run.tmp

COPY . /

ENTRYPOINT [ "/start.sh" ]