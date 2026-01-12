variable "each_vm" {
  type = list(object({
    vm_name       = string
    cpu           = number
    ram           = number
    disk          = number
    core_fraction = number
    platform_id   = string
  }))
  default = [
    { vm_name = "main",    cpu = 2, ram = 2, disk = 20, core_fraction = 20, platform_id = "standard-v1" },
    { vm_name = "replica", cpu = 2, ram = 1, disk = 15, core_fraction = 5,  platform_id = "standard-v1" }
  ]
}

resource "yandex_compute_instance" "db" {
  for_each = { for vm in var.each_vm : vm.vm_name => vm }

  name        = each.value.vm_name
  platform_id = each.value.platform_id
  allow_stopping_for_update = true

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = each.value.disk
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }

  scheduling_policy { 
    preemptible = true 
  }
}