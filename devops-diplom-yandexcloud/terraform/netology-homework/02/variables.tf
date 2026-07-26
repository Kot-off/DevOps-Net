# cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

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
  description = "Это будет наше окружение (env)"
}

# Переменные для задания 5
variable "project" {
  type    = string
  default = "netology"
}

variable "platform" {
  type    = string
  default = "platform"
}

# ssh vars
variable "vms_ssh_root_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJiwLIT8LlSs222hpvlBIXwLr6+FTAufLdF/3+RYXGBH user@WIN-5MT07GOE69A"
}