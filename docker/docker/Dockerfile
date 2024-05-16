FROM node:16.14

RUN export http_proxy=$http_proxy && \
    apt-get update && \
    apt-get install -y unzip libaio1 vim && \
    unset http_proxy
RUN mkdir /opt/oracle && mkdir /workspace

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_19_3
WORKDIR /opt/oracle

COPY instantclient-basiclite-linux.x64-19.3.0.0.0dbru.zip client.zip
COPY tnsnames.ora .
COPY package.json /workspace

RUN unzip client.zip && rm client.zip
RUN echo alias ll=\'ls -la --color=auto\' >> ~/.bashrc
RUN mv tnsnames.ora `ls -d instantclient*`/network/admin

WORKDIR /workspace
RUN export http_proxy=$http_proxy && \
    export https_proxy=$http_proxy && \
    npm install && \
    unset http_proxy && \
    unset https_proxy

WORKDIR /workspace/code
