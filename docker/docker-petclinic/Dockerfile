FROM wouterla/docker-base
MAINTAINER Wouter Lagerweij <wouter@lagerweij.com>

RUN curl -L http://repo2.maven.org/maven2/org/mortbay/jetty/jetty-runner/8.1.9.v20130131/jetty-runner-8.1.9.v20130131.jar -o jetty-runner.jar

ADD petclinic.war ./

CMD java -jar jetty-runner.jar petclinic.war
