terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
  required_version = ">= 1.1.0" 
}

provider "docker" {}

# Ресурс для генерации пароля
resource "random_password" "random_string" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

# Ресурс образа
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

# Ресурс контейнера (Исправленный)
resource "docker_container" "hello_world" {
  image = docker_image.nginx.image_id
  name  = "hello_world"

  ports {
    internal = 80
    external = 9090
  }
}