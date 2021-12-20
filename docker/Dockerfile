FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

RUN pip3 install \
    setuptools \
    boto3 \
    botocore \
    awscli

CMD ["tail", "-f","/dev/null"]