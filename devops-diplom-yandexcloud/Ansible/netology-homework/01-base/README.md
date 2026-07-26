# Домашнее задание к занятию «Введение в Ansible»

##  Что было сделано
1. **Подготовка окружения:** Настроена связка Docker Desktop + WSL2. Развернуты контейнеры (Ubuntu, CentOS, Fedora) через `docker-compose`.
2. **Inventory:** Написан файл `inventory/prod.yml` с разделением хостов по группам (`deb`, `el`, `local`).
3. **Переменные (Vars):**
   - Изучены приоритеты переменных (`group_vars` vs `all`).
   - Настроены уникальные значения фактов для каждой группы хостов.
4. **Безопасность (Vault):**
   - Использован `ansible-vault` для шифрования файлов переменных в `group_vars/deb` и `group_vars/el`.
5. **Запуск:** Проведен успешный запуск плейбука на всех хостах с расшифровкой данных на лету.

##  Инструменты
- Ansible (Core 2.10+)
- Docker & Docker Compose
- WSL2 (Ubuntu Environment)

## Скриншоты
![Вывод](./img/1.png)

## Настройка и команды

1. Настройка WSL и Docker (Windows)
Если docker ps не работает внутри Ubuntu или "command not found":
Открыть Docker Desktop в Windows.
Settings (шестеренка) -> Resources -> WSL Integration.
Включить переключатель напротив Ubuntu.
Нажать Apply & Restart.

2. Команды для работы с WSL
``` PowerShell
wsl -l -v
# Вывод должен быть:
# * docker-desktop    Running    2
#   Ubuntu            Running    2

# Зайти в конкретный дистрибутив
wsl -d Ubuntu
```
  
3.   
```bash
# 1. Поднятие контейнеров
docker-compose up -d

# 2.
ansible-vault encrypt group_vars/deb/examp.yml group_vars/el/examp.yml

# 3. Запуск плейбука (потребуется ввод пароля vault)
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
```

---
