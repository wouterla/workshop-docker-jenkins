FROM wouterla/docker-base
MAINTAINER Wouter Lagerweij <wouter@lagerweij.com>

RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y git openssh-server
RUN mkdir -p /var/run/sshd

RUN useradd -m jenkins

RUN mkdir -p /home/jenkins/.ssh && chown jenkins:jenkins /home/jenkins/.ssh && chmod 700 /home/jenkins/.ssh
ADD jenkins_home/.ssh/id_rsa.pub /home/jenkins/.ssh/authorized_keys
RUN chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys && chmod 600 /home/jenkins/.ssh/authorized_keys

RUN apt-get install -y maven groovy gradle

EXPOSE 22
