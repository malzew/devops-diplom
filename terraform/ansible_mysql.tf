resource "null_resource" "mysql_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/mysql_install.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}