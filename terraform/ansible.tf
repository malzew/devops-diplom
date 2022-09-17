resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 100"
  }

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "dns_record_create" {
  provisioner "local-exec" {
    command = "./dns_records ${data.yandex_dns_zone.zone.name} @ A ${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"
  }

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/reverse_proxy.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}
