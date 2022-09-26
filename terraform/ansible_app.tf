resource "null_resource" "app" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/app_install.yml"
  }

  depends_on = [
    null_resource.proxy_firewall
  ]
}
