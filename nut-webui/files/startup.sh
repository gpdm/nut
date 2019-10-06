#!/bin/sh

cfgVolume="/etc/nut"
cfgFiles="hosts.conf upsset.conf upsstats-single.html upsstats.html"

echo "*** NUT web server startup ***"

# bail out if the config volume is not mounted
grep ${cfgVolume} /proc/mounts >/dev/null ||
	{ printf "ERROR: It does not look like the config volume is mounted to %s. Have a look at the README for instructions.\n" ${cfgVolume}; exit; }

# more sanity: make sure our config files stick around
for cfgFile in ${cfgFiles}; do
	[ -f ${cfgVolume}/${cfgFile} ] && continue 
	printf "ERROR: config file '%s/%s' does not exist. You should create one, have a look at the README.\n" ${cfgVolume} ${cfgFile}
	exit
done

# future enhancement: 
# activate the SSL webserver, when needed 
# - check env var
# - check cert files availability
# - enable the website configuration 

# run the fcgiwrap daemon
printf "Starting up the fcgiwrap daemon ...\n"
service fcgiwrap start || { printf "ERROR on daemon startup.\n"; exit; }

# run nginx
printf "Starting up the web server ...\n"
exec nginx -g 'daemon off;'
