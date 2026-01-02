#!/bin/bash
# deploy.sh - установка на чистую Ubuntu 24.04

set -e  

echo "=== НАЧАЛО РАЗВЕРТЫВАНИЯ ПРОЕКТА ==="

# 0. Настройка Vm
echo "0. Настройка Vm"
sudo apt update
sudo apt install -y curl git

# 1. Устанавливаем Docker
echo "1. Установка Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Добавляем пользователя в группу docker
echo "2. Настройка прав пользователя..."
sudo usermod -aG docker $USER

# 3. Проверяем установку
echo "3. Проверка установки Docker..."
docker --version
docker compose version

# 4. Скачиваем проект
echo "4. Клонирование репозитория..."
cd /opt
if [ -d "less-3-docker" ]; then
    echo "Проект уже существует, обновляем..."
    cd less-3-docker
    git pull
else
    echo "Клонируем репозиторий..."
    git clone https://github.com/ваш-username/ваш-репозиторий.git less-3-docker
    cd less-3-docker
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

# 7. Запускаем проект
echo "7. Запуск Docker Compose..."
docker compose up -d

# 8. Ждем запуска
echo "8. Ожидание запуска сервисов..."
sleep 30

# 9. Проверяем статус
echo "9. Проверка статуса контейнеров..."
docker compose ps

# 10. Проверяем работу
echo "10. Тестирование приложения..."
for i in {1..5}; do
    echo "Попытка $i:"
    if curl -s -L http://localhost:8090 > /dev/null; then
        echo "УСПЕХ! Приложение работает"
        curl -s -L http://localhost:8090 | head -c 200
        echo ""
        break
    else
        echo "Еще не готово, ждем..."
        sleep 5
    fi
done

# 11. Показываем внешний IP
echo "11. Внешний IP адрес сервера:"
EXTERNAL_IP=$(curl -s ifconfig.me)
echo "    $EXTERNAL_IP"
echo ""
echo "12. Ссылка для проверки через check-host.net:"
echo "    https://check-host.net/check-http?host=$EXTERNAL_IP:8090"
echo ""
echo "=== РАЗВЕРТЫВАНИЕ ЗАВЕРШЕНО ==="
