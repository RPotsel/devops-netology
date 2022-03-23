output "internal_ip_address_instace_count" {
  value = resource.yandex_compute_instance.instance_count.*.network_interface.0.ip_address
}

output "external_ip_address_instace_count" {
  value = resource.yandex_compute_instance.instance_count.*.network_interface.0.nat_ip_address
}

output "internal_ip_address_instace_for_each" {
  value = toset([
    for instance in yandex_compute_instance.instance_for_each : instance.network_interface.0.ip_address
  ])
}

output "external_ip_address_instace_for_each" {
  value = toset([
    for instance in yandex_compute_instance.instance_for_each : instance.network_interface.0.nat_ip_address
  ])
}