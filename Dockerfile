FROM ubuntu:24.04
LABEL maintainer="coral xciii <coralhl@gmail.com>" \
      description="ViPNet Client 4 docker container based on Ubuntu Linux"
ARG INSTALL_DEB_PACKAGE

ENV WEB_HEALTHCHECK=${WEB_HEALTHCHECK}
ENV HEALTHCHECK_CMD=${HEALTHCHECK_CMD}
ENV INSTALL_DEB_PACKAGE=${INSTALL_DEB_PACKAGE}
ENV DNS_SERVER=${DNS_SERVER:-77.88.8.8}
ENV DEBUG_LEVEL=${DEBUG_LEVEL:-1}
ENV KEYFILE_PASS=${KEYFILE_PASS}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -o Acquire::Max-FutureTime=86400 update && \
    apt-get upgrade -y && \
    apt-get -fyq install cron curl iputils-ping procps && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh

WORKDIR /vipnet
COPY ./app/${INSTALL_DEB_PACKAGE} .

RUN mkdir -p /vipnet && \
    dpkg -i ${INSTALL_DEB_PACKAGE} && \
    rm -f ${INSTALL_DEB_PACKAGE}

HEALTHCHECK --interval=5s --timeout=30s --retries=10 \
    CMD ${HEALTHCHECK_CMD} || bash -c 'kill -s 15 -1 && (sleep 10; kill -s 9 -1)'

CMD ["bash", "/entrypoint.sh"]
