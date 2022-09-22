# Образ берем стандартный, предоставляемый Яндексом, по семейству
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

variable "username" {
  type = string
  default = "ubuntu"
}

data "yandex_compute_image" "nat_instance" {
  family = "nat-instance-ubuntu"
}

data "yandex_dns_zone" "zone" {
  name = "eladminru"
}

variable "dns_zone" {
  type = string
  default = "eladmin.ru"
}

variable "services" {
  default = {
    www = "app"
    gitlab = "gitlab"
    grafana = "monitoring"
    prometheus = "monitoring"
    alertmanager = "monitoring"
  }
}

variable "database" {
  default = {
    database_name = "wordpress"
    database_user = "wordpress"
    database_password = "wordpress"
  }
}
