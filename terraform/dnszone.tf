resource "yandex_dns_recordset" "record" {
  zone_id = data.yandex_dns_zone.zone.id
  name    = "${var.dns_zone}."
  type    = "A"
  ttl     = 300
  data    = ["${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"]

  depends_on = [
    yandex_compute_instance.nginx
  ]
}

resource "yandex_dns_recordset" "records" {
  zone_id = data.yandex_dns_zone.zone.id
  name    = "${each.key}.${var.dns_zone}."
  type    = "A"
  ttl     = 300
  data    = ["${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"]

  for_each = var.services

  depends_on = [
    yandex_compute_instance.nginx
  ]
}
