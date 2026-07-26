#!/bin/bash
# deploy.sh - установка на чистую Ubuntu 24.04 для локальной VM (VirtualBox)

set -e  

echo "=== НАЧАЛО РАЗВЕРТЫВАНИЯ ПРОЕКТА НА ЛОКАЛЬНОЙ VM ==="

# 0. Настройка VM
echo "0. Обновление системы..."
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl git wget

# 1. Устанавливаем Docker
echo "1. Установка Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
else
    echo "Docker уже установлен"
fi

# 2. Добавляем пользователя в группу docker
echo "2. Настройка прав пользователя..."
sudo usermod -aG docker $USER

# 3. Проверяем установку
echo "3. Проверка установки Docker..."
docker --version
docker compose version

# 4. Скачиваем проект (ЗАМЕНИТЕ НА СВОЙ ФОРК)
echo "4. Клонирование репозитория..."
cd /opt
REPO_URL="https://github.com/YOUR_USERNAME/YOUR_REPO.git"  # ЗАМЕНИТЕ НА СВОЙ РЕПОЗИТОРИЙ
REPO_DIR="less-3-docker"

if [ -d "$REPO_DIR" ]; then
    echo "Проект уже существует, обновляем..."
    cd $REPO_DIR
    git pull
else
    echo "Клонируем репозиторий..."
    git clone $REPO_URL $REPO_DIR
    cd $REPO_DIR
fi

# 5. Создаем .env для переменных
echo "5. Создание .env файла..."
cat > .env << 'ENVFILE'
MYSQL_ROOT_PASSWORD=strong_root_password_123
MYSQL_DATABASE=netology
MYSQL_USER=netology_user
MYSQL_PASSWORD=netology_password_456
ENVFILE

# 6. Проверяем наличие необходимых файлов
echo "6. Проверка файлов проекта..."
ls -la
if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
    echo "Docker Compose файл найден"
else
    echo "ОШИБКА: Docker Compose файл не найден!"
    exit 1
fi

# 7. Запускаем проект
echo "7. Запуск Docker Compose..."
docker compose up -d

# 8. Ждем запуска
echo "8. Ожидание запуска сервисов (30 секунд)..."
sleep 30

# 9. Проверяем статус
echo "9. Проверка статуса контейнеров..."
docker compose ps

# 10. Проверяем работу локально
echo "10. Тестирование приложения локально..."
LOCAL_SUCCESS=false
for i in {1..10}; do
    echo "Попытка $i/10: Проверка http://localhost:8090"
    if curl -s -f -L http://localhost:8090 > /dev/null; then
        echo "УСПЕХ! Приложение работает локально"
        echo "Пробуем получить ответ..."
        curl -s -L http://localhost:8090 | head -c 500
        echo ""
        LOCAL_SUCCESS=true
        break
    else
        echo "Еще не готово, ждем 5 секунд..."
        sleep 5
    fi
done

if [ "$LOCAL_SUCCESS" = false ]; then
    echo "ВНИМАНИЕ: Не удалось подключиться к localhost:8090"
    echo "Проверяем логи контейнеров..."
    docker compose logs --tail=50
fi

# 11. Определяем IP-адреса
echo "11. Определение сетевых интерфейсов..."
echo "Сетевые интерфейсы:"
ip addr show | grep inet | grep -v "127.0.0.1" | grep -v "::1"

# Для VirtualBox обычно используется NAT или Bridged адаптер
# Выводим несколько возможных IP
echo ""
echo "Возможные IP-адреса для проверки:"
if command -v hostname &> /dev/null; then
    HOST_IP=$(hostname -I | awk '{print $1}')
    echo "1. Основной IP: $HOST_IP"
fi

# Пытаемся получить внешний IP (работает если есть интернет)
echo ""
echo "12. Проверка внешней доступности (если NAT настроен правильно)..."
EXTERNAL_IP=$(curl -s --max-time 3 ifconfig.me || echo "не удалось определить")

if [ "$EXTERNAL_IP" != "не удалось определить" ]; then
    echo "Внешний IP адрес: $EXTERNAL_IP"
    echo ""
    echo "Для проверки на check-host.net выполните:"
    echo "1. Откройте https://check-host.net/check-http"
    echo "2. В поле для проверки введите: http://$EXTERNAL_IP:8090"
    echo "3. Или перейдите по прямой ссылке:"
    echo "   https://check-host.net/check-http?host=$EXTERNAL_IP:8090"
else
    echo "Не удалось определить внешний IP"
    echo "Для локальной VM в VirtualBox:"
    echo "1. Настройте сетевой адаптер как 'Сетевой мост' (Bridged Adapter)"
    echo "2. Или используйте проброс портов (Port Forwarding)"
    echo "3. Перезапустите VM и выполните скрипт снова"
fi

echo ""
echo "13. Команды для проверки цепочки трафика:"
echo "    # Проверить все контейнеры"
echo "    docker ps -a"
echo ""
echo "    # Проверить логи nginx"
echo "    docker compose logs nginx"
echo ""
echo "    # Проверить логи HAProxy"
echo "    docker compose logs haproxy"
echo ""
echo "    # Проверить логи FastAPI"
echo "    docker compose logs fastapi"
echo ""
echo "    # Выполнить SQL-запрос (из задания)"
echo "    docker exec mysql-db mysql -uroot -pstrong_root_password_123 -e \""
echo "    show databases;"
echo "    use netology;"
echo "    show tables;"
echo "    SELECT * from requests LIMIT 10;\""

echo ""
echo "=== РАЗВЕРТЫВАНИЕ ЗАВЕРШЕНО ==="
echo ""
echo "ВАЖНО для выполнения задания:"
echo "1. Замените в скрипте REPO_URL на ваш реальный форк-репозиторий"
echo "2. Для локальной VM настройте проброс портов в VirtualBox:"
echo "   - Зайдите в настройки VM"
echo "   - Сеть > Дополнительно > Проброс портов"
echo "   - Добавьте правило:"
echo "     Хост: 8090 -> Гость: 8090 (TCP)"
echo "3. После настройки проверьте на check-host.net"