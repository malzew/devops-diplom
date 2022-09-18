resource "null_resource" "dns_record_create_root" {
  provisioner "local-exec" {
    command = "./dns_records ${data.yandex_dns_zone.zone.name} @ A ${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"
  }

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "dns_record_create_app" {
  provisioner "local-exec" {
    command = "./dns_records ${data.yandex_dns_zone.zone.name} ${each.key} A ${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"
  }
  for_each = var.services

  depends_on = [
    null_resource.dns_record_create_root
  ]
}
