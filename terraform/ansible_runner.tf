resource "null_resource" "runner_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/gitlab_runner.yml"
  }

  depends_on = [
    null_resource.proxy_restart
  ]
}

resource "null_resource" "runner_register" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/gitlab_runner_reg.yml --extra-vars 'registration_token=${var.gitlab_runner_token} domain_name=gitlab.${var.dns_zone}'"
  }

  depends_on = [
    null_resource.wait_gitlab
  ]
}
