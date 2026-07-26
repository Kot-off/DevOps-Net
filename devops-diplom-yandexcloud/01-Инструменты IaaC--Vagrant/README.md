# Основные команды Vagrant

## Базовые команды работы с окружением

``` bash
# Инициализация нового проекта Vagrant
vagrant init ubuntu/focal64

# Запуск виртуальной машины
vagrant up

# Остановка VM
vagrant halt

# Перезагрузка VM
vagrant reload

# Подключение к VM по SSH
vagrant ssh

# Проверка статуса VM
vagrant status

# Удаление VM
vagrant destroy

# Приостановка VM
vagrant suspend

# Возобновление VM
vagrant resume
```


## Команды управления боксами

``` bash
# Список установленных боксов
vagrant box list

# Добавление нового бокса
vagrant box add ubuntu/focal64

# Удаление бокса
vagrant box remove ubuntu/focal64

# Обновление бокса
vagrant box update
```

## Команды для плагинов

``` bash
# Установка плагина
vagrant plugin install vagrant-vbguest

# Список установленных плагинов
vagrant plugin list
```