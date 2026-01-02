mkdir -p /projects/devops-homework-5/task0-docker-check
cat > /projects/devops-homework-5/task0-docker-check/README.md << 'EOF'
# ЗАДАНИЕ 0: Проверка окружения Docker

## Цель задания
Убедиться что:
1. ❌ `docker-compose` (старая версия) НЕ установлен
2. ✅ `docker compose` (новая версия V2) версии не менее v2.24.X установлен

## Описание
В новых версиях Docker используется Docker Compose V2, который устанавливается как плагин к Docker CLI (`docker compose` без тире). Старая отдельная утилита `docker-compose` (с тире) не должна быть установлена.

## Команды для выполнения

### 1. Проверка отсутствия старого docker-compose:
```bash
docker-compose --version
docker compose version
docker -v
```

### Скачать:
```bash
   curl -fsSL https://get.docker.com -o get-docker.sh.
```
### Установить:
```bash
chmod +x get-docker.sh
sudo sh get-docker.sh
```