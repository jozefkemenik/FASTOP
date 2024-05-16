# stage 1: base setup
FROM python:3.11.1
WORKDIR /workspace/python
RUN echo alias ll=\'ls -la --color=auto\' >> ~/.bashrc

RUN apt-get update && \
    apt-get install -y vim dos2unix

ARG FASTOP_API_KEY

ENV FASTOP=/workspace
ENV PYTHONPATH=/workspace/python/lib
ENV X13PATH=/workspace/python/hicp/pyhicp/tools
ENV FASTOP_API_KEY=${FASTOP_API_KEY}

# stage 2: create .venv and instal dependencies
COPY ./fastop/python/requirements.txt .
RUN python -m venv .venv
RUN . .venv/bin/activate && \
    pip install -r requirements.txt && \
    deactivate

# stage 3: copy sources
COPY ./fastop/python .
# fdms
COPY ./fdmsstar/fdms ./fdmsstar/fdms
# remove the scripts folder
RUN rm -rf ./scripts
RUN dos2unix ./fdmsstar/start-service.sh &&  \
    chmod +x ./fdmsstar/start-service.sh && \
    dos2unix ./sdmx/start-service.sh &&  \
    chmod +x ./sdmx/start-service.sh

# eucam
COPY ./eucam/fastop ./eucam
COPY ./eucam/EUCAM_light ./lib/EUCAM_light
RUN dos2unix ./eucam/start-service.sh &&  \
    chmod +x ./eucam/start-service.sh

# hicp
COPY ./hicp_python/server ./hicp
COPY ./hicp_python/pyhicp ./hicp/pyhicp/
RUN dos2unix ./hicp/start-service.sh &&  \
    chmod +x ./hicp/start-service.sh

# ameco-download
COPY ./ameco-download/server ./amecodownload
COPY ./ameco-download/pyameco ./amecodownload/pyameco
RUN dos2unix ./amecodownload/start-service.sh &&  \
    chmod +x ./amecodownload/start-service.sh

# neer
COPY ./neer_py/server ./neer
COPY ./neer_py/eer ./neer/eer/
RUN dos2unix ./neer/start-service.sh &&  \
    chmod +x ./neer/start-service.sh

# update endpoints
RUN sed -i 's/localhost:3101/da:3101/g; s/localhost:3103/dashboard:3103/g; s/localhost:3210/dfm:3210/g; s/localhost:3260/fdms:3260/g; s/localhost:3105/cs:3105/g; s/localhost:3110/task:3110/g; s/localhost:3290/bcs:3290/g; s/localhost:3501/sdmx:3501/g; s/localhost:3505/ad:3505/g; s/localhost:3507/neer:3507/g' ./lib/fastoplib/config.py
