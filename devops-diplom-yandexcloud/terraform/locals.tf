locals {
  k8s = {
    region        = "ru-central1"
    node_platform = "standard-v2"
    node_ssh_key  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    
    # Ubuntu 22.04 LTS
    instance_image = "fd80m9ut138no05a1133" 
    instance_count  = 3
    instance_memory = 4
    instance_cores  = 2
    core_fraction   = 20

    subnet_ids = {
       for k, v in yandex_vpc_subnet.subnet : v.zone => v.id 
    }
  }
}