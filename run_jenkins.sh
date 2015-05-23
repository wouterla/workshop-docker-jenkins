#!/bin/bash

# Build the images
#build_docker_jenkins.sh
#build_docker_jenkins_builder.sh
#build_docker_jenkins_slave_php.sh
#build_docker_jenkins_slave_java.sh

# Run
docker run -d -v /home/vagrant/.m2:/root/.m2 -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 --name jenkins wouterla/docker-jenkins
docker run --link jenkins:jenkins wouterla/docker-jenkins-job-builder
