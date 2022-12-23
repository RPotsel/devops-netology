# Домашнее задание к занятию 15.3 "Безопасность в облачных провайдерах"
Используя конфигурации, выполненные в рамках предыдущих домашних заданиях, нужно добавить возможность шифрования бакета.

---
## Задание 1. Яндекс.Облако (обязательное к выполнению)
1. С помощью ключа в KMS необходимо зашифровать содержимое бакета:
- Создать ключ в KMS,
- С помощью ключа зашифровать содержимое бакета, созданного ранее.
2. (Выполняется НЕ в terraform) *Создать статический сайт в Object Storage c собственным публичным адресом и сделать доступным по HTTPS
- Создать сертификат,
- Создать статическую страницу в Object Storage и применить сертификат HTTPS,
- В качестве результата предоставить скриншот на страницу с сертификатом в заголовке ("замочек").

Документация
- [Настройка HTTPS статичного сайта](https://cloud.yandex.ru/docs/storage/operations/hosting/certificate)
- [Object storage bucket](https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/storage_bucket)
- [KMS key](https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/kms_symmetric_key)

**Ответ:**

Выполним развертывание виртуальных машин с требуемыми параметрами в облачной платформе `Yandex Cloud`. Для автоматизации работы с инфраструктурой воспользуемся решением `Terraform`, для которого платформа `Yandex Cloud` предоставляет провайдер. Опишем созданные конфигурационные файлы `Terraform` для каждого задания.

Общие конфигурационные файлы:

* [variables.tf](./terraform-yc/variables.tf) - указание переменных, используемых в сценарии развертывания;
* [provider.tf](./terraform-yc-alb/provider.tf) - объявление поставщика услуг `yandex-cloud/yandex`;
* [service_accounts.tf](./terraform-yc-alb/service_accounts.tf) - создание сервисной учетной записи для настройки  хранилища объектов;

*Задание 1. С помощью ключа в KMS необходимо зашифровать содержимое бакета.*

* [kms.tf](./terraform-yc/kms.tf) - создание симметричного ключа шифрования с помощью сервиса для создания и управления ключами шифрования, которые можно использовать для защиты данных в инфраструктуре `Yandex Cloud`;
* [bucket.tf](./terraform-yc/bucket.tf) - [шифрование объектов в бакете `netology_15_3-encrypt` с помощью ключей KMS](./terraform-yc/bucket.tf#L3-L16) и [загрузка в него данных](./terraform-yc/bucket.tf#L40-L47);

*Задание 2. *Создать статический сайт в Object Storage c собственным публичным адресом и сделать доступным по HTTPS*
* [bucket.tf](./terraform-yc/bucket.tf) - [создание статистического сайта в Object Storage и привязка сертификата из сервиса Certificate Manager](./terraform-yc/bucket.tf#L22-L36) и [загрузка в него данных](./terraform-yc/bucket.tf#L49-L59);

Сертификат создан согласно инструкции https://cloud.yandex.ru/docs/certificate-manager/, для его подтверждения нужна регистрация домена на публичных dns службах, у меня такой возможности нет, поэтому полная привязка сайта к сертификату не пройдена.

Выведем список созданных ресурсов после применения конфигурационных файлов [`Terraform`](./terraform-yc/):

```BASH
# Вывод используемых симметричных ключей шифрования
  $ yc kms symmetric-key list
+----------------------+----------+----------------------+-------------------+---------------------+--------+
|          ID          |   NAME   |  PRIMARY VERSION ID  | DEFAULT ALGORITHM |     CREATED AT      | STATUS |
+----------------------+----------+----------------------+-------------------+---------------------+--------+
| abjhbajiac7qgt6mbttj | key_n153 | abjtslaksmemnq2fq1mq | AES_128           | 2022-12-19 15:11:57 | ACTIVE |
+----------------------+----------+----------------------+-------------------+---------------------+--------+

# Создание псевдонима для работы с объектным хранилищем Yandex Cloud с помощью утилиты AWS CLI
# https://cloud.yandex.ru/docs/storage/tools/aws-cli
  $ alias ycs3='aws s3 --endpoint-url=https://storage.yandexcloud.net'

# Вывод информации об объектных хранилищах
  $ ycs3 ls
2022-12-19 18:11:59 netology-hw1503-encrypt
2022-12-19 18:11:59 hw15.rpotsel.ru

  $ ycs3 ls --recursive s3://netology-hw1503-encrypt
2022-12-19 18:13:00      16062 img/devops.png

  $ ycs3 ls --recursive s3://hw15.rpotsel.ru
2022-12-19 18:13:11      16062 devops.png
2022-12-19 18:13:11        213 error.html
2022-12-19 18:13:11        219 index.html

# Вывод информации о шифровании бакета netology-hw1503-encrypt
$ aws s3api get-bucket-encryption --bucket netology-hw1503-encrypt --endpoint-url=https://storage.yandexcloud.net
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:kms",
                    "KMSMasterKeyID": "abjhbajiac7qgt6mbttj"
                }
            }
        ]
    }
}

# Копирование с незашифрованного объектного хранилища
$ ycs3 cp s3://hw15.rpotsel.ru/devops.png 1.png
download: s3://hw15.rpotsel.ru/devops.png to ./1.png
$ ll 1.png 
-rw-rw-r-- 1 rpot rpot 16062 Dec 19 18:13 1.png

# При копировании с зашифрованного объектного хранилища выдается ошибка
$ ycs3 cp s3://netology-hw1503-encrypt/img/devops.png 2.png
download failed: s3://netology-hw1503-encrypt/img/devops.png to ./2.png An error occurred (AccessDenied) when calling the GetObject operation: Access Denied

# Чтобы расшифровывать объекты, у пользователя из под которого работает AWS CLI (aws-cli), кроме роли storage.editor, должна быть роль на чтение ключа шифрования - kms.keys.encrypterDecrypter
# https://cloud.yandex.ru/docs/storage/concepts/encryption
# https://cloud.yandex.ru/docs/iam/

  $ yc iam service-account list
+----------------------+----------+
|          ID          |   NAME   |
+----------------------+----------+
| aje048o20vbrqh1tqttr | aws-cli  |
| aje7d8cfirtboh8bgtml | ig-sa    |
| ajen2hmes6l9j89oeu5e | my-robot |
+----------------------+----------+

  $ yc resource-manager folder list-access-bindings netology
+----------------+----------------+----------------------+
|    ROLE ID     |  SUBJECT TYPE  |      SUBJECT ID      |
+----------------+----------------+----------------------+
| admin          | serviceAccount | ajen2hmes6l9j89oeu5e |
| editor         | serviceAccount | aje7d8cfirtboh8bgtml |
| storage.editor | serviceAccount | aje048o20vbrqh1tqttr |
+----------------+----------------+----------------------+

# Добавим роль и попробуем скопировать зашифрованные данные (успешно)
  $ yc resource-manager folder add-access-binding netology --role kms.keys.encrypterDecrypter --subject serviceAccount:aje048o20vbrqh1tqttr
  $ ycs3 cp s3://netology-hw1503-encrypt/img/devops.png 2.png
  download: s3://netology-hw1503-encrypt/img/devops.png to ./2.png 
  $ ll 2.png 
  -rw-rw-r-- 1 rpot rpot 16062 Dec 19 18:13 2.png

# Вывод информации об сертификатах зарегистрированных в Certificate Manager
# https://cloud.yandex.ru/docs/certificate-manager/
$ yc certificate-manager certificate list
+----------------------+------+------------+-----------+---------+------------+
|          ID          | NAME |  DOMAINS   | NOT AFTER |  TYPE   |   STATUS   |
+----------------------+------+------------+-----------+---------+------------+
| fpq0s1l5bsfc8jqim1au | hw15 | rpotsel.ru |           | MANAGED | VALIDATING |
+----------------------+------+------------+-----------+---------+------------+

# Вывод информации об статическом сайте
  $ aws s3api get-bucket-website --bucket hw15.rpotsel.ru --endpoint-url=https://storage.yandexcloud.net
{
    "IndexDocument": {
        "Suffix": "index.html"
    },
    "ErrorDocument": {
        "Key": "error.html"
    }
}
```
---
## Задание 2*. AWS (необязательное к выполнению)

1. С помощью роли IAM записать файлы ЕС2 в S3-бакет:
- Создать роль в IAM для возможности записи в S3 бакет;
- Применить роль к ЕС2-инстансу;
- С помощью бутстрап скрипта записать в бакет файл web-страницы.
2. Организация шифрования содержимого S3-бакета:
- Используя конфигурации, выполненные в рамках ДЗ на предыдущем занятии, добавить к созданному ранее bucket S3 возможность шифрования Server-Side, используя общий ключ;
- Включить шифрование SSE-S3 bucket S3 для шифрования всех вновь добавляемых объектов в данный bucket.
3. *Создание сертификата SSL и применение его к ALB:
- Создать сертификат с подтверждением по email;
- Сделать запись в Route53 на собственный поддомен, указав адрес LB;
- Применить к HTTPS запросам на LB созданный ранее сертификат.

Resource terraform
- [IAM Role](https://registry.tfpla.net/providers/hashicorp/aws/latest/docs/resources/iam_role)
- [AWS KMS](https://registry.tfpla.net/providers/hashicorp/aws/latest/docs/resources/kms_key)
- [S3 encrypt with KMS key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object#encrypting-with-kms-key)

Пример bootstrap-скрипта:
```
#!/bin/bash
yum install httpd -y
service httpd start
chkconfig httpd on
cd /var/www/html
echo "<html><h1>My cool web-server</h1></html>" > index.html
aws s3 mb s3://mysuperbacketname2021
aws s3 cp index.html s3://mysuperbacketname2021
```
