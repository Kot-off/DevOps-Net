resource "yandex_compute_disk" "storage_disks" {
  count = 3
  name  = "extra-disk-${count.index + 1}"
  size  = 1
}

resource "yandex_compute_instance" "storage" {
  name = "storage"
  resources {
    cores = 2
    memory = 1
    core_fraction = 5 
  }

  allow_stopping_for_update = true
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  # Динамическое подключение дисков
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