
# Reverse proxy
resource "null_resource" "proxy" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_install.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}

# TLS certs for services
resource "null_resource" "get_letsencrypt" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=${local.dns_zone}'"
  }

  depends_on = [
    null_resource.proxy,
    null_resource.dns_record_create_app
  ]
}

resource "null_resource" "get_letsencrypt_services" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/letsencrypt.yml --extra-vars 'domain_name=${each.value}.${local.dns_zone}'"
  }
  for_each = var.services

  depends_on = [
    null_resource.proxy,
    null_resource.dns_record_create_app
  ]
}

resource "null_resource" "create_proxy_config" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_config.yml --extra-vars 'domain_name=${local.dns_zone} conf_dir=/etc/nginx/conf.d service_ip_port=localhost:8080 default_conf_file=default.conf'"
  }

  depends_on = [
    null_resource.get_letsencrypt_services,
    null_resource.get_letsencrypt
  ]
}

resource "null_resource" "create_proxy_config_services" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/proxy_config.yml --extra-vars 'domain_name=${each.value}.${local.dns_zone} conf_dir=/etc/nginx/conf.d service_ip_port=localhost:8080'"
  }
  for_each = var.services

  depends_on = [
    null_resource.get_letsencrypt_services,
    null_resource.get_letsencrypt
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

