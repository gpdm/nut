#!/bin/sh

sslCfgVolume="/etc/ssl"
sslCfgFiles="${SSL_PRIVATE_KEY} ${SSL_CERTIFICATE}"
nginxCertificatesConf="/etc/nginx/snippets/tls-certificates.conf"
nginxSslWebsiteConf="nut-default-tcp443"
nutCfgVolume="/etc/nut"
nutCfgFiles="hosts.conf upsset.conf upsstats-single.html upsstats.html"

echo "*** NUT web server startup ***"

# bail out if the config volume is not mounted
grep ${nutCfgVolume} /proc/mounts >/dev/null ||
	{ printf "ERROR: It does not look like the config volume is mounted to %s. Have a look at the README for instructions.\n" ${nutCfgVolume}; exit; }
grep ${sslCfgVolume} /proc/mounts >/dev/null ||
	printf "WARN: It does not look like the config volume is mounted to %s. Have a look at the README for instructions on SSL/TLS support.\n" ${sslCfgVolume};

# more sanity: make sure our config files stick around
for cfgFile in ${nutCfgFiles}; do
	[ -f "${nutCfgVolume}/${cfgFile}" ] && continue 
	printf "ERROR: config file '%s/%s' does not exist. You should create one, have a look at the README.\n" ${nutCfgVolume} ${cfgFile}
	exit
done

# more sanity: make sure our certificates stick around
for cfgFile in ${sslCfgFiles}; do
	[ -f "${sslCfgVolume}/${cfgFile}" ] && continue 
	printf "ERROR: SSL key/cert '%s/%s' does not exist. You should create one, have a look at the README.\n" ${sslCfgVolume} ${cfgFile}
	exit
done


# activate SSL support if keys are set
if [ ! -z "${SSL_PRIVATE_KEY}" -a ! -z "${SSL_CERTIFICATE}" ]; then

	# bail out if private key is too permissive
	if [ "`stat -c '%a' ${sslCfgVolume}/${SSL_PRIVATE_KEY}`" != "400" ]; then
		printf "ERROR: private key '%s' mode is too permissive. You should restrict to '0400' mask.\n" ${sslCfgVolume}/${SSL_PRIVATE_KEY}
		exit
	fi
	
	# dump the config file for nginx
	cat > ${nginxCertificatesConf} <<EOF 
        ssl_certificate ${sslCfgVolume}/${SSL_CERTIFICATE};
        ssl_certificate_key ${sslCfgVolume}/${SSL_PRIVATE_KEY};
EOF

	# finally, enable the SSL webservice
	ln -s /etc/nginx/sites-available/${nginxSslWebsiteConf} /etc/nginx/sites-enabled/${nginxSslWebsiteConf}

else
	printf "NOTICE: No SSL certificate and/or private key defined. Have a look at the README for instructions on enabling SSL/TLS support.\n"
fi


# run the fcgiwrap daemon
printf "Starting up the fcgiwrap daemon ...\n"
service fcgiwrap start || { printf "ERROR on daemon startup.\n"; exit; }

# run nginx
printf "Starting up the web server ...\n"
exec nginx -g 'daemon off;'
