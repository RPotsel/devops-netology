resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    working_dir = "../ansible"
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i inventory playbook.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}
