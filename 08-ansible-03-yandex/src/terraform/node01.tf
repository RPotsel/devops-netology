resource "yandex_compute_instance" "node01" {
  name                      = "clickhouse-01"
  zone                      = "ru-central1-a"
  hostname                  = "clickhouse-01.netology.yc"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "${data.yandex_compute_image.centos.id}"
      name        = "root-node01"
      type        = "network-hdd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.default.id}"
    nat        = true
    ip_address = "192.168.101.11"
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}
