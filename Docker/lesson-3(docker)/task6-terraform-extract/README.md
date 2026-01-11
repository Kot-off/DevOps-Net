# Извлечение файлов из контейнера через Docker build

## Цель задания
1. Извлечь бинарник terraform из официального образа HashiCorp
2. Использовать только команду docker build и Dockerfile
3. Создать новый образ с извлеченным файлом
4. Продемонстрировать работу через скриншоты

## Требования
- Использовать многостадийную сборку (multi-stage build)
- Извлечь файл /bin/terraform из образа hashicorp/terraform:latest
- Поместить извлеченный файл в новый образ
- Показать версию terraform для проверки
- Предоставить скриншоты всех действий

## Файлы в папке
- Dockerfile.extract - Dockerfile для извлечения файла
- README.md - эта инструкция

## Команды
```bash
# Создаем Dockerfile для извлечения
cat > Dockerfile.extract << 'EOF'
FROM hashicorp/terraform:latest AS source

FROM alpine:latest
COPY --from=source /bin/terraform /extracted-terraform
CMD ["sh", "-c", "ls -la /extracted-terraform && /extracted-terraform --version"]
EOF

# Собираем образ с извлеченным файлом
docker build -f Dockerfile.extract -t terraform-extracted .

# Запускаем контейнер для проверки
docker run --rm terraform-extracted

# Создаем папку для извлечения на хост
mkdir -p extracted

# Запускаем контейнер с volume для копирования файла
docker run --rm -v $(pwd)/extracted:/output terraform-extracted sh -c "cp /extracted-terraform /output/"

# Проверяем извлеченный файл
ls -la extracted/
./extracted-terraform/terraform --version
```