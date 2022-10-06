resource "null_resource" "gitlab_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/gitlab_install.yml --extra-vars 'docker_compose_src_dir=/opt/gitlab docker_compose_template=gitlab-docker-compose.yml.j2 domain_name=gitlab.${var.dns_zone} gitlab_root_password=${var.gitlab_root_password} gitlab_runner_token=${var.gitlab_runner_token}'"
  }

  depends_on = [
    null_resource.proxy_insert_dnat_rule
  ]
}

resource "null_resource" "wait_gitlab" {
  provisioner "local-exec" {
    command = "sleep 300"
  }

  depends_on = [
    null_resource.gitlab_install
  ]
}
