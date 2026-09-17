terraform {
  required_version = ">= 1.8, < 2.0"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "= 0.228.0"
    }
  }
}

# Учётные данные передаются через YC_TOKEN или YC_SERVICE_ACCOUNT_KEY_FILE.
provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts"
}

resource "yandex_vpc_network" "lab" {
  name = "${var.name}-network"
}

resource "yandex_vpc_subnet" "lab" {
  name           = "${var.name}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.lab.id
  v4_cidr_blocks = ["10.91.0.0/24"]
}

resource "yandex_vpc_security_group" "lab" {
  name       = "${var.name}-sg"
  network_id = yandex_vpc_network.lab.id

  ingress {
    description    = "SSH только с разрешённого адреса оператора"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    description    = "Обновления, DNS и диагностика соединения"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "lab" {
  name        = var.name
  hostname    = var.name
  zone        = var.zone
  platform_id = "standard-v3"
  labels      = { project = "otus-dz01", purpose = "terraform-homework" }

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.lab.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.lab.id]
  }

  metadata = {
    user-data = "#cloud-config\n${yamlencode({
      users = [{
        name                = "ubuntu"
        groups              = ["sudo"]
        shell               = "/bin/bash"
        sudo                = ["ALL=(ALL) NOPASSWD:ALL"]
        lock_passwd         = true
        ssh_authorized_keys = [trimspace(file(pathexpand(var.ssh_public_key_path)))]
      }]
      ssh_pwauth   = false
      disable_root = true
    })}"
  }
}
