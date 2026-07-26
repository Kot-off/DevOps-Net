# --- 1. Генерируем пароли ---
resource "random_password" "container_pass" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_password" "mysql_root_psw" {
  length  = 16
  special = false
}

# --- 2. Контейнер netology (Docker-хост) ---
module "netology" {
  source               = "./modules/lxc_container"
  target_node          = var.target_node
  vm_id                = 301
  hostname             = "netology-docker-host"
  ip_address           = var.netology_master_ip
  container_password   = random_password.container_pass.result
  template_id          = var.ubuntu_template_path
  os_type              = "ubuntu"
  ssh_user             = var.ssh_user
  ssh_public_key       = file("${path.module}/${var.ssh_key_path}.pub")
  ssh_private_key_path = "${path.module}/${var.ssh_key_path}"

  setup_commands = [
    # Ожидание разблокировки apt
    "while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 5; done",
    "apt-get update && apt-get install -y curl git",
    
    # Официальный метод установки Docker (get.docker.com)
    "curl -fsSL https://get.docker.com -o get-docker.sh",
    "sh get-docker.sh",
    
    # Запуск и настройка прав
    "systemctl start docker",
    "echo 'devops:${random_password.container_pass.result}' | chpasswd"
  ]
}

# --- 3. Удаленный Docker (Задание 2*) ---
provider "docker" {
  alias = "remote"
  host  = "ssh://root@192.168.1.111:22"
  ssh_opts = [
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
    "-i", "${path.module}/${var.ssh_key_path}"
  ]
}

# --- 4. MySQL Контейнер (Задание 2*) ---

# Добавляем этот блок, чтобы OpenTofu сначала скачал образ
resource "docker_image" "mysql" {
  provider     = docker.remote
  name         = "mysql:8"
  keep_locally = true
  # Добавим этот параметр, чтобы он не падал, если Docker еще не готов
  force_remove = false 
}

resource "docker_container" "mysql_server" {
  provider = docker.remote
  # Теперь ссылаемся на ресурс выше
  image    = docker_image.mysql.image_id
  name     = "example_mysql_${random_password.mysql_root_psw.result}"

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root_psw.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${var.mysql_user_password}",
    "MYSQL_ROOT_HOST=%",
    "MYSQL_ROOT_PASSWORD_AUTH=true"
  ]

  ports {
    internal = 3306
    external = 3306
    ip       = "127.0.0.1"
  }
}