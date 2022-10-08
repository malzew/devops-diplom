# Установка необходимых пакетов и docker, docker-compose
# Выдача прав пользователю ubuntu на управление docker
resource "null_resource" "app_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/app_install.yml"
  }

  depends_on = [
    null_resource.proxy_insert_dnat_rule
  ]
}

# Создаем ssh ключи, скачиваем ключи в files/app_id_rsa.pub и files/app_id_rsa.pub. Добавляем свой же ключ в авторизированные.
# Данный шаг необходим для автоматическиго деплоя приложения из GitLab
resource "null_resource" "app_ssh" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/app_ssh.yml --extra-vars 'username=${var.username} destfile=files/app_id_rsa.pub srcfile=files/app_id_rsa.pub destfile_secret=files/app_id_rsa'"
  }

  depends_on = [
    null_resource.app_install
  ]
}

# Деплой приложения методом сборки docker контейнера из заданного репозитория. При наличии сохраняем старый образ с тегом :old
# Настройки имени проекта, использующегося репозитория и ветки из переменных terraform
resource "null_resource" "app_deploy" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/app_deploy.yml --extra-vars 'project_name=${var.project_name} git_repo=${var.git_initial_repo} git_branch=${var.git_branch}'"
  }

  depends_on = [
    null_resource.app_ssh
  ]
}
