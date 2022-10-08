# Создается IN A запись в зоне для домена, по готовности сервера NGINX - нужно знать его внешний IP адрес.
resource "yandex_dns_recordset" "record" {
  zone_id = data.yandex_dns_zone.zone.id
  name    = "${var.dns_zone}."
  type    = "A"
  ttl     = var.dns_zone_ttl
  data    = ["${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"]

  depends_on = [
    yandex_compute_instance.nginx
  ]
}

# Создается IN A запись в зоне для каждого из поддоменов, описанного в переменной services, по готовности сервера NGINX - нужно знать его внешний IP адрес.
resource "yandex_dns_recordset" "records" {
  zone_id = data.yandex_dns_zone.zone.id
  name    = "${each.key}.${var.dns_zone}."
  type    = "A"
  ttl     = var.dns_zone_ttl
  data    = ["${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}"]

  for_each = var.services

  depends_on = [
    yandex_compute_instance.nginx
  ]
}
