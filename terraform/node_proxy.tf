resource "yandex_compute_instance" "nginx" {
  name        = "nginx"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  hostname    = "nginx.${var.dns_zone}"

  # В ресурсах 2 ядра, 4 гига оперативы, под 100% нагрузку
  resources {
    cores  = 2
    memory = 2
    core_fraction = 100
  }

  # Загрузочный диск из образа Ubuntu, на HDD, 20Gb
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

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_zone_a_dmz.id
    nat = "true"
  }

  # Передаем свои SSH ключи для авторизации
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "external_ip_address_ngnix" {
  value = yandex_compute_instance.nginx.network_interface[0].nat_ip_address
}

output "internal_ip_address_nginx" {
  value = yandex_compute_instance.nginx.network_interface[0].ip_address
}
