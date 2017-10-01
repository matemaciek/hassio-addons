ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install requirements for add-on
RUN apk add --no-cache alpine-sdk python3 python3-dev py3-pip jq git openssh-server libressl-dev libxml2-dev libxslt-dev libjpeg-turbo-dev libffi-dev eudev-dev autoconf automake libtool
RUN pip3 install --upgrade setuptools


# Copy data for add-on
COPY coap_client.sh /
COPY run.sh /

WORKDIR /data

RUN chmod a+x /coap_client.sh
RUN chmod a+x /run.sh

RUN /coap_client.sh

CMD [ "/run.sh" ]
