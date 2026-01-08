# --- Данные Proxmox API ---
variable "proxmox_api_url" { type = string }
variable "proxmox_api_token_id" { type = string }
variable "proxmox_api_token_secret" { 
  type = string 
  sensitive = true 
}

# --- Инфраструктура ---
variable "target_node" { type = string }
variable "ubuntu_template_path" { type = string }

# --- Глобальные настройки доступа ---
variable "ssh_user" { type = string }
variable "ssh_key_path" { 
  type    = string
  default = "id_ed25519" 
}
variable "devops_password" { 
  type = string 
  sensitive = true 
}

# --- Переменные для netology Master ---
variable "netology_master_ip" { type = string }
variable "netology_master_password" { 
  type = string 
  sensitive = true 
}

