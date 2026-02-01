# Домашнее задание 04: Работа с ролями

## Описание
Плейбук разворачивает стек (Clickhouse + Vector + Lighthouse).
 **Примечание:** В рамках данного выполнения роли `vector-role` и `lighthouse-role` хранятся локально в папке `roles/` данного репозитория, а не в отдельных удаленных репозиториях.

## Роли
* **Роль Vector**: Локальная (папка `roles/vector-role`)
* **Роль Lighthouse**: Локальная (папка `roles/lighthouse-role`)
* **Роль Clickhouse**: [https://github.com/AlexeySetevoi/ansible-clickhouse](https://github.com/AlexeySetevoi/ansible-clickhouse)

## Команды для запуска

### 1. Скачивание зависимостей
Перед запуском необходимо подтянуть роли из файла `requirements.yml`:
```bash
ansible-galaxy install -r requirements.yml -p roles
```

### 2. Запуск плейбука
```bash
ansible-playbook -i inventory/prod.yml site.yml --diff
```

## Скриншот

![1](./img/1.png)

---
