resource "null_resource" "requirements" {
  provisioner "local-exec" {
    command = <<-EOT
      cp -rfp ../kubespray/inventory/sample ../kubespray/inventory/mycluster
      cp -rfp inventory/extra_vars.yml ../kubespray/inventory/mycluster
    EOT
  }

  depends_on = [
    yandex_compute_instance.control,
    yandex_compute_instance.worker
  ]
}

data "template_file" "inventory" {
  template = file("${path.module}/inventory/inventory.tpl")

  vars = {
    connection_strings_master = join("\n", formatlist("%s ansible_host=%s", yandex_compute_instance.control.*.name, yandex_compute_instance.control.*.network_interface.0.nat_ip_address))
    connection_strings_node   = join("\n", formatlist("%s ansible_host=%s", yandex_compute_instance.worker.*.name, yandex_compute_instance.worker.*.network_interface.0.nat_ip_address))
    list_master               = join("\n", yandex_compute_instance.control.*.name)
    list_node                 = join("\n", yandex_compute_instance.worker.*.name)
  }

  depends_on = [
    null_resource.requirements
  ]
}

resource "null_resource" "inventory" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ../kubespray/inventory/mycluster/hosts"
  }

  triggers = {
    template = data.template_file.inventory.rendered
  }
}
