resource "null_resource" "gitlab_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/gitlab_install.yml --extra-vars 'docker_compose_src_dir=/opt/gitlab docker_compose_template=gitlab-docker-compose.yml.j2 domain_name=gitlab.${var.dns_zone}'"
  }

  depends_on = [
    null_resource.wait
  ]
}
