FROM iofog/ubuntu-16.04-java8

ARG LOCAL_AGENT_PACKAGE
# Copy install script and local package if there is one (No conditional copy in docker)
COPY ./install.sh ${LOCAL_AGENT_PACKAGE} /opt/iofog-agent/

# Install our deps
RUN apt-get update -qq && apt-get install -qqy \
    sudo \
    curl \
    software-properties-common \
    openssh-server \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install iofog-agent (script requires sudo, curl and software-properties-common)
RUN /opt/iofog-agent/install.sh ${LOCAL_AGENT_PACKAGE}
RUN rm /opt/iofog-agent/install.sh

# SSH Magic
# Allows the test's container "test-runner" access to iofog-agent, due to the agent's lack of REST API
COPY id_ecdsa.pub /
RUN mkdir -p /root/.ssh
RUN cat /id_ecdsa.pub > /root/.ssh/authorized_keys
RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22

# Copy our configs
COPY config.xml /etc/iofog-agent/config.xml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
