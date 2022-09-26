resource "null_resource" "mysql_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/mysql_install.yml"
  }

  depends_on = [
    null_resource.proxy_firewall
  ]
}

resource "null_resource" "mysql_config_master" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/mysql_config.yml --extra-vars 'mysql_hosts=mysql_master conf_file=/etc/mysql/mysql.conf.d/mysqld.cnf bind_address=0.0.0.0 server_id=1 binlog_do_db=${var.database.database_name}'"
  }

  depends_on = [
    null_resource.mysql_install
  ]
}

resource "null_resource" "mysql_config_slave" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/mysql_config.yml --extra-vars 'mysql_hosts=mysql_slave conf_file=/etc/mysql/mysql.conf.d/mysqld.cnf bind_address=0.0.0.0 server_id=2 binlog_do_db=${var.database.database_name}'"
  }

  depends_on = [
    null_resource.mysql_install
  ]
}

resource "null_resource" "mysql_create_db" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/mysql_create_db.yml --extra-vars 'mysql_hosts=mysql database_name=${var.database.database_name} database_user=${var.database.database_user} database_password=${var.database.database_password}'"
  }

  depends_on = [
    null_resource.mysql_config_master,
    null_resource.mysql_config_slave
  ]
}

resource "null_resource" "mysql_replication_master" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/mysql_replication.yml --extra-vars 'mysql_hosts=mysql_master mysql_replication_role=master mysql_replication_master=${yandex_compute_instance.db01.hostname} database_user=${var.database.database_user} database_password=${var.database.database_password} database_name=${var.database.database_name}'"
  }

  depends_on = [
    null_resource.mysql_create_db
  ]
}

resource "null_resource" "mysql_replication_slave" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/mysql_replication.yml --extra-vars 'mysql_hosts=mysql_slave mysql_replication_role=slave mysql_replication_master=${yandex_compute_instance.db01.hostname} mysql_replication_master_ext=${yandex_compute_instance.db01.network_interface[0].nat_ip_address} database_user=${var.database.database_user} database_password=${var.database.database_password} database_name=${var.database.database_name}'"
  }

  depends_on = [
    null_resource.mysql_replication_master
  ]
}
