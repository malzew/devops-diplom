resource "null_resource" "app_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/app_install.yml"
  }

  depends_on = [
    null_resource.proxy_firewall
  ]
}

resource "null_resource" "app_deploy" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/app_deploy.yml --extra-vars 'project_name=${var.project_name} git_repo=${var.git_initial_repo} git_branch=${var.git_branch}'"
  }

  depends_on = [
    null_resource.app_install
  ]
}
