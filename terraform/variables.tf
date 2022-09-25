# Образ берем стандартный, предоставляемый Яндексом, по семейству
# В данной работе используется Ubuntu 20.04
# Переход на версию 22.04 потребует изменения настройки NAT
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

variable "username" {
  type = string
  default = "ubuntu"
}

data "yandex_dns_zone" "zone" {
  name = "eladminru"
}

variable "dns_zone" {
  type = string
  default = "eladmin.ru"
}

variable "dns_zone_ttl" {
  type = string
  default = "300"
}

# Список для создания поддоменов и конфигурации NGINX
variable "services" {
  default = {
    www = "app"
    gitlab = "gitlab"
    grafana = "monitoring:3000"
    prometheus = "monitoring:9090"
    alertmanager = "monitoring:9093"
  }
}

# Список для настройки мониторинга
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

# Настройки СУБД, боевые нужно переместить в secrets.tf
variable "database" {
  default = {
    database_name = "wordpress"
    database_user = "wordpress"
    database_password = "wordpress"
  }
}
