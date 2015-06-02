# workshop-docker-jenkins-startpoint
Startpoint for participants in the workshop "Docker & Jenkins Job Builder".

Original sources on: [https://github.com/wouterla/workshop-docker-jenkins](https://github.com/wouterla/workshop-docker-jenkins)

## Prerequisites:
- VirtualBox: [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
- Vagrant: [http://www.vagrantup.com/downloads.html](http://www.vagrantup.com/downloads.html)

### On Windows machines**:
- Git bash: [https://msysgit.github.io/](https://msysgit.github.io/) or other package providing ssh. Ensure that the path containing the ssh.exe file is in your system PATH (ie.: `set PATH=%PATH%;C:\Program Files (x86)\Git\bin`)

## Getting Started
- Copy contents of the usb drive to your local disk
- Open a (unix/bash) shell and go to the 'workshop-docker-jenkins' directory
- Type 'vagrant up'
- Wait...
- Type 'vagrant ssh'

You should now be logged into the virtual machine.

### Basic Docker commands
Within the virtual machine, docker should be running. Let's try:

```shell
$> docker ps
```

You should get a response that looks like this:

```shell
vagrant@vagrant-ubuntu-vivid-64:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

**Note**: if you get a response that looks like this:

```shell
FATA[0000] Get http:///var/run/docker.sock/v1.18/containers/json: dial unix /var/run/docker.sock: no such file or directory. Are you trying to connect to a TLS-enabled daemon without TLS?
```

simply restart the docker daemon in the vm by typing:

```shell
sudo service docker restart
```

### Starting containers
Let's start a container. To start jenkins within the vm, type:

```shell
docker run -d -v /home/vagrant/.m2:/root/.m2 -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 --name jenkins wouterla/docker-jenkins
```

See [https://docs.docker.com/reference/commandline/cli/](https://docs.docker.com/reference/commandline/cli/) for the documentation of the docker run command. What we are using here is:
- **-d** - run this container in the background
- **-v host-dir:container-dir** - mount a file or directory from the host (our vm) to the docker container. We mount the pre-filled maven repository, to avoid having to download the internet, and we mount the docker socket so jenkins will be able to start other containers.
- **-p host-port:container-port** - expose a port from the container to the outside
- **--name a-name** - a name we can use to refer to this container
- **repository/name:tag** - the name/location of the docker image

Now that we've started jenkins, we can check that it is running by typing:

```shell
docker ps
```

again, this time we should get something like:

```shell
vagrant@vagrant-ubuntu-vivid-64:~$ docker ps
CONTAINER ID        IMAGE                            COMMAND                CREATED             STATUS              PORTS                    NAMES
27c0e62bfbaa        wouterla/docker-jenkins:latest   "/bin/sh -c 'java -j   23 seconds ago      Up 22 seconds       0.0.0.0:8080->8080/tcp   jenkins
```

Now you can access jenkins by opening [http://localhost:9080](http://localhost:9080). We are not accessing the docker image, or port, directly. There is yet another level of port forwarding used to link the vagrant vm to your local network. Check the Vagrantfile to see how that's done. We are forwarding port 8080 on the vagrant machine to port 9080 on your local machine. And 8081->9081, 8082->9082, 8083->9083.

But this jenkins is still empty. No job have been defined yet. We will not be adding any jobs or configuration to jenkins by hand. To see how jobs are defined, have a look at the definitions in [roles/jenkins-jobs/jobs/jobs.yml](roles/jenkins-jobs/jobs/jobs.yml).

Those jobs are packaged in a separate docker image, together with the means to add them tdocker run --link jenkins:jenkins wouterla/docker-jenkins-job-builder o jenkins: [http://docs.openstack.org/infra/jenkins-job-builder/](jenkins-job-builder). A few jobs are pre-packaged, and you can add them to jenkins by running:

```shell
docker run --link jenkins:jenkins wouterla/docker-jenkins-job-builder
```

You can see that we have a new switch to the docker 'run' command, here:
- **--link container-name:alias** - we link an existing, running, container to the new one, and give it a name. For our current purposes, this means that the jenkins container's ip address will be added to the 'hosts' file of the new container with the hostname 'jenkins'.

When this container is run, you see the output of the main process (`jenkins-jobs`) on the command-line. This process runs it course and then returns, stopping the container.

Now, you can see three pre-defined jobs in jenkins, 'petclinic-start', 'petclinic-test' and 'done'. Start 'petclinic-start', and switch to the 'pipelines' view to see the basic pipeline working.

### Adding jobs
To add a job to our build pipelins, we need a new job-template, and to call that template from our project:x:

```yaml
- job-template:
    name: '{name}-package'
    builders:
      - maven-target:
          goals: '{goals}'
```

Note that we don't have to do anything to configure the git repository, since that is all coming from the defaults.

```yaml
- '{name}-package':
    goals: 'install'
    pipeline-stage: 'build'
    next-job: 'done'
```

Don't forget to also update the `next-job` from the test job to point to this new 'petclinic-package' job!

### Building containers
To build a new version of the jenkins-job-builder container, we need to use the docker build command. The script [build_docker_jenkins_job_builder.sh](build_docker_jenkins_job_builder.sh) shows all the steps, but the only one specific to building the container is:

```shell
docker build -t wouterla/docker-jenkins-job-builder .
```

Again, we see the format of the 'tag', comprising of the repository (wouterla), the name (docker-jenkins-job-builder) and the tag (not given, so defaulting to 'latest'). This form of the command assumes all related files are in the current directory (the '.' at the end). See the full documentation [https://docs.docker.com/reference/commandline/cli/#build](on the docker site).

In the context of this workshop, simply run the script.

```shell
./build_docker_jenkins_job_builder.sh
```

Then, re-run the job-builder container to add the new job to jenkins:

```shell
docker run --link jenkins:jenkins wouterla/docker-jenkins-job-builder
```

### Creating a Dockerfile
To be able to deploy the demo app, we need to complete the Dockerfile. The Dockerfile in your [spring-petclinic/docker](spring-petclinic/docker) directory is incomplete. It specifies the base image (docker-base) that contains usefull things, like a java runtime. To make it install the jetty-runner app, and run our petclinit example application from the war generated by the maven install goal, change it to:

```docker
FROM wouterla/docker-base
MAINTAINER Wouter Lagerweij <wouter@lagerweij.com>

# Normally we'd retrieve the jetty-runner jar directly from the internet,
# but we want to make sure we don't overtax conference wifi, so it's included
# in the image
# RUN curl -L http://repo2.maven.org/maven2/org/mortbay/jetty/jetty-runner/8.1.9.v20130131/jetty-runner-8.1.9.v20130131.jar -o jetty-runner.jar

RUN mkdir -p /opt/jetty
WORKDIR /opt/jetty
ADD jetty-runner.jar ./

ADD petclinic.war ./

CMD java -jar jetty-runner.jar petclinic.war
```

### Add the building of the docker image to the jenkins pipeline
For this we need to have the contents of the build_docker_petclinic.sh script within the jenkins-job-builder yaml. In other circumstances we could also call the existing script, or even add the building of the docker image to maven using [https://github.com/spotify/docker-maven-plugin](the maven docker plugin), but for the purposes of understanding what's going on in this process, we'll make it explicit:

```yaml
- job-template:
    name: '{name}-create-docker-image'
    builders:
      - maven-target:
          goals: 'clean install'
      - shell: |
           #!/bin/bash
          set -v
          set -e

          echo "Copying docker files"
          cp docker/* target/

          echo "Running docker"
          cd target/
          docker build -t wouterla/docker-petclinic .

           #echo "Pushing docker image to repository"
           #docker push wouterla/docker-jenkins
```

Note the use of the pipe ('|') symbol to include multiple lines of pre-formatted code. A default yaml feature.

Note that we're not pushing the image to the repository. You'd need to login, and have a fast internet connection to do so. Adding this job-template to our project is similar to our previous change. The project will now look somewhat like this:

```yaml
jobs:
  - '{name}-start':
      pipeline-stage: 'build'
      next-job: 'petclinic-test'
  - '{name}-test':
      goals: 'test'
      pipeline-stage: 'build'
      next-job: 'petclinic-package'
  - '{name}-package':
      goals: 'install'
      pipeline-stage: 'build'
      next-job: 'petclinic-create-docker-image'
  - '{name}-create-docker-image':
      pipeline-stage: 'build'
      next-job: 'done'
```

### Deploy the container from our pipeline
Now that we've built our container for the petclinic, it's time to deploy it on a 'test environment'!

We can deploy the container using the docker run command in another shell builder. Since I'd like to be able to deploy to a 'production environment' as well, we do a little parametrisation, and use a macro for the builder:

```yaml
- builder:
    name: deploy
    builders:
      - shell: |
          #!/bin/bash
          set -v
          set +e #the next step can return error code if no container is running
          docker kill {name}-{env} && docker rm {name}-{env}
          set -e
          docker run -d -p {external-port}:{internal-port} --name {name}-{env} wouterla/docker-{name}

- job-template:
    name: '{name}-deploy-test'
    builders:
      - deploy:
          name: '{name}'
          env: '{env}'
          external-port: '{external-port}'
          internal-port: '{internal-port}'
```

Using different ports allows us to deploy multiple copies of the same container on one docker node. In real life, we'd probable be more comfortable using different nodes for production and test, and perhaps set a 'DOCKER_HOST' variable for each environment, or use ansible's docker module to start the containers on different hosts.

**Note**: We have to pass-through the parameters explicitly, even though they have the same name in the project, template and macro. This is a feature (?) of jenkins job builder that I've not been able to work around.

The project should not contain something like:

```yaml
- project:
    name: petclinic
    gitrepo: 'spring-petclinic'
    branch: 'master'
    internal-port: '8080'
    jobs:
      ...
      - '{name}-create-docker-image':
          pipeline-stage: 'build'
          next-job: 'petclinic-deploy-test'
      - '{name}-deploy-test':
          pipeline-stage: 'test'
          external-port: '8081'
          env: 'test'
          next-job: 'done'
```

Since the internal port is always the same, we can define that one on a project level.

Also, not that we now have set the `pipeline-stage` to `test`, since we're actually deploying to a test environment.

### A test?
Since this is a demo, we don't have to run any real integration tests here. On the other hand, before we deploy to 'production', it would be nice to know that our container actually started successfully. So let's put in a very simple test:

```yaml
- builder:
    name: integration-test
    builders:
      - shell: |
          #!/bin/bash
          set -v
          set -e
          URL=http://{host}:{external-port}/vets.html
          sleep 10
          curl --retry 10 --retry-max-time 10 --retry-delay 1 --output /dev/null --silent --head --fail ${{URL}}

- job-template:
    name: '{name}-test-integration-test'
    builders:
      - integration-test:
          host: '{host}'
          external-port: '{external-port}'
```

### Production
Now we can add a production stage. We can easily copy the -test job-templates, and fill in the environment and ports for production. We could probably do this with a little less duplication by employing the job-group concept from job builder, but within the confines of the workshop, we'll stick to copy-past.

```yaml
- job-template:
    name: '{name}-deploy-production'
    builders:
      - deploy:
          name: '{name}'
          env: '{env}'
          external-port: '{external-port}'
          internal-port: '{internal-port}'
```

```yaml
- project:
    name: petclinic
    gitrepo: 'spring-petclinic'
    branch: 'master'
    internal-port: '8080'
    host: '10.0.2.15'
    jobs:
      - '{name}-start':
          pipeline-stage: 'build'
          next-job: 'petclinic-test'
      - '{name}-test':
          goals: 'install'
          pipeline-stage: 'build'
          next-job: 'petclinic-create-docker-image'
      - '{name}-create-docker-image':
          pipeline-stage: 'build'
          next-job: 'petclinic-deploy-test'
      - '{name}-deploy-test':
          pipeline-stage: 'test'
          external-port: '8081'
          env: 'test'
          next-job: 'petclinic-test-integration-test'
      - '{name}-test-integration-test':
          pipeline-stage: 'test'
          external-port: '8081'
          env: 'test'
          next-job: '{name}-deploy-production'
      - '{name}-deploy-production':
          pipeline-stage: 'production'
          external-port: '8082'
          env: 'production'
          next-job: 'petclinic-production-integration-test'
      - '{name}-production-integration-test':
          pipeline-stage: 'production'
          external-port: '8082'
          env: 'production'
          next-job: 'done'
```

### Another service?
A good exercise would be to add another service to this system. Since most java services would use the same build scripts, and only different names for the docker image (and different git repository and ports), in many cases it would be enough to simply add a new project, and re-use all the existing job-templates.

For the workshop context, you could try to deploy a different branch of the petclinic code. There is a branch 'some-branch' available to do this with.
