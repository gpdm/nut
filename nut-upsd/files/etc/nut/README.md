# sample configs for nut-upsd docker image

This is a few sample configs for the nut-upsd docker image.
These are used for explanatory and illustration purposes only.
There is absolutely no guarantee they fit your particular purpose,
nor where they made with any special security in mind.

Please note that proper permissions must be applied,
or startup failures will occur.

So on your host, whereever your location of **/path/to/nut-config**,
ensure that permissions bit are set to 0400, and uid and gid are set
to 1000 and 1001 respetively.

```
cd /path/to/nut-config
chmod 0440 ups.conf upsd.conf upsd.users
chown 100:101 ups.conf upsd.conf upsd.users
```

You use this examples at your own risk.
I strongly recommend to go through the documentation at
[Network UPS Tools](https://networkupstools.org/).
