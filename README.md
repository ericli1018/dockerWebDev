# Docker Web Dev


## Usage

To get started, make sure you have [Docker installed](https://docs.docker.com/docker-for-mac/install/) on your system, and then clone this repository.

Make sure you have been created `.env` file from `.env.example` to specify current user's UID and GID.

Next, navigate in your terminal to the directory you cloned this, and spin up the containers for the web server by running `docker-compose up -d --build`.

After that completes, follow the steps from the [README.md](/README.md) file to get your Laravel project added in (or create a new blank one).

Bringing up the Docker Compose network with `nginx` instead of just using `up`, ensures that only our site's containers are brought up at the start, instead of all of the command containers as well. The following are built for our web server, with their exposed ports detailed:

- **nginx** - `:8080`
- **nginx with ssl** - `:8443`
- **mysql5.7** - `:3306`
- **mysql8.0** - `:3307`
- **mysql8.2** - `:3308`

Three additional containers are included that handle Composer, NPM, NPX, YARN, PHP, and Artisan commands *without* having to have these platforms installed on your local computer. Use the following command examples from your project root, modifying them to fit your particular use case.
Using .env variable `SYS_PHP_VER` to specify PHP version. PHP support version 8.3, 8,1 and 7.4(default).
Example for php version 8.1 is `echo "SYS_PHP_VER=8.1" >> .env`.

- `./run_composer update`
- `./run_npm run dev`
- `./run_npx --version`
- `./run_php --version`
- `./run_artisan migrate`
- `./run_yarn --version`

## Persistent MySQL Storage

By default, whenever you bring down the Docker network, your MySQL data will be removed after the containers are destroyed. If you would like to have persistent data that remains after bringing containers down and back up, do the following:

1. Create a `mysql` folder in the project root, alongside the `nginx` and `web` folders.
2. Under the mysql service in your `docker-compose.yml` file, add the following lines:

```
volumes:
  - ./mysql/{sql_ver}:/var/lib/mysql
```
sql_ver=8.2, 8.0, 5.7

## Store Git Password for vscode sync to git

Edit git.info then do the following command:

```
windows:
type git.info | git credential-manager approve

linux:
git config --global credential.helper 'store --file ~/.git-credentials'
cat git.info | git credential approve

mac os:
cat git.info | git credential-osxkeychain store
```

## Quick create web project.

```
cd ./web
```

### laravel8

```
./mklaravel8.sh <example.local>
```

### laravel9

```
./mklaravel9.sh <example.local>
```

### laravel9 api + nuxt3

```
./mklaravel9ApiNuxt3.sh <example.local>
```

### laravel10

```
./mklaravel10.sh <example.local>
```

### wordpress

```
./mkwordpress.sh <example.local> <database name>
```

## Put your laravel project source folder to ./web folder. Create file link into your project root path.

```
mkdir ./web/<example.local>
cd ./web/<example.local>
ln -s ../../run_* .
```

## For pure php8.1 prject, create nginx configure file and copy below code to your <example.local>.conf file and restart nginx.

```
server {
    server_name <example.local>
    listen 80;
    #listen 443 ssl;
    #ssl_certificate /var/www/html/<example.local>/ssl_cert.pem;
    #ssl_certificate_key /var/www/html/<example.local>/ssl_key.pem;
    error_log  /var/log/nginx/error.<example.local>.log;
    access_log /var/log/nginx/access.<example.local>.log;
    root /var/www/html/example.local/public;
    include /etc/nginx/conf.d/inc/php8.1.conf;
}
```

## For laravel api + nuxt3 project, create nginx configure file and copy below code to your <example.local>.conf file and restart nginx.

```
server {
    server_name <example.local>
    listen 80;
    #listen 443 ssl;
    #ssl_certificate /var/www/html/<example.local>/ssl_cert.pem;
    #ssl_certificate_key /var/www/html/<example.local>/ssl_key.pem;
    error_log  /var/log/nginx/error.<example.local>.log;
    access_log /var/log/nginx/access.<example.local>.log;
    root /var/www/html/example.local/public;
    include /etc/nginx/conf.d/inc/php8.1_laravelApiNuxt3.conf;
}
```

## Use PHP Intelephone

In each project folder (./web/<example.local>), create `./web/<example.local>/.vscode/settings.json` file and add the following script.

```
{
    ...
    "php.validate.executablePath": "run_php"
    ...
}
```

## Use PHP XDebug in vscode

In each project folder (./web/<example.local>), create `./web/<example.local>/.vscode/launch.json` file and add the following script.

```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for XDebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "hostname": "0.0.0.0",
            "pathMappings": {
                "/var/www/html/${workspaceFolderBasename}": "${workspaceFolder}"
            },
            "ignore": [
                "**/vendor/**/*.php"
            ],
            "log": false,
            "xdebugSettings": {
                "max_children": 10000,
                "max_data": 10000,
                "show_hidden": 1
            }
        },
        {
            "name": "Launch currently open script",
            "type": "php",
            "request": "launch",
            "program": "${file}",
            "cwd": "${fileDirname}",
            "port": 9003,
            "hostname": "0.0.0.0"
        }
    ]
}
```

## Use Google Chrome Plugin "HostAdmin" App to edit host file

- MacOS path `/etc/hosts`
- Windows path `C:\windows\system32\drivers\etc\hosts`

Add the following script to the last line, then save.

```
127.0.0.1 <example.local>
```

Follow these steps to start your docker and browser http://<example.local>:8080 or https://<example.local>:8443