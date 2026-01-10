resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

# Подсеть для Web (Зона A)
resource "yandex_vpc_subnet" "develop" {
  name           = "develop-ru-central1-a"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

# Подсеть для DB (Зона B) - Задание 3
resource "yandex_vpc_subnet" "db" {
  name           = "develop-ru-central1-b"
  zone           = var.vm_db_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

# Получаем ID
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

# ВМ Web (Задание 1, 2, 5, 6)
resource "yandex_compute_instance" "web" {
  name        = local.vm_web_name
  platform_id = "standard-v1"
  zone        = var.default_zone

  resources {
    cores         = var.vms_resources.web.cores
    memory        = var.vms_resources.web.memory
    core_fraction = var.vms_resources.web.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = var.vms_metadata
}

# ВМ DB (Задание 3, 5, 6)
resource "yandex_compute_instance" "db" {
  name        = local.vm_db_name
  platform_id = "standard-v1"
  zone        = var.vm_db_zone

  resources {
    cores         = var.vms_resources.db.cores
    memory        = var.vms_resources.db.memory
    core_fraction = var.vms_resources.db.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.db.id
    nat       = true
  }

  metadata = var.vms_metadata
}