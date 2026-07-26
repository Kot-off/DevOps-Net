output "netology_container_ip" {
  value = module.netology.container_ip
}

output "generated_container_password" {
  value     = random_password.container_pass.result
  sensitive = true
}

# Вывод пароля root для MySQL
output "mysql_root_password" {
  value     = random_password.mysql_root_psw.result
  sensitive = true
}