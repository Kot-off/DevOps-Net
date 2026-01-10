variable "vm_db_zone" {
  type    = string
  default = "ru-central1-b"
}

# Задание 6: Параметры ресурсов ВМ в виде карты
variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
  default = {
    web = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    },
    db = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}

# Задание 6: Общая метадата для всех ВМ
variable "vms_metadata" {
  type = map(string)
  default = {
    serial-port-enable = "1"
    ssh-keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJiwLIT8LlSs222hpvlBIXwLr6+FTAufLdF/3+RYXGBH user@WIN-5MT07GOE69A"
  }
}