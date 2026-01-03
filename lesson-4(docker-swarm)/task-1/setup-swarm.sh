#!/bin/bash
set -e 

echo "=== Создание Docker Swarm-кластера ==="
echo "Хостовая система: $(uname -a)"
echo "Docker версия: $(docker --version)"
echo "Docker Compose версия: $(docker-compose --version)"

# 1. Полная очистка
echo "1. Полная очистка предыдущих запусков..."
docker-compose -f docker-compose-swarm.yml down --volumes --remove-orphans 2>/dev/null || true
docker network prune -f
docker volume prune -f

# 2. Запуск контейнеров
echo "2. Запуск контейнеров DinD..."
if ! docker-compose -f docker-compose-swarm.yml up -d; then
    echo "Ошибка при запуске контейнеров"
    exit 1
fi

# 3. Функция проверки готовности Docker демона
wait_for_docker() {
    local container=$1
    local timeout=60
    local start_time=$(date +%s)
    
    echo "Ожидание Docker демона в $container..."
    
    while true; do
        # Проверяем, запущен ли контейнер
        if ! docker ps | grep -q "$container"; then
            echo "Контейнер $container не запущен"
            return 1
        fi
        
        # Пробуем выполнить команду docker info внутри контейнера
        if docker exec "$container" docker info > /dev/null 2>&1; then
            local elapsed=$(( $(date +%s) - start_time ))
            echo "✓ Docker в $container готов через ${elapsed} секунд"
            return 0
        fi
        
        # Проверяем таймаут
        if [ $(date +%s) -gt $(( start_time + timeout )) ]; then
            echo "✗ Таймаут ожидания Docker в $container"
            return 1
        fi
        
        echo "  Ждем... ($(date +%H:%M:%S))"
        sleep 5
    done
}

# 4. Ожидаем запуск Docker демонов
echo "3. Ожидание запуска Docker демонов..."
for container in swarm-manager swarm-worker1 swarm-worker2; do
    wait_for_docker "$container"
done

# 5. Инициализация Swarm
echo "4. Инициализация Swarm на manager..."
# Получаем внутренний IP адрес менеджера
MANAGER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' swarm-manager)
echo "IP адрес manager: $MANAGER_IP"

# Пробуем несколько вариантов инициализации
echo "Пробуем инициализировать Swarm..."
if docker exec swarm-manager docker swarm init --advertise-addr "$MANAGER_IP" --listen-addr "$MANAGER_IP"; then
    echo "✓ Swarm инициализирован с advertise-addr: $MANAGER_IP"
elif docker exec swarm-manager docker swarm init --advertise-addr eth0; then
    echo "✓ Swarm инициализирован с advertise-addr: eth0"
elif docker exec swarm-manager docker swarm init; then
    echo "✓ Swarm инициализирован без указания адреса"
else
    echo "Проверяем текущее состояние Swarm..."
    docker exec swarm-manager docker info | grep -i swarm
    exit 1
fi

# 6. Получаем токен
echo "5. Получение токена для workers..."
JOIN_TOKEN=$(docker exec swarm-manager docker swarm join-token worker -q)
if [ -z "$JOIN_TOKEN" ]; then
    echo "Ошибка: не удалось получить токен"
    docker exec swarm-manager docker swarm join-token worker
    exit 1
fi
echo "Токен для workers: $JOIN_TOKEN"

# 7. Присоединяем workers
echo "6. Присоединение workers..."
docker exec swarm-worker1 docker swarm join --token "$JOIN_TOKEN" "$MANAGER_IP:2377"
docker exec swarm-worker2 docker swarm join --token "$JOIN_TOKEN" "$MANAGER_IP:2377"

# 8. Проверка
echo "7. Проверка кластера..."
echo ""
echo "=== СПИСОК НОД SWARM ==="
docker exec swarm-manager docker node ls

echo ""
echo "=== ИНФОРМАЦИЯ О SWARM ==="
docker exec swarm-manager docker info | grep -A 10 "Swarm"

echo ""
echo "=== ТЕСТОВЫЙ СЕРВИС ==="
docker exec swarm-manager docker service create --name nginx-test --replicas 2 -p 8080:80 nginx:alpine
sleep 5
docker exec swarm-manager docker service ls

echo ""
echo "=== КЛАСТЕР УСПЕШНО СОЗДАН! ==="
echo ""
echo "КОМАНДЫ ДЛЯ УПРАВЛЕНИЯ:"
echo "  Просмотр нод:          docker exec swarm-manager docker node ls"
echo "  Просмотр сервисов:     docker exec swarm-manager docker service ls"
echo "  Проверить тестовый Nginx: curl http://localhost:8080"
echo "  Удалить тестовый сервис: docker exec swarm-manager docker service rm nginx-test"
echo ""
echo "Для очистки выполните: ./cleanup.sh"