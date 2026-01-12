resource "yandex_compute_disk" "storage_disks" {
  count = 3
  name  = "extra-disk-${count.index + 1}"
  size  = 1
}

resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = var.vms_default_hw.platform_id

  resources {
    cores         = var.vms_default_hw.cores
    memory        = var.vms_default_hw.memory
    core_fraction = var.vms_default_hw.core_fraction
  }

  allow_stopping_for_update = true
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.storage_disks[*].id
    content {
      disk_id = secondary_disk.value
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