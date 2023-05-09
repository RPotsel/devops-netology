# 12.4 Развертывание кластера на собственных серверах, лекция 2

Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

## Задание 1: Подготовить инвентарь kubespray
Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
* подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
* в качестве CRI — containerd;
* запуск etcd производить на мастере.

**Ответ:**

* Подготовленные ВМ в Yandex Cloud

```BASH
  $ yc compute instance list
+----------------------+-----------+---------------+---------+---------------+-------------+
|          ID          |   NAME    |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP |
+----------------------+-----------+---------------+---------+---------------+-------------+
| fhm0la00li205gq51pi9 | worker02  | ru-central1-a | RUNNING | 51.250.92.36  | 10.0.0.16   |
| fhm3vsncgcu78ujkhjjm | worker04  | ru-central1-a | RUNNING | 51.250.80.220 | 10.0.0.10   |
| fhm50q6k1l2o9urepggh | control01 | ru-central1-a | RUNNING | 84.201.135.70 | 10.0.0.29   |
| fhmci913674ar36vqsth | worker03  | ru-central1-a | RUNNING | 62.84.126.105 | 10.0.0.31   |
| fhmoo9mg9h11gh346amp | worker01  | ru-central1-a | RUNNING | 84.201.135.72 | 10.0.0.24   |
+----------------------+-----------+---------------+---------+---------------+-------------+
```

* Информация о нодах кластера Kubernetes

```BASH
ubuntu@control01:~$ kubectl get nodes -o wide
NAME        STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
control01   Ready    control-plane   12m   v1.24.4   10.0.0.29     <none>        Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.8
worker01    Ready    <none>          10m   v1.24.4   10.0.0.24     <none>        Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.8
worker02    Ready    <none>          10m   v1.24.4   10.0.0.16     <none>        Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.8
worker03    Ready    <none>          10m   v1.24.4   10.0.0.31     <none>        Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.8
worker04    Ready    <none>          10m   v1.24.4   10.0.0.10     <none>        Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.8
```

* Информация о базе данных etcd

```BASH
ubuntu@control01:~$ sudo etcdctl endpoint status --write-out=table --endpoints=127.0.0.1:2379 --cacert=/etc/ssl/etcd/ssl/ca.pem --cert=/etc/ssl/etcd/ssl/node-control01.pem --key=/etc/ssl/etcd/ssl/node-control01-key.pem 
+----------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|    ENDPOINT    |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| 127.0.0.1:2379 | 20c1df3bc6c542ae |   3.5.4 |   10 MB |      true |      false |         3 |       4962 |               4962 |        |
+----------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```

## Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
* разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
* работать должны на минимально допустимых EC2 — t3.small.

**Ответ:**

Развертывание ВМ выполняется в Yandex Cloud [скриптами Terraform](./src/terraform/). Скрипты подготавливают папку [inventory](./src/terraform/inventory.tf) и запускают набор [Ansible ролей Kubespray](./src/terraform/ansible.tf) с указанием [файла приоритетных переменных](./src/terraform/inventory/extra_vars.yml) `extra-vars`, в котором предъявлены требования к конфигурации кластера. Конфигурация создаваемых ВМ задается в [переменных скрипта](./src/terraform/variables.tf).

* [Лог запуска Terraform](./src/terraform/14-4-terraform.out)
