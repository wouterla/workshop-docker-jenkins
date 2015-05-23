FROM wouterla/docker-base
MAINTAINER Wouter Lagerweij <wouter@lagerweij.com>

RUN curl -L http://mirrors.jenkins-ci.org/war/latest/jenkins.war -o /opt/jenkins.war
ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_UC http://updates.jenkins-ci.org

# Add configuration for jenkins and plugins
RUN mkdir -p /var/lib/jenkins

# Install plugins from plugins.txt
RUN mkdir -p /var/lib/jenkins/plugins
ADD plugins.txt plugins.txt
RUN cat plugins.txt | while read line; do \
      plugin_name=$(echo $line | cut -f1 -d:); \
      plugin_version=$(echo $line | cut -f2 -d:); \
      curl -L ${JENKINS_UC}/download/plugins/${plugin_name}/${plugin_version}/${plugin_name}.hpi -o ${JENKINS_HOME}/plugins/${plugin_name}.hpi; \
    done

# Add configuration files
ADD jenkins_home/* /var/lib/jenkins/

# Expose the jenkins dir as a volume
VOLUME /var/lib/jenkins

EXPOSE 8080
ENTRYPOINT java -jar /opt/jenkins.war
