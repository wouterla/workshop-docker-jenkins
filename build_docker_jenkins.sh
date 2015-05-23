#!/bin/bash
echo "Clean..."
rm -rf build && mkdir build

echo "generating files with ansible"
ansible-playbook --connection=local -i 'localhost,' site_jenkins_docker.yml

echo "Copying docker files"
cp docker/docker-jenkins/* build/

echo "Running docker"
cd build
docker build -t wouterla/docker-jenkins .

echo "Pushing docker image to repository"
#docker push wouterla/docker-jenkins
