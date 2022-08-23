data "yandex_compute_image" "centos" {
  family = "centos-7"
}

locals {
  virtual_machines = {
    "redis01" = { cores = 2, memory = 4, disk_size = 10 },
    "redis02" = { cores = 2, memory = 4, disk_size = 10 },
    "redis03" = { cores = 2, memory = 4, disk_size = 10 }
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
      image_id    = data.yandex_compute_image.centos.id
      name        = "root-${each.key}"
      type        = "network-hdd"
      size        = each.value.disk_size
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
