
# ЗАДАНИЕ 1: Создание Dockerfile.python

##  Цель задания
Создать Dockerfile для Python FastAPI приложения на основе образа `python:3.12-slim`.

## Требования
1. Использовать базовый образ `python:3.12-slim`
2. Использовать конструкцию `COPY . .` в Dockerfile
3. Создать `.dockerignore` файл для исключения ненужных файлов
4. Использовать команду: `CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]`
5. Протестировать корректность сборки

##  Файлы в папке
- `Dockerfile.python` - основной Dockerfile
- `.dockerignore` - исключение файлов из образа
- `main.py` - FastAPI приложение
- `requirements.txt` - зависимости Python
- `.gitignore` - исключение файлов из git

##  Команды
```bash
# Сборка Docker образа:
docker build -f Dockerfile.python -t python-app:latest .

# Проверка собранного образа:
docker images | grep python-app

# Тестовый запуск контейнера:
# Запуск в фоновом режиме
docker run -d --name test-app -p 5000:5000 python-app:latest

# Проверка логов
sleep 5
docker logs test-app

# Проверка работы приложения
curl http://localhost:5000

# Остановка тестового контейнера
docker stop test-app && docker rm test-app

# Проверка содержимого образа:
# Запуск интерактивного shell в контейнере
docker run -it --rm python-app:latest bash

# Внутри контейнера проверяем:
ls -la /app
python --version
pip list | grep -E "(fastapi|uvicorn|mysql)"
exit
```