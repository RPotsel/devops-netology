# https://cloud.yandex.ru/docs/cli/cli-ref/managed-services/kms/
# https://cloud.yandex.ru/docs/kms/quickstart/

resource "yandex_kms_symmetric_key" "key-n153" {
  name              = "key_n153"
  description       = "Homework 15.3 KSM symmetric key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}
