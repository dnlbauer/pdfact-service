# STEP 1: build pdfact
FROM ubuntu:20.04
LABEL maintainer="Daniel Bauer <dev@dbauer.me>"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y maven git

WORKDIR /
# TODO freeze revision?
RUN git clone https://github.com/ad-freiburg/pdfact.git --depth 1 --branch master
WORKDIR pdfact

RUN mvn install -DskipTests

# STEP 2: run service
FROM alpine:latest
WORKDIR /

# copy build artifact
COPY --from=0 /pdfact/bin/pdfact.jar pdfact.jar

# get java
RUN apk update \
    && apk upgrade \
    && apk add --no-cache openjdk11-jre
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk"

# get python
RUN apk add --no-cache python3 \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip setuptools

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install flask app
WORKDIR /app
COPY ./requirements.txt .
RUN pip install -r requirements.txt

COPY app.py gunicorn_conf.py ./

ENTRYPOINT ["gunicorn", "--conf", "gunicorn_conf.py", "--bind", "0.0.0.0:80", "app:app"]
