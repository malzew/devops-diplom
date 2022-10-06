resource "null_resource" "app_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/app_install.yml"
  }

  depends_on = [
    null_resource.proxy_insert_dnat_rule
  ]
}

resource "null_resource" "app_ssh" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/app_ssh.yml --extra-vars 'username=${var.username} destfile=files/app_id_rsa.pub srcfile=files/app_id_rsa.pub destfile_secret=files/app_id_rsa'"
  }

  depends_on = [
    null_resource.app_install
  ]
}

resource "null_resource" "app_deploy" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/app_deploy.yml --extra-vars 'project_name=${var.project_name} git_repo=${var.git_initial_repo} git_branch=${var.git_branch}'"
  }

  depends_on = [
    null_resource.app_ssh
  ]
}
