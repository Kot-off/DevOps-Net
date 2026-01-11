#  ЗАДАНИЕ 3: Docker Compose конфигурация

##  Цель задания
1. Изучить файл "proxy.yaml"
2. Создать файл compose.yaml с подключением proxy.yaml через include
3. Описать сервисы web и db с фиксированными IP-адресами
4. Запустить проект локально и протестировать работу
5. Выполнить SQL-запросы к базе данных

##  Требования к конфигурации

### Сервис web (FastAPI приложение):
- Образ: собирается из Dockerfile.python ИЛИ из Yandex Container Registry
- Сеть: bridge-сеть "backend" с IP 172.20.0.5
- Рестарт: всегда перезапускаться в случае ошибок
- Переменные: ENV-переменные для подключения к MySQL
- Зависимость: зависит от сервиса db

### Сервис db (MySQL 8):
- Образ: mysql:8
- Сеть: bridge-сеть "backend" с IP 172.20.0.10
- Рестарт: явно перезапуск в случае ошибок
- Переменные: ENV-переменные для создания БД и пользователя
- Данные: volume для сохранения данных

## Файлы в папке
- `compose.yaml` - основная конфигурация Docker Compose
- `proxy.yaml` - конфигурация proxy сервисов (nginx + haproxy)
- `.env` - секретные переменные окружения
- `nginx.conf` - конфигурация Nginx
- `haproxy.cfg` - конфигурация HAProxy

## Команды 
```bash
# Запуск проекта:
docker compose up -d

# Проверка статуса контейнеров:
docker compose ps

# Проверка работы приложения:
curl -L http://127.0.0.1:8090

# SQL-запросы
docker exec -ti mysql-db mysql -uroot -pstrong_root_password_123

# Остановка проекта
docker compose down

# Так же команды:
# Просмотр логов
docker compose logs

# Проверка каждого сервиса
docker compose logs web
docker compose logs db
docker compose logs nginx
docker compose logs haproxy

# Перезапуск
docker compose down
docker compose up -d
```