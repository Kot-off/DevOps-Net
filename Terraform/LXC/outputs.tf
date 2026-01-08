output "netology_container_ip" {
  value = module.netology.container_ip
}

# Выводим сгенерированный пароль (он будет скрыт, пока не будет выполнена команда terraform output)
output "generated_container_password" {
  value     = random_password.container_pass.result
  sensitive = true
}