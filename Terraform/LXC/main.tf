# Ресурс для генерации случайного пароля (Задание 1.3 из ДЗ)
resource "random_password" "container_pass" {
  length  = 16
  special = true
  override_special = "_%@" # Для Proxmox (не воспринимает сложные символы в пароле)
}

# --- 1. netology (Ubuntu) ---
module "netology" {
  source               = "./modules/lxc_container"
  target_node          = var.target_node
  vm_id                = 301
  hostname             = "netology"
  ip_address           = var.netology_master_ip
  
  container_password   = random_password.container_pass.result
  
  template_id          = var.ubuntu_template_path
  os_type              = "ubuntu"
  
  ssh_user             = var.ssh_user
  ssh_public_key       = file("${path.module}/${var.ssh_key_path}.pub")
  ssh_private_key_path = "${path.module}/${var.ssh_key_path}"
  copy_private_key     = false

  setup_commands = [
    "apt-get update",
    "apt-get install -y sudo",
    "useradd -m -s /bin/bash devops",
    "echo 'devops:${random_password.container_pass.result}' | chpasswd",
    "usermod -aG sudo devops",
    "echo 'devops ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/devops"
  ]
}