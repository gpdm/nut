FROM bitnami/minideb

MAINTAINER Gianpaolo Del Matto "buildmaint@phunsites.net"
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.schema-version="1.0" \
    org.label-schema.description="This is the nut-webui docker image, which implements the web-based UI for Network UPS Tools (NUT)" \
    org.label-schema.name=nut-webui \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url=https://github.com/gpdm/nut/tree/master/nut-webui

ENV SSL_PRIVATE_KEY= \
    SSL_CERTIFICATE=

RUN apt-get update && \
    apt-get install -y nut-cgi fcgiwrap nginx-light openssl ssl-cert busybox && \
    apt-get auto-remove && \
    apt-get clean

COPY files/startup.sh /startup.sh
COPY files/healthcheck.sh /healthcheck.sh
COPY files/etc/nginx/sites-available/nut-default-tcp80 files/etc/nginx/sites-available/nut-default-tcp443 /etc/nginx/sites-available/

# rename included config files to .sample, bail out with failure if /etc/nut would not exist
RUN [ -d /etc/nut ] && find /etc/nut/ -type f -regex '.*\.conf$' -exec mv {} {}.sample \; || false

# disable default website in nginx, bail out with failure if the file would not exist
RUN [ -f /etc/nginx/sites-enabled/default ] && rm /etc/nginx/sites-enabled/default || false

# register our default tcp-80 website instead
RUN ln -s /etc/nginx/sites-available/nut-default-tcp80 /etc/nginx/sites-enabled/nut-default-tcp80

RUN chmod 700 /startup.sh /healthcheck.sh

ENTRYPOINT ["/startup.sh"]

HEALTHCHECK --interval=10s --timeout=5s \
    CMD /healthcheck.sh

EXPOSE 80
EXPOSE 443
