
### **4. Задание 2: task2-yandex-registry/README.md**
```bash
mkdir -p /projects/devops-homework-5/task2-yandex-registry
cat > /projects/devops-homework-5/task2-yandex-registry/README.md << 'EOF'
#  ЗАДАНИЕ 2: Yandex Container Registry (*)

##  Цель задания
1. Создать Container Registry в Yandex Cloud с именем "test"
2. Настроить аутентификацию локального Docker
3. Собрать и загрузить образ с Python приложением
4. Просканировать образ на уязвимости

##  Описание задания
Yandex Container Registry (YCR) - это приватный Docker registry для хранения Docker образов. В этом задании нужно создать registry, загрузить в него собранный образ python-app и просканировать на уязвимости.

##  Команды для выполнения

### 1. Установка Yandex Cloud CLI:
```bash
# Добавление репозитория Yandex Cloud
curl https://storage.yandex-cloud.net/yandexcloud-yc/install.sh | bash

# Инициализация
yc init

# Проверка
yc --version

# Создание registry с именем "test"
yc container registry create --name test

# Получение информации
yc container registry get test

# Получение ID registry
yc container registry list

# Аутентификация Docker в Yandex Cloud
yc container registry configure-docker

# Проверка
docker login cr.yandex

# Сборка образа с тегом для YCR
docker build -t cr.yandex/<registry-id>/python-app:latest -f Dockerfile.python .

# Пуш образа в registry
docker push cr.yandex/<registry-id>/python-app:latest

# Проверка
yc container image list --registry-name test

# Сканирование через Yandex Cloud
yc container image scan cr.yandex/<registry-id>/python-app:latest

# Альтернативно через trivy
docker run --rm aquasec/trivy image cr.yandex/<registry-id>/python-app:latest
# Офф документация https://yandex.cloud/ru/docs/container-registry/operations/authentication?utm_referrer=https%3A%2F%2Fyandex.ru%2F

```
<!-- Или как в моём случае это моя VM развёрнутая в Oracle VirtualBox -->