# Network
resource "yandex_vpc_network" "network-15-2" {
  name = "Network 15-2"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-15-2.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-15-2.id
  v4_cidr_blocks = ["192.168.2.0/24"]
}
