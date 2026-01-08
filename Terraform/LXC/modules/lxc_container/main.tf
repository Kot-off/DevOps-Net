resource "proxmox_virtual_environment_container" "this" {
  node_name = var.target_node
  vm_id     = var.vm_id

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

  operating_system {
    template_file_id = var.template_id
    type             = var.os_type
  }

  disk { 
    datastore_id = "local"
    size = 20 
  }
  cpu  { cores = 1 }
  memory { dedicated = 2048 }
  network_interface { 
    name = "eth0"
    bridge = "vmbr0" 
  }

  unprivileged = true
  started      = true

  # Подключение через приватный ключ
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    host        = split("/", var.ip_address)[0]
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = concat(
      ["mkdir -p /root/.ssh", "chmod 700 /root/.ssh"],
      var.setup_commands
    )
  }
}

resource "null_resource" "copy_key" {
  count = var.copy_private_key ? 1 : 0
  depends_on = [proxmox_virtual_environment_container.this]

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    host        = split("/", var.ip_address)[0]
  }

  provisioner "file" {
    source      = var.ssh_private_key_path
    destination = "/root/.ssh/${basename(var.ssh_private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = ["chmod 600 /root/.ssh/${basename(var.ssh_private_key_path)}"]
  }
}