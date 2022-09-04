output "internal_ip_address_control" {
  value = yandex_compute_instance.control[*].network_interface.0.ip_address
}

output "external_ip_address_control" {
  value = yandex_compute_instance.control[*].network_interface.0.nat_ip_address
}

output "internal_ip_address_worker" {
  value = yandex_compute_instance.worker[*].network_interface.0.ip_address
}

output "external_ip_address_worker" {
  value = yandex_compute_instance.worker[*].network_interface.0.nat_ip_address
}
