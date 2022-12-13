# Network
resource "yandex_vpc_network" "net_15_1" {
  name = "Network 15-1"
}

# Internet gateway
resource "yandex_vpc_subnet" "public" {
  name           = "Public Network 15-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net_15_1.id
  v4_cidr_blocks = ["172.31.32.0/19"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "Private Network 15-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net_15_1.id
  v4_cidr_blocks = ["172.31.96.0/19"]
  route_table_id = yandex_vpc_route_table.rt_15_1.id
}

# https://cloud.yandex.ru/docs/vpc/operations/static-route-create
resource "yandex_vpc_route_table" "rt_15_1" {
  name = "Route table for Network 15-1"
  network_id = yandex_vpc_network.net_15_1.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.public_vm["nat-instance"].network_interface.0.ip_address
  }
}
