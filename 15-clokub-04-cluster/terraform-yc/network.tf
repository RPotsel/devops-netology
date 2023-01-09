# Network
resource "yandex_vpc_network" "network-15-4" {
  name = "Network 15-4"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "Subnet 1 mysql"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-15-4.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "Subnet 2 mysql"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-15-4.id
  v4_cidr_blocks = ["192.168.2.0/24"]
}

resource "yandex_vpc_subnet" "k8s-subnet-a" {
  name           = "Subnet a k8s"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-15-4.id
  v4_cidr_blocks = ["10.5.0.0/16"]
}

resource "yandex_vpc_subnet" "k8s-subnet-b" {
  name           = "Subnet b k8s"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-15-4.id
  v4_cidr_blocks = ["10.6.0.0/16"]
}

resource "yandex_vpc_subnet" "k8s-subnet-c" {
  name           = "Subnet c k8s"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-15-4.id
  v4_cidr_blocks = ["10.7.0.0/16"]
}
