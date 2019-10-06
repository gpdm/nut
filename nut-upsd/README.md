# nut-upsd

This is the **nut-upsd** docker image, which implements the UPS drivers and the upsd daemon from https://networkupstools.org/.

## how to use

pull as usual:

```
docker pull gpdm/nut-upsd[:<tag>]
```

tags:
* **latest** for most recent (but potentially most broken / unstable) build
* other version-specific tags (if any) for frozen / stable builds

then run it as follows:

```
docker run -d \
   -p 3493:3493 \
   -v /path/to/nut-config:/etc/nut \
   gpdm/nut-upsd[:<tag>] 
```


## configuration

### main config for upsd

As this docker runs only the UPS drivers and the upsd daemon itself,
you only need these configuration files:

* [ups.conf](https://networkupstools.org/docs/man/nut.conf.html)
* [upsd.conf](https://networkupstools.org/docs/man/upsd.conf.html)
* [upsd.users](https://networkupstools.org/docs/man/upsd.users.html)


This docker image cannot be configured through environment variables.
You have to use a config volume as shown:

1. create the *ups.conf*, *upsd.conf* and *upsd.users* config files with your favorite editor
2. store them into a permanent config directory, e.g. /data/dockers/nut-upsd/config
3. when running the container, point it mount the config directory as a volume, e.g.
   `-v /data/dockers/nut-upsd/config:/etc/nut`

**The container will fail to start when no volume is mounted, or not all needed files are present!**

Some sample config files are provided for your conventience in the [master repository](https://github.com/gpdm/nut/tree/master/nut-upsd/files/etc/nut).
You may use them as a starting point, however I recommed to have a indepth look at the official
[Network UPS Tools](https://networkupstools.org/) documentation.


## device mapping

In order for the ups monitoring to work, you have to map your device tree into the docker container.


