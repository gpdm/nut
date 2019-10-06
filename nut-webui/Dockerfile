FROM bitnami/minideb

RUN apt-get update && \
    apt-get install -y nut-cgi fcgiwrap nginx-light && \
    apt-get auto-remove && \
    apt-get clean

COPY files/startup.sh /startup.sh
COPY files/etc/nginx/sites-available/nut-default-tcp80 /etc/nginx/sites-available/nut-default-tcp80
COPY files/etc/nginx/sites-available/nut-default-tcp443 /etc/nginx/sites-available/nut-default-tcp443

# rename included config files to .sample, bail out with failure if /etc/nut would not exist
RUN [ -d /etc/nut ] && find /etc/nut/ -type f -regex '.*\.conf$' -exec mv {} {}.sample \; || false

# disable default website in nginx, bail out with failure if the file would not exist
RUN [ -f /etc/nginx/sites-enabled/default ] && rm /etc/nginx/sites-enabled/default || false

# register our default tcp-80 website instead
RUN ln -s /etc/nginx/sites-available/nut-default-tcp80 /etc/nginx/sites-enabled/nut-default-tcp80

RUN chmod 700 /startup.sh

ENTRYPOINT ["/startup.sh"]

EXPOSE 80
EXPOSE 443
