terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "devops-netology"
    region     = "ru-central1-a"
    key        = "07-terraform-03-basic/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}