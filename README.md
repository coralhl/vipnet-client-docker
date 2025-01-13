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
    container_name: vipnet-client
    env_file:
      - ./.env
    restart: unless-stopped
    privileged: true
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
    environment:
      - HEALTHCHECK_CMD=$HEALTHCHECK_CMD
      - DNS_SERVER=77.88.8.88,77.88.8.2
    volumes:
      - /etc/timezone:/etc/timezone:ro
      - ./app/key.dst:/vipnet/key.dst
      - ./app/data/:/vipnet/
    healthcheck:
      test: ${HEALTHCHECK_CMD}
      interval: 30s
      timeout: 10s
      retries: 10

    service:
        image: ubuntu
        depends_on: 
            vpn:
                condition: service_healthy
        network_mode: "service:vpn"
        restart: unless-stopped
```


[Main Project](https://github.com/gseldon/vipnet-client)
