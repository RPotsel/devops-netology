data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

# https://cloud.yandex.ru/docs/tutorials/routing/nat-instance
data "yandex_compute_image" "nat-ubuntu" {
  family = "nat-instance-ubuntu"
}

locals {
  public_vm = {
    "nat-instance" = { cores = 2, memory = 2, disk_size = 20 },
  }
}

locals {
  private_vm = {
    "node" = { cores = 2, memory = 2, disk_size = 20 },
  }
}

resource "yandex_compute_instance" "public_vm" {
  for_each = local.public_vm
  name     = each.key
  hostname = "${each.key}.netology.cloud"
  platform_id = "standard-v1"
  zone     = "ru-central1-a"

  allow_stopping_for_update = true

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.nat-ubuntu.id
      name        = "root-${each.key}"
      type        = "network-hdd"
      size        = each.value.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "pivate_vm" {
  for_each = local.private_vm
  name     = each.key
  hostname = "${each.key}.netology.cloud"
  platform_id = "standard-v1"
  zone     = "ru-central1-a"

  allow_stopping_for_update = true

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.ubuntu.id
      name        = "root-${each.key}"
      type        = "network-hdd"
      size        = each.value.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
