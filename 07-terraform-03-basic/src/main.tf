data "yandex_compute_image" "centos" {
  family = "centos-7"
}

locals {
  instance_cores = {
    stage = 2
    prod = 2
  }
  instance_memory = {
    stage = 2
    prod = 2
  }
  instance_disk_size = {
    stage = 10
    prod = 10
  }
  instance_count_map = {
    stage = 1
    prod  = 2
  }
  instance_for_each_map = {
    stage = toset(["s1"])
    prod  = toset(["p1", "p2"])
  }
}

resource "yandex_compute_instance" "instance_count" {
  count                     = local.instance_count_map[terraform.workspace]
  name                      = "node-${terraform.workspace}-${count.index}"
  zone                      = "ru-central1-a"
  hostname                  = "node-${terraform.workspace}-${count.index}.netology.cloud"
  allow_stopping_for_update = true

  resources {
    cores  = local.instance_cores[terraform.workspace]
    memory = local.instance_memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.centos.id
      name        = "root-${terraform.workspace}-${count.index}"
      type        = "network-hdd"
      size        = local.instance_disk_size[terraform.workspace]
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "instance_for_each" {
  lifecycle {
    create_before_destroy = true
  }

  for_each      = local.instance_for_each_map[terraform.workspace]

  name                      = "node-${terraform.workspace}-${each.key}"
  zone                      = "ru-central1-a"
  hostname                  = "node-${terraform.workspace}-${each.key}.netology.cloud"
  allow_stopping_for_update = true

  resources {
    cores  = local.instance_cores[terraform.workspace]
    memory = local.instance_memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.centos.id
      name        = "root-${terraform.workspace}-${each.key}"
      type        = "network-hdd"
      size        = local.instance_disk_size[terraform.workspace]
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}