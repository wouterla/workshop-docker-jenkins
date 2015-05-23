#!/bin/bash
echo "Clean..."
rm -rf build && mkdir build

echo "building petclinic"
cd spring-petclinic
mvn clean install
cd ..

echo "Copying docker files"
cp docker/docker-petclinic/* spring-petclinic/target/

echo "Running docker"
cd spring-petclinic/target/
docker build -t wouterla/docker-petclinic .

echo "Pushing docker image to repository"
#docker push wouterla/docker-jenkins
