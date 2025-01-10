## ViPNet Client 4 
_(клиент на базе Ubuntu или Debian)_

### Подготовка к сборке образа.

Скачать дистрибутив с сайта [infotecs.ru](https://infotecs.ru/downloads/all/vipnet-client-4u.html) для версии Linux x64 и положить его в папку app

Подготовить файл 

Подготовить файл переменных ```.env```

```sh
KEYFILE_PASS=""
WEB_HEALTHCHECK=""
HEALTHCHECK_CMD=""
DNS_SERVER=""
INSTALL_DEB_PACKAGE="" # если нужна сборка
```
Варианты ```HEALTHCHECK_CMD```
```
# проверка через пинг
ping -c 4 ${WEB_HEALTHCHECK}
```

```
# проверка через web
curl -o /dev/null -s -w "%{http_code}\n" https://${WEB_HEALTHCHECK}
```
### Docker Build

```sh
docker build \
-t coralhl/vipnetclient:ubuntu \
--build-arg INSTALL_DEB_PACKAGE=vipnetclient_ru_amd64_4.15.0-26717.deb \
--no-cache .
```
или
```sh
docker build \
-t coralhl/vipnetclient:debian -f Dockerfile.deb \
--build-arg INSTALL_DEB_PACKAGE=vipnetclient_ru_amd64_4.15.0-26717.deb \
--no-cache .
```

### Docker-compose ```docker-compose.yml```

```docker
version: '3.8'

services:
    vpn:
        image: coralhl/vipnetclient:debian
        container_name: vipnet
        cap_add:
            - net_admin
        env_file:
            - ./.env
        tmpfs:
            - /run
            - /tmp
        restart: unless-stopped
        privileged: true
        security_opt:
            - label:disable
        stdin_open: true
        tty: true
        volumes:
            - /dev/net:/dev/net:z
            - ./app/key.dst:/vipnet/key.dst
    service:
        image: ubuntu
        depends_on: 
            vpn:
                condition: service_healthy
        network_mode: "service:vpn"
        restart: unless-stopped
```


[Main Project](https://github.com/gseldon/vipnet-client)
