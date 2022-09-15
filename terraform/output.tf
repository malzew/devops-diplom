/*
output "external_ip_address_foreach_yandex_cloud" {
  value = { for k, v in yandex_compute_instance.foreach: k => v.network_interface[0].nat_ip_address }
}

output "internal_ip_address_foreach_yandex_cloud" {
  value = { for k, v in yandex_compute_instance.foreach: k => v.network_interface[0].ip_address }
}
*/
output "subnet_id_a" {
  value = yandex_vpc_subnet.subnet_zone_a.network_id
}

output "subnet_id_b" {
  value = yandex_vpc_subnet.subnet_zone_b.network_id
}

output "zone" {
  value = data.yandex_dns_zone.eladminru.zone
}

output "external_ip_address_ngnix" {
  value = yandex_compute_instance.nginx.network_interface[0].nat_ip_address
}