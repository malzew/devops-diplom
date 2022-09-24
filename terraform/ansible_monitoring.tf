resource "null_resource" "monitoring_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/monitoring_install.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}
