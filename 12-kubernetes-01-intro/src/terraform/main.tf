data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

locals {
  virtual_machines = {
    "minikube" = { cores = 2, memory = 4, disk_size = 20 },
  }
}

resource "yandex_compute_instance" "vm" {
  for_each = local.virtual_machines
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
      type        = "network-ssd"
      size        = each.value.disk_size
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
