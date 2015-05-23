FROM java:8
MAINTAINER Wouter Lagerweij <wouter@lagerweij.com>

RUN apt-get install software-properties-common
RUN apt-add-repository ppa:ansible/ansible
RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y git maven groovy netcat ansible

RUN wget -qO- https://get.docker.com/ | sh

RUN mkdir -p /work
VOLUME /work
