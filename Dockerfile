# build pdfact
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y maven git

WORKDIR /
RUN git clone https://github.com/ad-freiburg/pdfact.git
WORKDIR pdfact

RUN mvn install -DskipTests

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


# install flask app
WORKDIR /app
COPY ./requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .
ENTRYPOINT ["python3"]
CMD ["app.py"]
