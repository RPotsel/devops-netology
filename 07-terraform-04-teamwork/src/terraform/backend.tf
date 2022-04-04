terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "devops-netology"
    region     = "ru-central1-a"
    key        = "07-terraform-04-teamwork/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}