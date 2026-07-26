### cloud vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "vpc_name" {
  type        = string
  default     = "develop"
}

### Удаление ХАРДКОДА =)

# Параметры железа по умолчанию
variable "vms_default_hw" {
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
    platform_id   = string
  })
  default = {
    cores         = 2
    memory        = 1
    core_fraction = 5
    platform_id   = "standard-v1"
  }
}

# Образ ОС
variable "vm_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

# Путь к SSH ключу
variable "vms_ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

# Правила Ingress (переехали из security.tf)
variable "security_group_ingress" {
  description = "secrules ingress"
  type = list(object({
    protocol       = string
    description    = string
    v4_cidr_blocks = list(string)
    port           = optional(number)
    from_port      = optional(number)
    to_port        = optional(number)
  }))
  default = [
    {
      protocol       = "TCP"
      description    = "разрешить входящий ssh"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 22
    },
    {
      protocol       = "TCP"
      description    = "разрешить входящий http"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 80
    },
    {
      protocol       = "TCP"
      description    = "разрешить входящий https"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 443
    }
  ]
}

# Правила Egress (переехали из security.tf)
variable "security_group_egress" {
  description = "secrules egress"
  type = list(object({
    protocol       = string
    description    = string
    v4_cidr_blocks = list(string)
    port           = optional(number)
    from_port      = optional(number)
    to_port        = optional(number)
  }))
  default = [
    { 
      protocol       = "TCP"
      description    = "разрешить весь исходящий трафик"
      v4_cidr_blocks = ["0.0.0.0/0"]
      from_port      = 0
      to_port        = 65535
    }
  ]
}
