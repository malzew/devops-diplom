resource "null_resource" "runner_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/gitlab_runner.yml --extra-vars 'registration_token=GR1348941tTiyaiSVQpzpeAsLAj_2 domain_name=gitlab.${var.dns_zone}'"
  }

  depends_on = [
    null_resource.proxy_firewall
  ]
}
