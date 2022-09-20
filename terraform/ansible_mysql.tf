resource "null_resource" "mysql_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/mysql_install.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}

resource "null_resource" "mysql_create_db" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/mysql_create_db.yml --extra-vars 'database_name=${var.database.database_name} database_user=${var.database.database_name} database_password=${var.database.database_password}'"
  }

  depends_on = [
    null_resource.mysql_install
  ]
}

resource "null_resource" "mysql_create_db" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/mysql_create_db.yml --extra-vars 'database_name=${var.database.database_name} database_user=${var.database.database_name} database_password=${var.database.database_password}'"
  }

  depends_on = [
    null_resource.mysql_install
  ]
}