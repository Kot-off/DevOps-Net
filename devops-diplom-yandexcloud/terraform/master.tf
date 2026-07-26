resource "yandex_compute_instance" "k8s-control-plane" {
  name                      = "control-plane"
  platform_id               = local.k8s.node_platform
  allow_stopping_for_update = true
  zone                      = "ru-central1-a"

  resources {
    memory        = local.k8s.instance_memory
    cores         = local.k8s.instance_cores
    core_fraction = local.k8s.core_fraction
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      size     = 30
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = local.k8s.subnet_ids["ru-central1-a"]
    nat       = true
  }

  metadata = {
    ssh-keys = local.k8s.node_ssh_key
  }
}