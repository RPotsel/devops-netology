resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [
    null_resource.inventory
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    working_dir = "../kubespray"
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -b -i inventory/mycluster/hosts cluster.yml -e @inventory/mycluster/extra_vars.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}

resource "null_resource" "config" {
  provisioner "local-exec" {
    working_dir = "../ansible"
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../kubespray/inventory/mycluster/hosts playbook.yml"
  }

  depends_on = [
    null_resource.cluster
  ]
}
