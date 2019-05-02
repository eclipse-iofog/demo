FROM iofog/java-ubuntu-x86:8u211

# Install all our deps
RUN apt-get update --fix-missing -qq && \
  apt-get install -qqy sudo curl && \
# Install iofog-connector
  curl -s https://packagecloud.io/install/repositories/iofog/iofog-connector/script.deb.sh | sudo bash && \
  sudo apt-get install iofog-connector && \
  touch /first_run.tmp

# Copy in the files we need
COPY start.sh /start.sh

ENTRYPOINT [ "/start.sh" ]
