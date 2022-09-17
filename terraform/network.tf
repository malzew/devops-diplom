# Создаем сеть
resource "yandex_vpc_network" "default" {
  name = "net"
}

# Создаем подсеть в зоне A
resource "yandex_vpc_subnet" "subnet_zone_a" {
  zone       = "ru-central1-a"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

# Создаем подсеть в зоне B
resource "yandex_vpc_subnet" "subnet_zone_b" {
  zone       = "ru-central1-b"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}

#resource "yandex_dns_recordset" "rs1" {
#  zone_id = data.yandex_dns_zone.eladminru.id
#  name    = "${local.dns_zone}."
#  type    = "A"
#  ttl     = 200
#  data    = yandex_compute_instance.nginx.network_interface[0].nat_ip_address
#
#  depends_on = [yandex_compute_instance.nginx]
#}