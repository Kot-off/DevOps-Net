# 1. Модуль VPC (Задания 2 и 4*)
module "vpc_dev" {
  source   = "./vpc"
  env_name = "develop"
  subnets  = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" }
  ]
}

# 2. Шаблон Cloud-init (Задание 1)
data "template_file" "cloudinit" {
  template = file("${path.module}/cloud-init.yml")
  vars = {
    ssh_public_key = var.vms_ssh_root_key 
  }
}

# 3. Виртуальные машины (Задания 1 и 2)
module "marketing_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "marketing"
  network_id     = module.vpc_dev.network_id
  subnet_ids     = [module.vpc_dev.subnets["ru-central1-a"].id] 
  subnet_zones   = ["ru-central1-a"]
  instance_name  = "marketing-vm"
  instance_count = 1
  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
  labels = { project = "marketing" }
}

module "analytics_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "analytics"
  network_id     = module.vpc_dev.network_id
  subnet_ids     = [module.vpc_dev.subnets["ru-central1-a"].id]
  subnet_zones   = ["ru-central1-a"]
  instance_name  = "analytics-vm"
  instance_count = 1
  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
  labels = { project = "analytics" }
}

# 4. S3 Bucket и права доступа (Задание 6*)

# Сервисный аккаунт
resource "yandex_iam_service_account" "s3_sa" {
  name = "s3-manager-sa-${random_string.unique_id.result}"
}

# Роль для аккаунта
resource "yandex_resourcemanager_folder_iam_member" "s3_editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.s3_sa.id}"
}

# Статический ключ
resource "yandex_iam_service_account_static_access_key" "s3_key" {
  service_account_id = yandex_iam_service_account.s3_sa.id
}

# Модуль S3 (с учетом структуры переменных, которую мы нашли в variables.tf)
module "s3_bucket" {
  source      = "git::https://github.com/terraform-yc-modules/terraform-yc-s3.git?ref=master"
  bucket_name = "netology-bucket-${random_string.unique_id.result}"
  max_size    = 1073741824 # 1 ГБ

  existing_service_account = {
    id         = yandex_iam_service_account.s3_sa.id
    access_key = yandex_iam_service_account_static_access_key.s3_key.access_key
    secret_key = yandex_iam_service_account_static_access_key.s3_key.secret_key
  }

  force_destroy = true 
}

# ГЕНЕРАТОР УНИКАЛЬНОЙ СТРОКИ (то самое, чего не хватало)
resource "random_string" "unique_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

moved {
  from = module.vpc_dev.yandex_vpc_subnet.subnet
  to   = module.vpc_dev.yandex_vpc_subnet.subnet["ru-central1-a"]
}