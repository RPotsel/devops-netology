# https://cloud.yandex.ru/docs/cli/cli-ref/managed-services/kms/
# https://cloud.yandex.ru/docs/kms/quickstart/

resource "yandex_kms_symmetric_key" "key-n154" {
  name              = "key_n154"
  description       = "Homework 15.4 KSM symmetric key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}
