# Установка необходимых пакетов и docker, docker-compose
# Выдача прав пользователю ubuntu на управление docker
# Установка GitLab runner из репозитория
resource "null_resource" "runner_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/gitlab_runner.yml"
  }

  depends_on = [
    null_resource.proxy_insert_dnat_rule
  ]
}

# Регистрация runner на GitLab, по мере готовности. Данные для регистрации из переменных terraform
resource "null_resource" "runner_register" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/gitlab_runner_reg.yml --extra-vars 'registration_token=${var.gitlab_runner_token} domain_name=gitlab.${var.dns_zone}'"
  }

  depends_on = [
    null_resource.wait_gitlab,
    null_resource.runner_install
  ]
}
