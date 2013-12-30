# Riak 
#
# VERSION       0.1.1

# Riak 2 pre 7 compiled container. kunthar/riak

# Use the Ubuntu base image provided by dotCloud kunthar/riak
FROM ubuntu:latest
MAINTAINER Gokhan Boranalp kunthar@gmail.com

# Hack for initctl
# See: https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

# Update the APT cache
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y


RUN apt-get install -y language-pack-en
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

#Install dialog first!
RUN apt-get install -y dialog
 
# Install and setup project dependencies
RUN apt-get install -y lsb-release python-software-properties openssh-server supervisor sudo logrotate expect

#This line is for my additional packages. You can skip if you want.
#RUN apt-get install -y curl vim git htop munin-node socat ethtool net-tools netcat-openbsd telnet tcpdump bridge-utils 

RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

RUN echo 'root:basho' | chpasswd

# Install (Bullsh*t) Oracle Java for yokozuno
RUN add-apt-repository -y ppa:webupd8team/java  && apt-get update -y && echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && apt-get install -y oracle-java7-installer

ADD ./etc/supervisord.conf /etc/supervisor/supervisord.conf
ADD ./bin/riak_2.0.0pre7-1_amd64.deb /riak_2.0.0pre7-1_amd64.deb

ADD ./provision.sh /provision.sh

RUN dpkg -i riak_2.0.0pre7-1_amd64.deb

# Riak config settings
RUN echo "ulimit -n 4096" >> /etc/default/riak
RUN sed -i.bak 's/nodename = riak@127.0.0.1/nodename = riak@${RIAK_NODE_NAME}/' /etc/riak/riak.conf
RUN sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/riak/riak.conf
RUN sed -i.bak 's/anti_entropy = on/anti_entropy = off/' /etc/riak/riak.conf
RUN sed -i.bak 's/storage_backend = memory/storage_backend = bitcask/' /etc/riak/riak.conf
RUN sed -i.bak 's/search = off/search = on/' /etc/riak/riak.conf

RUN echo "[{riak_core, [{default_bucket_props, [{allow_mult, true}]}]}]." >> etc/riak/advanced.config

#RUN sudo /bin/bash provision.sh

# Hack for initctl
# See: https://github.com/dotcloud/docker/issues/1024
# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -s /bin/true /sbin/initctl

# Expose needed ports 
# Protobuf 8087, http 8098, solr port 8093, solr jmx 8985
EXPOSE 8087 8098 8093 8985 22

CMD ["/usr/bin/supervisord"]
