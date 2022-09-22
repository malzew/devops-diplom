output "external_ip_address_ngnix" {
  value = yandex_compute_instance.nginx.network_interface[0].nat_ip_address
}

output "internal_ip_address_nginx" {
  value = yandex_compute_instance.nginx.network_interface[0].ip_address
}

output "internal_ip_address_db01" {
  value = yandex_compute_instance.db01.network_interface[0].ip_address
}

output "internal_ip_address_db02" {
  value = yandex_compute_instance.db02.network_interface[0].ip_address
}

output "internal_ip_address_app" {
  value = yandex_compute_instance.app.network_interface[0].ip_address
}
