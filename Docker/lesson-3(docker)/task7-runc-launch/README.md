# ЗАДАНИЕ 7: Запуск контейнера через runC

## Цель задания
1. Запустить контейнер напрямую через runC без Docker/containerd
2. Создать OCI-совместимый bundle (rootfs + config.json)
3. Настроить namespaces и изоляцию
4. Запустить простое приложение в контейнере

## Требования
- Установить runc на Ubuntu 24.04
- Экспортировать rootfs из Docker образа alpine:latest
- Создать корректный config.json для OCI runtime
- Запустить контейнер через runc run
- Предоставить скриншоты всех этапов

## Файлы в папке
- config.json - OCI runtime конфигурация
- rootfs/ - корневая файловая система контейнера
- README.md - эта инструкция

## Команды
```bash
# Устанавливаем runc
sudo apt update
sudo apt install -y runc

# Создаем рабочую директорию
mkdir -p task7-runc
cd task7-runc
mkdir -p rootfs

# Экспортируем rootfs из Docker образа alpine
docker pull alpine:latest
docker create --name temp-alpine alpine:latest
docker export temp-alpine -o alpine.tar
tar -xf alpine.tar -C rootfs/
docker rm temp-alpine

# Создаем базовый config.json
sudo runc spec --rootless

# Редактируем config.json для простого теста
cat > config.json << 'EOF'
{
    "ociVersion": "1.0.2",
    "process": {
        "terminal": false,
        "user": {"uid": 0, "gid": 0},
        "args": ["echo", "Hello from runC container!"],
        "env": ["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"],
        "cwd": "/"
    },
    "root": {"path": "rootfs"},
    "hostname": "runc-test",
    "linux": {
        "namespaces": [
            {"type": "pid"},
            {"type": "network"},
            {"type": "ipc"},
            {"type": "uts"},
            {"type": "mount"}
        ]
    }
}
EOF

# Запускаем контейнер через runc
sudo runc run mycontainer

# Создаем Python приложение для запуска
cat > rootfs/app.py << 'EOF'
#!/usr/bin/env python3
print("=== Python Application in runC ===")
print(f"Container ID: runc-python-test")
print(f"Current directory: {os.getcwd()}")
import os
print(f"Process ID: {os.getpid()}")
print(f"Hostname: {os.uname().nodename}")
print("=== End ===")
EOF

# Создаем config для Python приложения
cat > config-python.json << 'EOF'
{
    "ociVersion": "1.0.2",
    "process": {
        "terminal": true,
        "user": {"uid": 0, "gid": 0},
        "args": ["python3", "/app.py"],
        "env": [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "PYTHONUNBUFFERED=1"
        ],
        "cwd": "/"
    },
    "root": {"path": "rootfs"},
    "hostname": "python-runc",
    "linux": {
        "namespaces": [
            {"type": "pid"},
            {"type": "network"},
            {"type": "ipc"},
            {"type": "uts"},
            {"type": "mount"}
        ]
    }
}
EOF

# Запускаем Python приложение в runc
sudo runc run --bundle . python-container

# Просмотр запущенных контейнеров runc
sudo runc list

# Запуск контейнера в фоновом режиме
sudo runc run -d --bundle . background-container

# Выполнение команды в запущенном контейнере
sudo runc exec background-container ps aux

# Остановка контейнера
sudo runc kill background-container SIGTERM

# Удаление контейнера
sudo runc delete background-container
```