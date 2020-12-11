# BIMserver

Deploy BIMserver in a Docker container

#### BIMserver 1.5.63 remote

Deploys on a remote server with Ubuntux64:latest. The Dockerfile will install dependencies such as JDK and Tomcat and then install BIMserver into the webapps dir inside Tomcats home. Simply SSH into a server, install Docker with

```bash
$ wget -qO- https://get.docker.com/ | sh
```

```
docker build --tag bimserver-evoltia:1.0 .


and run the following (change username and password to your own choice):

```bash
$ docker run -d \
	-e TOMCAT_USER=xxx \
	-e TOMCAT_PASSWORD=xxx \
	-p 8080:8080 \
	--restart=always \
	px3l/bimserver
```

This will pull the 'latest' tagged image. For other tags please see Tags on Dockerhub. To use a specific tag, put `:TAGNAME` after the docker image at the end of the run command.

This exposes port 8080 of your host, so if you visit server:8080/BIMserver you will be able to then set up a BIMserver as desired.

#### BIMserver 1.5.63 local

Alternatively, `docker run` your local machine and then visit localhost:8080/BIMserver
