#!/bin/sh
#
#  Provided to you under the terms of the Simplified BSD License.
#  
#  Copyright (c) 2019. Gianpaolo Del Matto, https://github.com/gpdm, <delmatto _ at _ phunsites _ dot _ net>
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

SSL_PRIVATE_KEY=${SSL_PRIVATE_KEY:-"private/ssl-cert-snakeoil.key"}
SSL_CERTIFICATE=${SSL_CERTIFICATE:-"certs/ssl-cert-snakeoil.pem"}
sslCfgVolume="/etc/ssl"
sslCfgFiles="${SSL_PRIVATE_KEY} ${SSL_CERTIFICATE}"
nginxCertificatesConf="/etc/nginx/snippets/tls-certificates.conf"
nginxSslWebsiteConf="nut-default-tcp443"
nutCfgVolume="/etc/nut"
nutCfgFiles="hosts.conf upsset.conf upsstats-single.html upsstats.html"

echo "*** NUT web server startup ***"

# bail out if the config volume is not mounted
grep ${nutCfgVolume} /proc/mounts >/dev/null ||
	{ printf "ERROR: It does not look like the config volume is mounted to %s.\nHave a look at the README for instructions.\n" ${nutCfgVolume}; exit; }
grep ${sslCfgVolume} /proc/mounts >/dev/null ||
	printf "WARN: It does not look like the config volume is mounted to %s.\nHave a look at the README for instructions on how to use individual certificates.\nWe will use self-signed certificates for HTTPS." ${sslCfgVolume};

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

	# check if key and cert are valid, and match each other
	#
	privateKeyModulus=`openssl rsa -noout -modulus -in ${sslCfgVolume}/${SSL_PRIVATE_KEY} 2> /dev/null`
	certificateModulus=`openssl x509 -noout -modulus -in ${sslCfgVolume}/${SSL_CERTIFICATE} 2> /dev/null`

	if [ -z "${privateKeyModulus}" -o -z "${certificateModulus}" ]; then
		printf "ERROR: private key and/or certificate seem invalid. Please check file contents.\n"
		exit
	fi

	if [ "`echo ${privateKeyModulus} | openssl md5`" != "`echo ${certificateModulus} | openssl md5`" ]; then
		printf "ERROR: private key and certificate modulus mismatch. The two files may not belong together.\n"
		exit
	fi

	# bail out if private key is too permissive
	stat -c '%a' ${sslCfgVolume}/${SSL_PRIVATE_KEY} | grep -Ee '^(4|6)(4|0)0$' > /dev/null
	if [ "$?" != "0" ]; then
		printf "ERROR: private key '%s' mode is too permissive.\n" ${sslCfgVolume}/${SSL_PRIVATE_KEY}
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
