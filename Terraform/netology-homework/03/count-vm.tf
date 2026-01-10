resource "yandex_compute_instance" "web" {
  count = 2
  name  = "web-${count.index + 1}"

  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }

  scheduling_policy { 
    preemptible = true 
  }

  # Задание 2.4: Ждем БД
  depends_on = [yandex_compute_instance.db]
}