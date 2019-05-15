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
    software-properties-common \
    openssh-server \
    supervisor

RUN curl -s https://packagecloud.io/install/repositories/computology/apt-backport/script.deb.sh | sudo bash
RUN sudo apt-get install -y apt=1.2.10

# Install iofog-agent
RUN curl -s https://packagecloud.io/install/repositories/iofog/iofog-agent/script.deb.sh | sudo bash
RUN sudo apt-get install iofog-agent
RUN touch /first_run.tmp

# Copy our config and start scripts
COPY start.sh /start.sh
COPY config.xml /etc/iofog-agent/config.xml

# SSH Magic
COPY id_ecdsa.pub /
RUN mkdir -p /root/.ssh
RUN cat /id_ecdsa.pub > /root/.ssh/authorized_keys
RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]