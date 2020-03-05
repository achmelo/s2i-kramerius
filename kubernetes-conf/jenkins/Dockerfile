from jenkins/jenkins:2.203-jdk11

# Distributed Builds plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
COPY ca.crt /etc/docker/certs.d/harbor.nkp.cz:30004/
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt

# install Maven
USER root
RUN cat /etc/os-release
RUN apt-get update && \
apt-get -y install apt-transport-https \
	vim \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common  && \
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable" && \
apt-get update && \
apt-get -y install docker-ce
RUN apt-get install -y docker-ce

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

RUN curl -LO https://github.com/openshift/source-to-image/releases/download/v1.2.0/source-to-image-v1.2.0-2a579ecd-linux-amd64.tar.gz \
	&& tar -xvf source-to-image-v1.2.0-2a579ecd-linux-amd64.tar.gz \
	&& chmod +x ./s2i \
	&& mv ./s2i /usr/local/bin/s2i

RUN echo "192.168.131.128 harbor.nkp.cz" >> /etc/hosts
RUN chmod -R 757 /etc/hosts
COPY hosts /usr/share/
RUN cp -f /usr/share/hosts /etc/hosts
RUN usermod -a -G docker jenkins
RUN echo "root:root" | chpasswd

