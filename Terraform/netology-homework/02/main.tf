# --- 1. Сети ---
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  name           = "develop-ru-central1-a"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

# Подсеть для DB (Зона B)
resource "yandex_vpc_subnet" "db" {
  name           = "develop-ru-central1-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

# --- 2. Данные (Образ) ---
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

# --- 3. Виртуальные машины ---

# ВМ Web
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

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = var.vms_metadata
}

# ВМ DB
resource "yandex_compute_instance" "db" {
  name        = local.vm_db_name
  platform_id = "standard-v1"
  zone        = "ru-central1-b"

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

  network_interface {
    subnet_id = yandex_vpc_subnet.db.id
    nat       = true
  }

  metadata = var.vms_metadata
}