# Riak 2 pre 7
#
# VERSION       0.1.1

# NOTES
# This Dockerfile is only to create compiled Riak to be used within containers
# This will create riak_2.0.0pre7 version of Riak. 
# You should then use another Dockerfile in the dir to have smaller running Riak container
# - i can not guarantee if your git version could be broken or not!
# - Erlang R16B02 used
# - yokozuno is activated by default
# - please check erlang ./configure params and modify as needed

# Use the Ubuntu base image provided by dotCloud
FROM ubuntu:latest
MAINTAINER Gokhan Boranalp kunthar@gmail.com 

# Update the APT cache
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# Install and setup project dependencies
RUN apt-get install -y python-software-properties curl lsb-release openssh-server libc6-dev-i386 git build-essential libncurses5-dev openssl libssl-dev fop xsltproc unixodbc inetutils-ping telnet libpam0g-dev debhelper devscripts logrotate sudo dialog 

RUN mkdir -p /var/run/sshd
#RUN mkdir -p /var/log/supervisor

RUN locale-gen en_US en_US.UTF-8

#ADD ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo 'root:basho' | chpasswd

# Install (Bullsh*t) Oracle Java for yokozuno
RUN add-apt-repository -y ppa:webupd8team/java  && apt-get update -y && echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && apt-get install -y oracle-java7-installer

# Compile Erlang for Riak 
RUN mkdir -p /riak-base/erlang && cd /riak-base/erlang && wget http://www.erlang.org/download/otp_src_R16B02.tar.gz && tar -zxvf otp_src_R16B02.tar.gz && cd /riak-base/erlang/otp_src_R16B02 && ./configure --enable-threads --enable-smp-support --enable-kernel-poll --with-ssl --enable-sctp && make && make install

# Install Riak and prepare it to run
RUN cd /riak-base && git clone https://github.com/basho/riak.git -b release/2.0.0pre7 && cd riak && make package 

# Expose Protocol Buffers and HTTP interfaces
#EXPOSE 8087 8098 8069 22

CMD ["echo 'Chicken_is_ready_for_egg. Run_the_container_and_get_the_deb_file.'"]
