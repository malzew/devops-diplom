provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "b1g2n2okvr289487oale"
  folder_id = "b1gg33hbpnn7at4oorel"
  zone      = "ru-central1-a"
}

# Получим данные клиента
data "yandex_client_config" "client" {}

# Образ берем стандартный, предоставляемый Яндексом, по семейству
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

data "yandex_dns_zone" "eladminru" {
  name = "eladminru"
}

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


locals {
  dns_zone = "eladmin.ru"

  node_instance_type_map = {
    stage = "standard-v1"
    prod  = "standard-v2"
  }

  node_instance_foreach_map = {
    "foreach-01" = "ru-central1-a"
    "foreach-02" = "ru-central1-a"
  }
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = data.yandex_dns_zone.eladminru.id
  name    = "${local.dns_zone}."
  type    = "A"
  ttl     = 200
  data    = yandex_compute_instance.nginx.network_interface[0].nat_ip_address

  depends_on = [yandex_compute_instance.nginx]
}

# Создаем ВМ, задаем имя, платформу, зону, имя хоста с помощью for_each
resource "yandex_compute_instance" "nginx" {
  name        = "nginx"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  hostname    = "${local.dns_zone}"

  # В ресурсах 2 ядра, 4 гига оперативы, под 100% нагрузку
  resources {
    cores  = 2
    memory = 2
    core_fraction = 100
  }

  # Загрузочный диск из стандартного образа, на SSD, 40Gb
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type = "network-hdd"
      size = "20"
    }
  }

  # Это нужно, чтобы при смене id образа (сменилась последняя сборка семейства ОС) терраформ не пытался пересоздать ВМ
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]

    #Создать новый ресурс перед удалением старого
    # create_before_destroy = true
  }

  # Создаем сетевой интерфейс у ВМ, с адресом из ранее созданной подсети и NAT, чтобы был доступ в инет
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_zone_a.id
      nat = "true"
  }

  # Передаем свои SSH ключи для авторизации
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}


/*
# Создаем ВМ, задаем имя, платформу, зону, имя хоста с помощью for_each
resource "yandex_compute_instance" "foreach" {
  name        = each.key
  platform_id = local.node_instance_type_map[terraform.workspace]
  zone        = each.value
  hostname    = "${each.key}.${dns_zone}"
  for_each    = local.node_instance_foreach_map

  # В ресурсах 2 ядра, 4 гига оперативы, под 100% нагрузку
  resources {
    cores  = 2
    memory = 4
    core_fraction = 100
  }

  # Загрузочный диск из стандартного образа, на SSD, 40Gb
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type = "network-hdd"
      size = "20"
    }
  }

  # Это нужно, чтобы при смене id образа (сменилась последняя сборка семейства ОС) терраформ не пытался пересоздать ВМ
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]

    #Создать новый ресурс перед удалением старого
    create_before_destroy = true
  }

  # Создаем сетевой интерфейс у ВМ, с адресом из ранее созданной подсети и NAT, чтобы был доступ в инет
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_zone_a.id
      nat = "true"
  }

  # Передаем свои SSH ключи для авторизации
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
*/