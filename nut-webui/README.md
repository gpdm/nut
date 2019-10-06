# nut-upsd

This is the **nut-upsmon** docker image, which implements the monitoring for the upsd daemon from https://networkupstools.org/.

## how to use

pull as usual:

> docker pull

then run it:

> docker run -p 80:80 -p 443:443 -v /path/to/nut-config:/etc/nut <name-tbd> 


## configuration

As this docker runs only the upsmon daemon, 
you only need these configuration files:

* [upsset.conf](https://networkupstools.org/docs/man/upsset.conf.html)
* [hosts.conf](https://networkupstools.org/docs/man/hosts.conf.html)
* [upsstats.html](https://networkupstools.org/docs/man/upsstats.html.html)
* [upsstats-single.html](https://networkupstools.org/docs/man/upsstats.html.html)

This docker image cannot be configured through environment variables.
You have to use a config volume as shown:

1. create the *upsset.conf*, *hosts.conf*, *upsstats.html* and *upsstats-single.html* config files with your favorite editor
2. store them into a permanent config directory, e.g. /data/dockers/nut-upsd/config
3. when running the container, point it mount the config directory as a volume, e.g.
   `-v /data/dockers/nut-upsd/config:/etc/nut`

**The container will fail to start when no volume is mounted, or not all needed files are present!**

Some sample config files are provided for your conventience in the [master repository](https://github.com/gpdm/nut/tree/master/nut-webui/files/etc/nut).
You may use them as a starting point, however I recommed to have a indepth look at the official
[Network UPS Tools](https://networkupstools.org/) documentation.

