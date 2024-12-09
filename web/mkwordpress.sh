#!/bin/bash

SYS_PHP_VER=8.1
SYS_MYSQL_VER=8.0
export SYS_PHP_VER
export SYS_MYSQL_VER

SRC=$1

if [ "$SRC" = "" ]; then
  echo "Folder can not empty"
  exit
fi

if [ -d "${SRC}" ]; then
  echo "Folder is exist. ${SRC}"
  exit
fi

DBNAME=$(echo "wp_$SRC" | sed s/[.]/_/g)

mkdir .vscode
cp -a ../../.vscode/src.vscode.launch.json .vscode/launch.json
cp -a ../../.vscode/src.vscode.settings.json .vscode/settings.json
sed -i 's/<docker-container>/php${SYS_PHP_VER}_dev/g' .vscode/settings.json

# wordpress
wget https://tw.wordpress.org/latest-zh_TW.tar.gz
tar xf latest-zh_TW.tar.gz --strip-components=1
rm -f latest-zh_TW.tar.gz

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
echo "    include /etc/nginx/conf.d/inc/php${SYS_PHP_VER}_wordpress.conf;" >> "$NGCONFPATH"
echo "}" >> "$NGCONFPATH"

# create database
./run_mysql -uroot -psecret -hmysql${SYS_MYSQL_VER} -e "'CREATE DATABASE \`$DBNAME\`;'"

# nginx restart
docker container restart web_nginx

echo "Remember to add \"127.0.0.1 ${SRC}\" to the system host file at last line."
echo "MySql database name is \"${DBNAME}\", "
echo "      location is \"mysql${SYS_MYSQL_VER}\", "
echo "      account is \"root\" and password is \"secret\"."

echo "Finished."