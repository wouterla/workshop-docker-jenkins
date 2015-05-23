FROM wouterla/docker-base
MAINTAINER Wouter Lagerweij <wouter@lagerweij.com>

RUN apt-get update && apt-get install -y\
  python-setuptools \
  python-dev \
  libyaml-dev \
  git \
  curl \
  python-pip \
  python-yaml

RUN pip install jenkins-job-builder

ADD jobs /jobs
ADD config /config

CMD while ! curl --output /dev/null --silent --head --fail http://jenkins:8080; \
  do sleep 1; echo -n .; done \
  && jenkins-jobs --conf /config/jenkins_jobs.ini update /jobs

VOLUME /jobs
VOLUME /config
