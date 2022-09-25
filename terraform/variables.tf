# Образ берем стандартный, предоставляемый Яндексом, по семейству
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

variable "username" {
  type = string
  default = "ubuntu"
}

/*data "yandex_compute_image" "nat_instance" {
  family = "nat-instance-ubuntu"
}*/

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
    grafana = "monitoring:3000"
    prometheus = "monitoring:9090"
    alertmanager = "monitoring:9093"
  }
}

variable "monitoring" {
  default = {
    nginx = "nginx"
    www = "app"
    gitlab = "gitlab"
    runner = "runner"
    db01 = "db01"
    db02 = "db02"
  }
}

variable "database" {
  default = {
    database_name = "wordpress"
    database_user = "wordpress"
    database_password = "wordpress"
  }
}
