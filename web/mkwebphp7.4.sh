#!/bin/bash

SYS_PHP_VER=7.4
export SYS_PHP_VER

SRC=$1

if [ "$SRC" = "" ]; then
  echo "Folder can not empty"
  exit
fi

if [ -d "${SRC}" ]; then
  echo "Folder is exist. ${SRC}"
  exit
fi

mkdir -p "${SRC}"
cd "${SRC}"

mkdir .vscode
cp ../../.vscode/src.vscode.launch.json .vscode/launch.json

# nginx conf
cd ../../
NGCONFPATH="nginx/conf.d/${SRC}.conf"
echo "server {" > "$NGCONFPATH"
echo "    server_name ${SRC}" >> "$NGCONFPATH"
echo "    listen 80;" >> "$NGCONFPATH"
echo "    #listen 443 ssl;" >> "$NGCONFPATH"
echo "    #ssl_certificate /var/www/html/${SRC}/ssl_cert.pem;" >> "$NGCONFPATH"
echo "    #ssl_certificate_key /var/www/html/${SRC}/ssl_key.pem;" >> "$NGCONFPATH"
echo "    error_log  /var/log/nginx/error.${SRC}.log;" >> "$NGCONFPATH"
echo "    access_log /var/log/nginx/access.${SRC}.log;" >> "$NGCONFPATH"
echo "    root /var/www/html/${SRC};" >> "$NGCONFPATH"
echo "    include /etc/nginx/conf.d/inc/php7.4.conf;" >> "$NGCONFPATH"
echo "}" >> "$NGCONFPATH"

# nginx restart
docker container restart web_nginx

echo "Remember to add \"127.0.0.1 ${SRC}\" to the system host file at last line."
echo "MySql database"
echo "      location is \"mysql5.7\", "
echo "      account is \"root\" and password is \"secret\"."

echo "Finished."