data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "control" {
  count    = var.control_node["count"]
  name     = "${var.control_node["name"]}${format("%02s", count.index+1)}"
  hostname = "${var.control_node["name"]}${format("%02s", count.index+1)}.netology.cloud"
  platform_id = "standard-v1"
  zone     = "ru-central1-a"

  allow_stopping_for_update = true

  resources {
    cores  = var.control_node["cores"]
    memory = var.control_node["memory"]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      name     = "root-control${count.index}"
      type     = "network-hdd"
      size     = var.control_node["disk_size"]
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "worker" {
  count    = var.worker_node["count"]
  name     = "${var.worker_node["name"]}${format("%02s", count.index+1)}"
  hostname = "${var.worker_node["name"]}${format("%02s", count.index+1)}.netology.cloud"
  platform_id = "standard-v1"
  zone     = "ru-central1-a"

  allow_stopping_for_update = true

  resources {
    cores  = var.worker_node["cores"]
    memory = var.worker_node["memory"]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      name     = "root-worker${count.index}"
      type     = "network-hdd"
      size     = var.worker_node["disk_size"]
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
