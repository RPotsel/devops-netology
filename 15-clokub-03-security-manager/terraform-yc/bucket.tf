# https://cloud.yandex.ru/docs/storage/operations/buckets/encrypt

resource "yandex_storage_bucket" "netology_15_3-encrypt" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "netology-hw1503-encrypt"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-n153.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# https://cloud.yandex.ru/docs/storage/operations/hosting/setup
# https://cloud.yandex.ru/docs/storage/operations/buckets/edit-acl
# https://cloud.yandex.ru/docs/storage/operations/hosting/certificate

resource "yandex_storage_bucket" "netology_15_3-web" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "hw15.rpotsel.ru"
  acl        = "public-read"

    website {
      index_document = "index.html"
      error_document = "error.html"
    }
    #  yc certificate-manager certificate list
    https {
      certificate_id = "fpq0s1l5bsfc8jqim1au"
    }
  }

#https://cloud.yandex.ru/docs/storage/operations/objects/upload

resource "yandex_storage_object" "devops_png" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.netology_15_3-encrypt.bucket
  key        = "img/devops.png"
  source     = "devops.png"
  acl        = "public-read"
}

resource "yandex_storage_object" "site" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = yandex_storage_bucket.netology_15_3-web.bucket

  for_each = fileset("../site/", "*")
  key    = each.value
  source = "../site/${each.value}"
  # etag makes the file update when it changes for AWS
  # etag   = filemd5("../site/${each.value}")
}
