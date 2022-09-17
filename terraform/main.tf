
# Образ берем стандартный, предоставляемый Яндексом, по семейству
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
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