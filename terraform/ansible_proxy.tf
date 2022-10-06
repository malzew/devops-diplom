
# Reverse proxy
resource "null_resource" "proxy" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_install.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}

resource "null_resource" "proxy_ssh" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_ssh.yml --extra-vars 'username=${var.username} destfile=files/id_rsa.pub srcfile=files/id_rsa.pub'"
  }

  depends_on = [
    null_resource.proxy
  ]
}

resource "null_resource" "proxy_firewall" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_firewall.yml"
  }

  depends_on = [
    null_resource.proxy
  ]
}

resource "null_resource" "proxy_insert_dnat_rule" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_firewall_insert_dnat_rule.yml --extra-vars 'proto=tcp dest_port=2222 dest=${yandex_compute_instance.gitlab.network_interface.0.ip_address}:2222'"
  }

  depends_on = [
    null_resource.proxy_firewall
  ]
}

# TLS certs for services
resource "null_resource" "get_letsencrypt" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=${var.dns_zone}'"
  }

  depends_on = [
    null_resource.proxy_insert_dnat_rule,
    yandex_dns_recordset.records
  ]
}

resource "null_resource" "get_letsencrypt_services" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=${each.key}.${var.dns_zone}'"
  }
  for_each = var.services

  depends_on = [
    null_resource.proxy_insert_dnat_rule,
    yandex_dns_recordset.records
  ]
}

resource "null_resource" "create_proxy_config" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_config.yml --extra-vars 'domain_name=${var.dns_zone} conf_dir=/etc/nginx/conf.d service_ip_port=app default_conf_file=default.conf'"
  }

  depends_on = [
    null_resource.get_letsencrypt_services,
    null_resource.get_letsencrypt
  ]
}

resource "null_resource" "create_proxy_config_services" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_config.yml --extra-vars 'domain_name=${each.key}.${var.dns_zone} conf_dir=/etc/nginx/conf.d service_ip_port=${each.value}'"
  }
  for_each = var.services

  depends_on = [
    null_resource.create_proxy_config
  ]
}

resource "null_resource" "proxy_restart" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_restart.yml"
  }

  depends_on = [
    null_resource.create_proxy_config_services,
    null_resource.create_proxy_config
  ]
}
