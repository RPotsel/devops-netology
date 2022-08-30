resource "local_file" "inventory" {
  content = <<-DOC
  ---
  all:
    hosts:
      minikube:
        ansible_host: ${yandex_compute_instance.vm["minikube"].network_interface.0.nat_ip_address}

    vars:
      ansible_connection_type: ssh
      ansible_user: ubuntu
    DOC
  filename = "../ansible/inventory"

  depends_on = [
    yandex_compute_instance.vm["minikube"]
  ]
}
