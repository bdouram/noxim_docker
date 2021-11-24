FROM ubuntu:20.04

# Ubuntu dependencies
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install sudo -y && apt-get install wget -y && apt-get install git -y && apt-get install curl -y
RUN ln -s -T /usr/bin/make /usr/bin/gmake

#Source: https://askubuntu.com/questions/909277/avoiding-user-interaction-with-tzdata-when-installing-certbot-in-a-docker-contai
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install cmake -y


LABEL dev.bdouram.version="2020.02.21"
LABEL maintainer="Bruno D. Miranda"
LABEL licence="GPLv2" 
LABEL dev.bdouram.release-date="2021-11-24"

#noxim dependencies
RUN apt-get install build-essential -y
RUN apt-get install libyaml-cpp-dev -y
RUN apt-get install libboost-dev -y

# cloning noxim repository
RUN git clone https://github.com/davidepatti/noxim
WORKDIR /noxim/bin
RUN mkdir -p libs


# build yaml-cpp
WORKDIR /noxim/bin/libs
RUN git clone https://github.com/jbeder/yaml-cpp
WORKDIR /noxim/bin/libs/yaml-cpp
RUN git checkout -b r0.6.0 yaml-cpp-0.6.0
RUN mkdir -p lib
WORKDIR /noxim/bin/libs/yaml-cpp/lib
RUN cmake ..
RUN make

#build SystemC
WORKDIR /noxim/bin/libs
RUN wget http://www.accellera.org/images/downloads/standards/systemc/systemc-2.3.1.tgz
RUN tar -xzf systemc-2.3.1.tgz

WORKDIR /noxim/bin/libs/systemc-2.3.1
RUN mkdir -p objdir
WORKDIR /noxim/bin/libs/systemc-2.3.1/objdir
RUN export CXX=g++ && export CC=gcc
RUN ../configure
RUN make
RUN make install
WORKDIR /noxim/bin/libs/systemc-2.3.1/
RUN echo `pwd`/lib-* > systemc.conf && ln -sf `pwd`/systemc.conf /etc/ld.so.conf.d/noxim_systemc.conf
RUN ldconfig

WORKDIR /noxim/bin/
RUN make

RUN echo 'alias noxim="/noxim/bin/noxim"' >> ~/.bashrc
WORKDIR /home