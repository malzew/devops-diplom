# Создаем сеть
resource "yandex_vpc_network" "default" {
  name = "net"
}

# Создаем подсеть в зоне A для ДМЗ
resource "yandex_vpc_subnet" "subnet_zone_a_dmz" {
  zone       = "ru-central1-a"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  description = "Zone A DMZ subnet"
}

#Создаем подсеть в зоне A для внутренних сервисов
resource "yandex_vpc_subnet" "subnet_zone_a" {
  zone       = "ru-central1-a"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.21.0/24"]
  description = "Zone A inside subnet"
  route_table_id = yandex_vpc_route_table.route_table_nat.id
}

#Маршрут из зоны А на proxy, там NAT
resource "yandex_vpc_route_table" "route_table_nat" {
  description = "Route table for inside subnets"
  name        = "route_table_nat"

  depends_on = [
    yandex_compute_instance.nginx
  ]

  network_id = yandex_vpc_network.default.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nginx.network_interface.0.ip_address
  }
}

# Создаем подсеть в зоне B для внутренних сервисов
resource "yandex_vpc_subnet" "subnet_zone_b" {
  zone       = "ru-central1-b"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.31.0/24"]
  route_table_id = yandex_vpc_route_table.route_table_nat.id
}
