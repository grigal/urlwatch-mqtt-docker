#
# Dockerfile for urlwatch
#
FROM python:alpine
MAINTAINER Stephen Houser <stephenhouser@gmail.com>

RUN apk add -U ca-certificates \
               build-base \
               libxml2 \
               libxml2-dev \
               libxslt \
               libxslt-dev \
               make \
               python-dev \
               py-pip \
			   libffi-dev \
	           openssl-dev \
			   mosquitto-clients \
    && pip install urlwatch \
				   pyyaml \
				   minidb \
				   requests \
                   keyring \
				   appdirs \
                   lxml \
				   cssselect \
				   paho-mqtt \
    && apk del build-base \
               libxml2-dev \
               libxslt-dev \
			   libffi-dev \
               python-dev \
	           openssl-dev \
    && rm -rf /var/cache/apk/* \
    && echo '*/15 * * * * cd ~/.urlwatch && urlwatch' | crontab -

COPY urlwatch /root/.urlwatch
VOLUME /root/.urlwatch
WORKDIR /root/.urlwatch

CMD ["crond", "-f", "-L", "/dev/stdout"]
