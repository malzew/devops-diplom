resource "null_resource" "monitoring_config" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/prometheus_config.yml --extra-vars 'monitoring_target=${each.value}'"
  }

  for_each = var.monitoring

  depends_on = [
    null_resource.proxy_firewall
  ]
}

resource "null_resource" "monitoring_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/monitoring_install.yml"
  }

  depends_on = [
    null_resource.monitoring_config
  ]
}
