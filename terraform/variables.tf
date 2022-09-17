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

data "yandex_dns_zone" "zone" {
  name = "eladminru"
}
