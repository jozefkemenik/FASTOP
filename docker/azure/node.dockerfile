# stage 1: base setup
FROM node:18.13
WORKDIR /workspace
RUN echo alias ll=\'ls -la --color=auto\' >> ~/.bashrc

ARG FASTOP_SECRET
ARG FASTOP_API_KEY

ENV FASTOP_SECRET=${FASTOP_SECRET}
ENV FASTOP_API_KEY=${FASTOP_API_KEY}
ENV NODE_ENV=AZURE

# stage 2: configure oracle instant client
WORKDIR /workspace
RUN apt-get update && \
    apt-get install -y unzip libaio1 vim

ENV ORACLE_BASE=/usr/lib/instantclient
ENV LD_LIBRARY_PATH=/usr/lib/instantclient
ENV TNS_ADMIN=/usr/lib/instantclient
ENV ORACLE_HOME=/usr/lib/instantclient

# stage 3: copy sources to the image
COPY ./fastop .

# stage 4: build node apps
WORKDIR /workspace/services
RUN npm install && \
    npm run build:lib && \
    npm run build

# stage 5: build angular apps
WORKDIR /workspace/frontend
RUN npm install && \
    npm run build:prod
