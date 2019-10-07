FROM alpine:edge

MAINTAINER Gianpaolo Del Matto "buildmaint@phunsites.net"
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.schema-version="1.0" \
    org.label-schema.description="This docker image implements Network UPS Tools (NUT) upsd daemon" \
    org.label-schema.name=nut-upsd \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url=https://github.com/gpdm/nut/tree/master/nut-upsd

# 'nut' package is only available from testing branch -- add it to the repo list
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk add --no-cache nut

# rename included config files to .sample, bail out with failure if /etc/nut would not exist
RUN [ -d /etc/nut ] && find /etc/nut/ -type f -exec mv {} {}.sample \; || false

COPY files/startup.sh /startup.sh

RUN chmod 700 /startup.sh

RUN mkdir -p /var/run/nut && \
    chown nut:nut /var/run/nut && \
    chmod 700 /var/run/nut

ENTRYPOINT ["/startup.sh"]

EXPOSE 3493
