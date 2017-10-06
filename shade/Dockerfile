ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install requirements for add-on
RUN apk add --no-cache nano vim curl alpine-sdk python3 python3-dev py3-pip jq git git-perl openssh libressl-dev libxml2-dev libxslt-dev libjpeg-turbo-dev libffi-dev eudev-dev autoconf automake libtool
RUN pip3 install --upgrade setuptools
RUN pip3 install --upgrade cython


WORKDIR /data

COPY libcoap.sh /
RUN chmod a+x /libcoap.sh
RUN /libcoap.sh

COPY tinydtls.sh /
RUN chmod a+x /tinydtls.sh
RUN /tinydtls.sh

COPY aiocoap.sh /
RUN chmod a+x /aiocoap.sh
RUN /aiocoap.sh

COPY motd /etc/

COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh" ]
