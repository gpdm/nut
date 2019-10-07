# nut

This is dockerized [Network UPS Tools](https://networkupstools.org/).

# Motivation

I did this, because my Raspberry Pi died.
As I was fed up with doing the manual config all over again, I started building these Docker images.
Yes I know, there's already other NUT Dockers around, but somehow they didn't reflect the way I imagined it to be :-)
 
## nut-upsd

The UPS daemon docker image, which provides UPS device polling capability.

## nut-webui

Last but not least, the webui, which provides realtime information and statistics on the UPS overall condition.


# TO DO

* provide alternative builds for ARMv6 to run on Raspberry Pi (my original motivation was to do this)
* support for Docker compose
