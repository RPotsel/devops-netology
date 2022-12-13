# https://cloud.yandex.ru/docs/storage/operations/buckets/create

resource "yandex_storage_bucket" "netology_15_2" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "netology-hw1502-bucket"

  anonymous_access_flags {
    read = true
    list = true
  }
}

#https://cloud.yandex.ru/docs/storage/operations/objects/upload

resource "yandex_storage_object" "devops_png" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.netology_15_2.bucket
  key        = "img/devops.png"
  source     = "devops.png"
  acl        = "public-read"
}
