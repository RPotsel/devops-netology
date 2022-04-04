output "internal_ip_address_instace_count" {
  value = resource.yandex_compute_instance.instance_count.*.network_interface.0.ip_address
}

output "external_ip_address_instace_count" {
  value = resource.yandex_compute_instance.instance_count.*.network_interface.0.nat_ip_address
}
