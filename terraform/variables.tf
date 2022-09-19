locals {
  dns_zone = "eladmin.ru"

  node_instance_type_map = {
    stage = "standard-v1"
    prod  = "standard-v2"
  }
}

# Образ берем стандартный, предоставляемый Яндексом, по семейству
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

data "yandex_dns_zone" "zone" {
  name = "eladminru"
}

variable "dns_zone" {
  default = {
    dns_zone = "eladmin.ru"
  }
}

variable "services" {
  default = {
    www = "www"
    gitlab = "gitlab"
    grafana = "grafana"
    prometheus = "prometheus"
    alertmanager = "alertmanager"
  }
}

variable "database" {
  default = {
    database_name = "wordpress"
    database_user = "wordpress"
    database_password = "wordpress"
  }
}
