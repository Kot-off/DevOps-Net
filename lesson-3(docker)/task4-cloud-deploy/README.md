# ЗАДАНИЕ 4: Деплой на Yandex Cloud VM

## Цель задания
1. Запустить ВМ в Yandex Cloud (2 ГБ RAM)
2. Установить Docker на ВМ
3. Написать bash-скрипт для автоматического развертывания
4. Проверить доступность через check-host.net
5. Выполнить SQL-запросы на сервере

## Описание
Развертывание Docker Compose проекта на облачной виртуальной машине. Скрипт автоматизирует установку Docker, клонирование репозитория и запуск приложения. Проверка доступности через внешние сервисы.

## Файлы в папке
- `deploy.sh` - основной скрипт развертывания
- `README.md` - эта инструкция

## Команды
```bash
# Подключение к ВМ
ssh yc-user@<ВАШ_IP_ВМ>

# Запуск скрипта развертывания
# Скачиваем скрипт
curl -o deploy.sh https://raw.githubusercontent.com/ваш-username/devops-homework-5/main/task4-cloud-deploy/deploy.sh

# Делаем исполняемым
chmod +x deploy.sh

# Запускаем
sudo ./deploy.sh

# Проверка работы на сервере
# Проверка контейнеров
docker compose ps

# Локальная проверка
curl -L http://localhost:8090

# Проверка внешнего IP
curl -s ifconfig.me

# SQL-запросы на сервере
docker exec mysql-db mysql -uroot -pstrong_root_password_123 -e "
show databases;
use netology;
show tables;
SELECT * from requests LIMIT 10;"
```
