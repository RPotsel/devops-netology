output "internal_ip_address_instace" {
  value = toset([
    for instance in yandex_compute_instance.vm : instance.network_interface.0.ip_address
  ])
}

output "external_ip_address_instace" {
  value = toset([
    for instance in yandex_compute_instance.vm : instance.network_interface.0.nat_ip_address
  ])
}
