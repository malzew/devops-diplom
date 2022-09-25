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
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/monitoring_install.yml --extra-vars 'telega_bot_token=${var.telega_bot_token} telega_chat_id=${var.telega_chat_id}'"
  }

  depends_on = [
    null_resource.app,
    null_resource.gitlab_install,
    null_resource.mysql_replication_slave,
    null_resource.proxy_restart,
    null_resource.runner_install
  ]
}
