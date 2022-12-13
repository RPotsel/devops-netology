# Network
resource "yandex_vpc_network" "net_15_1" {
  name = "Network 15-1"
}

resource "yandex_vpc_subnet" "private" {
  name           = "Private Network 15-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net_15_1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}
