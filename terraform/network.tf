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
}

# Создаем подсеть в зоне B для ДМЗ
resource "yandex_vpc_subnet" "subnet_zone_b_dmz" {
  zone       = "ru-central1-b"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}

# Создаем подсеть в зоне B для внутренних сервисов
resource "yandex_vpc_subnet" "subnet_zone_b" {
  zone       = "ru-central1-b"
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.31.0/24"]
}
