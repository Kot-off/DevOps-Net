# Задание 5: Локальные переменные для имен ВМ
## У нас получается, что мы собираем имя из нескольких переменных: проект + окружение + платформа + роль
locals {
  vm_web_name = "${var.project}-${var.vpc_name}-${var.platform}-web"
  vm_db_name  = "${var.project}-${var.vpc_name}-${var.platform}-db"
}