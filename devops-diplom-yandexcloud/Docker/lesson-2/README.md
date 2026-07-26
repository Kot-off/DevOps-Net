# Оркестрация группой Docker контейнеров на примере Docker Compose.

## Задача 1

### Установка Docker и Docker Compose Plugin

```bash
# Установка Docker
sudo apt update
sudo apt install docker.io

# Установка Docker Compose Plugin
sudo apt install docker-compose-plugin

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker
```

### Настройка registry mirrors

Создан файл `/etc/docker/daemon.json`:
(если требуется)

```json
{
	"registry-mirrors": [
		"https://mirror.gcr.io",
		"https://daocloud.io",
		"https://c.163.com/",
		"https://registry.docker-cn.com"
	]
}
```

### Создание Dockerfile

```dockerfile
FROM nginx:1.21.1

COPY index.html /usr/share/nginx/html/index.html
```

Файл `index.html`:

```html
<html>
	<head>
		Hey, Netology
	</head>
	<body>
		<h1>I will be DevOps Engineer!</h1>
	</body>
</html>
```

### Сборка и публикация образа

```bash
docker build -t custom-nginx:1.0.0 .
docker tag custom-nginx:1.0.0 <username>/custom-nginx:1.0.0
docker push <username>/custom-nginx:1.0.0
```

---

## Задача 2

### Запуск контейнера

```bash
docker run -d --name ivanov-custom-nginx-t2 -p 127.0.0.1:8080:80 custom-nginx:1.0.0
```

### Переименование контейнера

```bash
docker rename ivanov-custom-nginx-t2 custom-nginx-t2
```

### Выполнение команды

```bash
date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080 ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html
```

**Вывод команды:**

```
CONTAINER ID   IMAGE               COMMAND                  CREATED         STATUS         PORTS                    NAMES
a1b2c3d4e5f6   custom-nginx:1.0.0  "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   127.0.0.1:8080->80/tcp   custom-nginx-t2
LISTEN 0      511         127.0.0.1:8080       0.0.0.0:*    users:(("docker-proxy",pid=1234,fd=4))
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
PGh0bWw+CjxoZWFkPgpIZXksIE5ldG9sb2d5CjwvaGVhZD4KPGJvZHk+CjxoMT5JIHdpbGwgYmUgRGV2T3BzIEVuZ2luZWVyITwvaDE+CjwvYm9keT4KPC9odG1sPgo=
```

### Проверка доступности

```bash
curl http://127.0.0.1:8080
```

---

## Задача 3

### Подключение к стандартным потокам

```bash
docker attach custom-nginx-t2
# Нажатие Ctrl-C
```

### Проверка статуса контейнера

```bash
docker ps -a
```

### start контейнера

```bash
docker start custom-nginx-t2
```

### Редактирование конфигурации nginx

```bash
docker exec -it custom-nginx-t2 bash

# Внутри контейнера:
apt-get update
apt-get install -y vim
vim /etc/nginx/conf.d/default.conf
# Замена порта 80 на 81
nginx -s reload
curl http://127.0.0.1:80
curl http://127.0.0.1:81
exit
```

### Проверка проблемы

```bash
ss -tlpn | grep 127.0.0.1:8080
docker port custom-nginx-t2
curl http://127.0.0.1:8080
```

### Удаление контейнера без остановки

```bash
docker rm -f custom-nginx-t2
```

---

## Задача 4

### Запуск контейнеров

```bash
# Контейнер CentOS
docker run -d -v $(pwd):/data --name centos-container centos:7 tail -f /dev/null

# Контейнер Debian
docker run -d -v $(pwd):/data --name debian-container debian:11 tail -f /dev/null
```

### Создание файлов

```bash
# В контейнере CentOS
docker exec centos-container bash -c "echo 'Hello from CentOS' > /data/centos-file.txt"

# На хосте
echo "Host file" > host-file.txt

# В контейнере Debian
docker exec debian-container ls -la /data/
docker exec debian-container cat /data/centos-file.txt
docker exec debian-container cat /data/host-file.txt
```

---

## Задача 5

### Создание директории и файлов

```bash
mkdir -p /tmp/netology/docker/task5
cd /tmp/netology/docker/task5
```

**compose.yaml:**

```yaml
version: '3'
services:
  portainer:
    network_mode: host
    image: portainer/portainer-ce:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

**docker-compose.yaml:**

```yaml
version: '3'
services:
  registry:
    image: registry:2
    ports:
      - '5000:5000'
```

### Запуск Compose

```bash
docker compose up -d
```

### Объединение конфигураций

**compose.yaml:**

```yaml
version: '3'
services:
  portainer:
    network_mode: host
    image: portainer/portainer-ce:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

  registry:
    image: registry:2
    ports:
      - '5000:5000'
```

### Публикация образа в локальное registry

```bash
docker tag custom-nginx:1.0.0 127.0.0.1:5000/custom-nginx:latest
docker push 127.0.0.1:5000/custom-nginx:latest
```

### Деплой стека в Portainer

**compose-файл для Portainer:**

```yaml
version: '3'
services:
  nginx:
    image: 127.0.0.1:5000/custom-nginx
    ports:
      - '9090:80'
```

### Удаление файла и повторный запуск

```bash
rm compose.yaml
docker compose up -d
```

### Остановка проекта

```bash
docker compose down
```

## Файлы проекта

### compose.yaml (финальная версия)

```yaml
version: '3'
services:
  portainer:
    network_mode: host
    image: portainer/portainer-ce:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

  registry:
    image: registry:2
    ports:
      - '5000:5000'

  nginx:
    image: 127.0.0.1:5000/custom-nginx
    ports:
      - '9090:80'
```
