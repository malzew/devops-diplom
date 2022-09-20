terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "amalzew-netology" # From yandex cloud
    region     = "ru-central1"
    key        = "diplom/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "b1g2n2okvr289487oale" # From yandex cloud
  folder_id = "b1gg33hbpnn7at4oorel" # From yandex cloud
  zone      = "ru-central1-a"
}
