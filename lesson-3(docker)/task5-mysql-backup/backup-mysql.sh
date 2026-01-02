#!/bin/bash
# Рабочий скрипт резервного копирования

set -e

BACKUP_DIR="/opt/backup"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql"

echo "=== РЕЗЕРВНОЕ КОПИРОВАНИЕ MYSQL ==="
echo "Время: $(date)"
echo "База: netology"

# Вариант A: Используем docker exec (самый надежный)
echo "Создание дампа через docker exec..."
docker exec mysql-db /usr/bin/mysqldump \
  --user=netology_user \
  --password=netology_password_456 \
  --databases netology \
  --default-auth=mysql_native_password \
  --single-transaction \
  --routines \
  --triggers \
  --events > "$BACKUP_FILE" 2>/dev/null

# Проверяем успешность
if [ $? -eq 0 ] && [ -s "$BACKUP_FILE" ]; then
    echo "✓ Дамп создан успешно"
    
    # Архивируем
    gzip "$BACKUP_FILE"
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}.gz" | cut -f1)
    
    # Удаляем старые бэкапы (оставляем 10)
    cd "$BACKUP_DIR"
    BACKUP_COUNT=$(ls -1 *.sql.gz 2>/dev/null | wc -l)
    
    if [ "$BACKUP_COUNT" -gt 10 ]; then
        echo "Удаляем старые бэкапы..."
        ls -t *.sql.gz | tail -n +11 | xargs --no-run-if-empty rm -f
    fi
    
    # Финальный результат
    FINAL_COUNT=$(ls -1 *.sql.gz 2>/dev/null | wc -l)
    echo ""
    echo "=== РЕЗУЛЬТАТ ==="
    echo "Файл: backup_${TIMESTAMP}.sql.gz"
    echo "Размер: $BACKUP_SIZE"
    echo "Всего бэкапов: $FINAL_COUNT"
    echo ""
    echo "Список бэкапов:"
    ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null | tail -5
    
else
    echo "✗ Ошибка создания дампа"
    
    # Вариант B: Пробуем с root пользователем
    echo "Пробуем с root пользователем..."
    docker exec mysql-db /usr/bin/mysqldump \
      --user=root \
      --password=strong_root_password_123 \
      --databases netology \
      --default-auth=mysql_native_password > "${BACKUP_FILE}_root.sql" 2>/dev/null
    
    if [ $? -eq 0 ] && [ -s "${BACKUP_FILE}_root.sql" ]; then
        mv "${BACKUP_FILE}_root.sql" "$BACKUP_FILE"
        gzip "$BACKUP_FILE"
        echo "✓ Дамп создан с root правами"
    else
        echo "✗ Все методы не сработали"
        rm -f "$BACKUP_FILE" "${BACKUP_FILE}_root.sql"
        exit 1
    fi
fi
