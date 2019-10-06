#!/bin/sh

nutCfgVolume="/etc/nut"
nutCfgFiles="ups.conf upsd.conf upsd.users"

echo "*** NUT upsd startup ***"

# bail out if the config volume is not mounted
grep ${nutCfgVolume} /proc/mounts >/dev/null ||
	{ printf "ERROR: It does not look like the config volume is mounted to %s. Have a look at the README for instructions.\n" ${nutCfgVolume}; exit; }

# more sanity: make sure our config files stick around
for cfgFile in ${nutCfgFiles}; do
	[ -f ${nutCfgVolume}/${cfgFile} ] && continue 
	printf "ERROR: config file '%s/%s' does not exist. You should create one, have a look at the README.\n" ${nutCfgVolume} ${cfgFile}
	exit
done

# initialize UPS driver
printf "Starting up the UPS drivers ...\n"
/usr/sbin/upsdrvctl start || { printf "ERROR on driver startup.\n"; exit; }

# run the ups daemon
printf "Starting up the UPS daemon ...\n"
exec /usr/sbin/upsd || { printf "ERROR on daemon startup.\n"; exit; }
