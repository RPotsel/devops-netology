resource "local_file" "inventory" {
  content = <<-DOC
  ---
  all:
    hosts:
      redis01:
        ansible_host: ${yandex_compute_instance.vm["redis01"].network_interface.0.nat_ip_address}
      redis02:
        ansible_host: ${yandex_compute_instance.vm["redis02"].network_interface.0.nat_ip_address}
      redis03:
        ansible_host: ${yandex_compute_instance.vm["redis03"].network_interface.0.nat_ip_address}

    children:
      rediscluster:
        hosts:
          redis01:
          redis02:
          redis03:

    vars:
      ansible_connection_type: ssh
      ansible_user: centos
    DOC
  filename = "../ansible/inventory"

  depends_on = [
    yandex_compute_instance.vm["redis01"],
    yandex_compute_instance.vm["redis02"],
    yandex_compute_instance.vm["redis03"]
  ]
}
