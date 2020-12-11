############################################################
# Dockerfile to deploy BIMserver on Tomcat
# Based on Ubuntu x64
############################################################

FROM ubuntu
MAINTAINER px3l@tuta.io

# Initial OS setup

RUN apt-get update
RUN apt-get -y install software-properties-common && \
	add-apt-repository -y ppa:openjdk-r/ppa
RUN apt-get -y update && apt-get -y install \
	openjdk-8-jdk \
	git \
	ant \
	wget
RUN echo "Europe/Madrid" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

################## BEGIN INSTALLATION ######################

# Create Tomcat root directory, set up users and install Tomcat

RUN mkdir /opt/tomcat
RUN groupadd tomcat
RUN useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
RUN http://apache.mirror.anlx.net/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61-deployer.tar.gz \
	-O /tmp/apache-tomcat-8.5.60.tar.gz
RUN tar xvf /tmp/apache-tomcat-8.5.60.tar.gz -C /opt/tomcat --strip-components=1
RUN rm -f /tmp/apache-tomcat-8.5.60.tar.gz

# Remove ROOT, docs, examples, host-manager and manager contexts
RUN rm -rf /opt/tomcat/webapps/ROOT 
RUN rm -rf /opt/tomcat/webapps/docs
RUN rm -rf /opt/tomcat/webapps/examples
RUN rm -rf /opt/tomcat/webapps/host-manager
RUN rm -rf /opt/tomcat/webapps/manager

## xeokit-bim-viewer 
RUN git clone https://github.com/nachomanzano/xeokit-bim-viewer.git /opt/tomcat/webapps/xeokit-bim-viewer
## xeokit-sdk
RUN git clone https://github.com/nachomanzano/xeokit-sdk.git /opt/tomcat/webapps/xeokit-sdk

# Set permissions for group and user to install BIMserver and edit conf

RUN chgrp -R tomcat /opt/tomcat/conf
RUN chmod g+rwx /opt/tomcat/conf
RUN chmod g+r /opt/tomcat/conf/*
RUN chown -R tomcat /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/
RUN chown -R tomcat /opt && chown -R tomcat /opt/tomcat/webapps
RUN chmod a+rwx /opt && chmod a+rwx /opt/tomcat/webapps

# Download BIMserver into /webapps for autodeploy

RUN wget https://github.com/opensourceBIM/BIMserver/releases/download/v1.5.182/bimserverwar-1.5.182.war \
	-O /opt/tomcat/webapps/ROOT.war

# Set environment paths for Tomcat

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
ENV CATALINA_HOME=/opt/tomcat
ENV JAVA_OPTS="-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"
ENV CATALINA_OPTS="-Xms3G -Xmx3G -server -XX:+UseParallelGC"

# Add roles and increase file size for webapps to 500Mb

#ADD ./web.xml /opt/tomcat/webapps/manager/WEB-INF/web.xml
ADD ./run.sh /opt/run.sh

##################### INSTALLATION END #####################

USER tomcat
EXPOSE 8080
ENTRYPOINT ["bash", "/opt/run.sh"]