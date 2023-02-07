#!/bin/bash

SYS_PHP_VER=8.1
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
../../run_composer create-project laravel/laravel="9.*" .
../../run_npm i
mv docker-compose.yml docker-compose.yml.nouse
echo "# SYSTEM PHP VERSION" >> .env
echo "SYS_PHP_VER=8.1" >> .env

ln -s ../../run_* .

mkdir .vscode
cp ../../.vscode/src.vscode.launch.json .vscode/launch.json

# backend nuxt
./run_npx --y nuxi init resources/backend
cp -a ../../nuxt3_init/backend.nuxt.config.ts resources/backend/nuxt.config.ts
echo "# SYSTEM PHP VERSION" > resources/backend/.env
echo "SYS_PHP_VER=8.1" >> resources/backend/.env
ln -s ../../run_npm resources/backend/
cd resources/backend
./run_npm i
sed -i 's/"dev": "nuxt dev",/"dev": "nuxt dev --port=3000",/gi' package.json
cd ../../

# frontend nuxt
./run_npx --y nuxi init resources/frontend
cp -a ../../nuxt3_init/frontend.nuxt.config.ts resources/frontend/nuxt.config.ts
echo "# SYSTEM PHP VERSION" > resources/frontend/.env
echo "SYS_PHP_VER=8.1" >> resources/frontend/.env
ln -s ../../run_npm resources/frontend/
cd resources/frontend
./run_npm i
sed -i 's/"dev": "nuxt dev",/"dev": "nuxt dev --port=3001",/gi' package.json
cd ../../

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
echo "    include /etc/nginx/conf.d/inc/php8.1_laravelApiNuxt3.conf;" >> "$NGCONFPATH"
echo "}" >> "$NGCONFPATH"

# nginx restart
docker container restart web_nginx

echo "Remember to add \"127.0.0.1 ${SRC}\" to the system host file at last line."
echo "Nuxt3 frontend project is location ${SRC}/resource/frontend, "
echo "      backend project is location ${SRC}/resource/backend, "
echo "      and start each nuxt3 project by \"./run_npm run dev\"."
echo "Finished."