#!/bin/bash

echo "=== ОЧИСТКА SWARM КЛАСТЕРА ==="

echo "1. Удаление тестовых сервисов..."
docker exec swarm-manager docker service rm nginx-test 2>/dev/null || true

echo "2. Остановка и удаление контейнеров..."
docker-compose -f docker-compose-swarm.yml down --volumes --remove-orphans

echo "3. Удаление сетей..."
docker network prune -f

echo "4. Удаление volumes..."
docker volume prune -f

echo "5. Удаление dangling образов..."
docker image prune -f

echo "=== ОЧИСТКА ЗАВЕРШЕНА ==="
