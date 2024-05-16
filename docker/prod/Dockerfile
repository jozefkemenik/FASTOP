FROM ecfin/ecfin_dev:latest

ARG service

WORKDIR /workspace/code/$service
COPY . ./

RUN export http_proxy=$http_proxy && \
    export https_proxy=$http_proxy && \
    npm install --production && \
    unset http_proxy && \
    unset https_proxy

