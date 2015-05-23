FROM ubuntu:15.04
MAINTAINER Wouter Lagerweij <wouter@lagerweij.com>

RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y software-properties-common
RUN apt-get install -y git maven groovy netcat ansible openjdk-8-jdk wget curl

RUN wget -qO- https://get.docker.com/ | sh

RUN mkdir -p /work
VOLUME /work
