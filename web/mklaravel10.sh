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

DBNAME=$(echo "laravel_$SRC" | sed s/[.]/_/g)

mkdir -p "${SRC}"
cd "${SRC}"
../../run_composer create-project laravel/laravel="10.*" .
../../run_npm i
touch ssl_cert.pem
touch ssl_key.pem
sed -i "s/APP_URL=http:\/\/localhost/APP_URL=http:\/\/${SRC}/gi" .env
sed -i "s/DB_HOST=127.0.0.1/DB_HOST=mysql${SYS_MYSQL_VER}/gi" .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD=secret/gi' .env
sed -i 's/REDIS_HOST=127.0.0.1/REDIS_HOST=redis6/gi' .env
echo "# SYSTEM PHP VERSION" >> .env
echo "SYS_PHP_VER=${SYS_PHP_VER}" >> .env
cp -a .env .env.example

ln -s ../../run_* .

mkdir .vscode
cp -a ../../.vscode/src.vscode.launch.json .vscode/launch.json
cp -a ../../.vscode/src.vscode.settings.json .vscode/settings.json
sed -i "s/<docker-container>/php${SYS_PHP_VER}_dev/g" .vscode/settings.json

# create database
./run_mysql -uroot -psecret --skip-ssl -hmysql${SYS_MYSQL_VER} -e "'CREATE DATABASE \`$DBNAME\`;'"
./run_artisan migrate

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
echo "    root /var/www/html/${SRC}/public;" >> "$NGCONFPATH"
echo "    include /etc/nginx/conf.d/inc/php${SYS_PHP_VER}_laravel.conf;" >> "$NGCONFPATH"
echo "}" >> "$NGCONFPATH"

# nginx restart
docker container restart web_nginx

echo "MySql database"
echo "      host is \"mysql${SYS_MYSQL_VER}\", "
echo "      database is \"${DBNAME}\", "
echo "      account is \"root\" and password is \"secret\"."

echo "Remember to add \"127.0.0.1 ${SRC}\" to the system host file at last line."