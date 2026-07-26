resource "proxmox_virtual_environment_container" "this" {
  node_name = var.target_node
  vm_id     = var.vm_id

  unprivileged = true 

  initialization {
    hostname = var.hostname
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }
    user_account {
      keys     = [trimspace(var.ssh_public_key)]
      password = var.container_password
    }
  }

  features {
    nesting = true
  }

  operating_system {
    template_file_id = var.template_id
    type             = var.os_type
  }

  disk { 
    datastore_id = "local"
    size = 20 
  }
  
  cpu    { cores = 1 }
  memory { dedicated = 2048 }
  
  network_interface { 
    name   = "eth0"
    bridge = "vmbr0" 
  }

  started = true

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    host        = split("/", var.ip_address)[0]
    timeout     = "2m"
  }

provisioner "remote-exec" {
    inline = [
      # 1. Ждем снятия блокировок и игнорируем мелкие ошибки apt
      "while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 5; done",
      "apt-get update || true", 
      
      # 2. Создаем конфиг VFS заранее
      "mkdir -p /etc/docker",
      "echo '{\"storage-driver\": \"vfs\"}' > /etc/docker/daemon.json",
      
      # 3. Установка curl и Docker
      "apt-get install -y curl || true",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sh get-docker.sh || (sleep 10 && sh get-docker.sh)", # Повторная попытка если скрипт мигнул
      
      # 4. Запуск и финальная настройка
      "systemctl restart docker",
      "echo 'devops:${var.container_password}' | chpasswd"
    ]
  }
}