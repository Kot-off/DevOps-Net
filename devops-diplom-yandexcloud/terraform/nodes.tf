resource "yandex_compute_instance_group" "k8s-node-group" {
  name               = "k8s-node-group"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.k8s-sa.id

  instance_template {
    name        = "node-{instance.index}"
    platform_id = local.k8s.node_platform

    resources {
      memory        = local.k8s.instance_memory
      cores         = local.k8s.instance_cores
      core_fraction = local.k8s.core_fraction
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu_2204.id
        size     = 30
        type     = "network-hdd"
      }
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      subnet_ids = toset(values(local.k8s.subnet_ids))
      nat        = true
    }

    metadata = {
      ssh-keys = local.k8s.node_ssh_key
    }
  }

  scale_policy {
    fixed_scale {
      size = local.k8s.instance_count
    }
  }

  allocation_policy {
    zones = [
      "ru-central1-a",
      "ru-central1-b",
      "ru-central1-c"
    ]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
}