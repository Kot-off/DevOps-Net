# Task-1: Создание Docker Swarm-кластера на локальной машине Ubuntu

## Цель задания
1. Создать Docker Swarm-кластер из 3 нод на одной локальной машине Ubuntu 24 с использованием Docker контейнеров в качестве нод.

## Описание
- Cоздаём виртуальный Swarm-кластер на локальной машине с использованием Docker-in-Docker (DinD). (позволяет создать реалистичный Swarm кластер на одной машине без затрат на облачные ресурсы.)
- Сделам через скрипты

## Файлы в папке
- docker-compose-swarm.yml - Docker Compose файл для создания Swarm-кластера
- setup-swarm.sh - Bash-скрипт для автоматизации создания кластера
- cleanup.sh - Скрипт для очистки окружения

## Команды

```bash
# Подготовка окружения
mkdir -p ~/lesson-4-docker-swarm/task-1
cd ~/lesson-4-docker-swarm/task-1

# Установка Docker
apt install git curl
curl -fsSL get.docker.com -o get-docker.sh
chmod +x get-docker.sh
./get-docker.sh

# Права и создание кластера
chmod +x setup-swarm.sh cleanup.sh
./setup-swarm.sh

# Проверяем список нод
docker exec swarm-manager docker node ls
# Проверяем информацию о Swarm
docker exec swarm-manager docker info | grep -A 10 "Swarm"

# Создаем overlay сеть
docker exec swarm-manager docker network create --driver overlay my-overlay

# Проверяем созданные сети
docker exec swarm-manager docker network ls

# Запускаем тестовый сервис
docker exec swarm-manager docker service create --name nginx-test --network my-overlay --replicas 2 nginx:alpine

# Проверяем сервисы
docker exec swarm-manager docker service ls
docker exec swarm-manager docker service ps nginx-test

#
./cleanup.sh
```