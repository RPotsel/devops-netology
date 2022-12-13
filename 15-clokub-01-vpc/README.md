# Домашнее задание к занятию "15.1. Организация сети"

Домашнее задание будет состоять из обязательной части, которую необходимо выполнить на провайдере Яндекс.Облако и дополнительной части в AWS по желанию. Все домашние задания в 15 блоке связаны друг с другом и в конце представляют пример законченной инфраструктуры.
Все задания требуется выполнить с помощью Terraform, результатом выполненного домашнего задания будет код в репозитории. 

Перед началом работ следует настроить доступ до облачных ресурсов из Terraform используя материалы прошлых лекций и [ДЗ](https://github.com/netology-code/virt-homeworks/tree/master/07-terraform-02-syntax ). А также заранее выбрать регион (в случае AWS) и зону.

---
## Задание 1. Яндекс.Облако (обязательное к выполнению)

1. Создать VPC.
- Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.
- Создать в vpc subnet с названием public.
- Создать в этой подсети NAT-инстанс. В качестве image_id использовать fd80mrhj8fl2oe87o4e1
- Создать в этой публичной подсети виртуалку с публичным IP и подключиться к ней, убедиться что есть доступ к интернету.
1. Приватная подсеть.
- Создать в vpc subnet с названием private.
- Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс
- Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее и убедиться что есть доступ к интернету

Resource terraform для ЯО
- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet)
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table)
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance)

**Ответ:**

Выполним развертывание виртуальных машин с требуемыми параметрами в облачной платформе `Yandex Cloud`. Для автоматизации работы с инфраструктурой воспользуемся решением `Terraform`, для которого платформа `Yandex Cloud` предоставляет провайдер. Опишем созданные конфигурационные файлы `Terraform`:

* [variables.tf](./terraform/variables.tf) - указание переменных, используемых в сценарии развертывания;
* [provider.tf](./terraform/provider.tf) - объявление поставщика услуг `yandex-cloud/yandex`;
* [network.tf](./terraform/network.tf) - создание `public`, `private` подсетей и создание таблицы маршрутизации для общей сети с переадресацией исходящего трафика 0.0.0.0/0 на ВМ с NAT адресом в соответствии с документом https://cloud.yandex.ru/docs/vpc/operations/static-route-create;
* [main.tf](./terraform/main.tf) - создание ВМ с NAT адресом из образа с преднастроенными правилами маршрутизации и трансляции IP-адресов, и ВМ, подключенной к внутренней подсети для проверки подключения к ресурсам Интернет согласно документа https://cloud.yandex.ru/docs/tutorials/routing/nat-instance.

Выведем список созданных ресурсов после применения конфигурационных файлов `Terraform`:

```
  $ yc compute instances list
+----------------------+--------------+---------------+---------+---------------+--------------+
|          ID          |     NAME     |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP  |
+----------------------+--------------+---------------+---------+---------------+--------------+
| fhmck7lmnrk96j08gbkf | node         | ru-central1-a | RUNNING |               | 172.31.96.17 |
| fhmcke9pak09feeivrrt | nat-instance | ru-central1-a | RUNNING | 51.250.90.207 | 172.31.32.24 |
+----------------------+--------------+---------------+---------+---------------+--------------+

  $ yc vpc networks list
+----------------------+--------------+
|          ID          |     NAME     |
+----------------------+--------------+
| enpo00rt1lb2l3efi8l8 | Network 15-1 |
+----------------------+--------------+

  $ yc vpc subnet list
+----------------------+----------------------+----------------------+----------------------+---------------+------------------+
|          ID          |         NAME         |      NETWORK ID      |    ROUTE TABLE ID    |     ZONE      |      RANGE       |
+----------------------+----------------------+----------------------+----------------------+---------------+------------------+
| e9b1h8p67vd151brfq84 | Public Network 15-1  | enpo00rt1lb2l3efi8l8 |                      | ru-central1-a | [172.31.32.0/19] |
| e9b941r29lv3ce2k68jt | Private Network 15-1 | enpo00rt1lb2l3efi8l8 | enpqhph877rpnfcmcjgr | ru-central1-a | [172.31.96.0/19] |
+----------------------+----------------------+----------------------+----------------------+---------------+------------------+

  $ yc vpc route-table get enpqhph877rpnfcmcjgr
id: enpqhph877rpnfcmcjgr
folder_id: b1gu9vr18o6v8qc41svt
created_at: "2022-11-25T16:16:23Z"
name: Route table for Network 15-1
network_id: enpo00rt1lb2l3efi8l8
static_routes:
  - destination_prefix: 0.0.0.0/0
    next_hop_address: 172.31.32.24

```

Копируем закрытий ключ на `nat-instance`, подключимся к внутренней ВМ `node` и запустим ping до внешнего ресурса.

```
  $ scp ~/.ssh/id_rsa ubuntu@51.250.90.207:/home/ubuntu/.ssh/
id_rsa                                                             100% 3381    94.5KB/s   00:00

  $ ssh -t ubuntu@51.250.90.207 ssh ubuntu@172.31.96.17
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.4.0-132-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
New release '22.04.1 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Fri Nov 25 16:33:51 2022 from 172.31.32.24
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@node:~$ ping ya.ru
PING ya.ru (87.250.250.242) 56(84) bytes of data.
64 bytes from ya.ru (87.250.250.242): icmp_seq=1 ttl=56 time=0.968 ms
64 bytes from ya.ru (87.250.250.242): icmp_seq=2 ttl=56 time=1.11 ms
64 bytes from ya.ru (87.250.250.242): icmp_seq=3 ttl=56 time=0.879 ms
...
```

Чтобы убедиться, что трафик действительно проходит через `nat-instance`, снимем трафик для `private` подсети утилитой `tcpdump` с этой ВМ. Видно, что `ICMP` запросы к `ya.ru` идут c ВМ `node`.

```
ubuntu@nat-instance:~$ sudo tcpdump -nni any net 172.31.96.0/24 and port ! 22 -c 10
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 262144 bytes
16:54:41.086332 IP 172.31.96.17 > 87.250.250.242: ICMP echo request, id 5, seq 351, length 64
16:54:41.087019 IP 87.250.250.242 > 172.31.96.17: ICMP echo reply, id 5, seq 351, length 64
16:54:42.087932 IP 172.31.96.17 > 87.250.250.242: ICMP echo request, id 5, seq 352, length 64
16:54:42.088516 IP 87.250.250.242 > 172.31.96.17: ICMP echo reply, id 5, seq 352, length 64
16:54:43.089374 IP 172.31.96.17 > 87.250.250.242: ICMP echo request, id 5, seq 353, length 64
16:54:43.090073 IP 87.250.250.242 > 172.31.96.17: ICMP echo reply, id 5, seq 353, length 64
16:54:44.090970 IP 172.31.96.17 > 87.250.250.242: ICMP echo request, id 5, seq 354, length 64
16:54:44.091580 IP 87.250.250.242 > 172.31.96.17: ICMP echo reply, id 5, seq 354, length 64
16:54:45.092448 IP 172.31.96.17 > 87.250.250.242: ICMP echo request, id 5, seq 355, length 64
16:54:45.093042 IP 87.250.250.242 > 172.31.96.17: ICMP echo reply, id 5, seq 355, length 64
10 packets captured
10 packets received by filter
0 packets dropped by kernel
```

---
## Задание 2*. AWS (необязательное к выполнению)

1. Создать VPC.
- Cоздать пустую VPC с подсетью 10.10.0.0/16.
2. Публичная подсеть.
- Создать в vpc subnet с названием public, сетью 10.10.1.0/24
- Разрешить в данной subnet присвоение public IP по-умолчанию. 
- Создать Internet gateway 
- Добавить в таблицу маршрутизации маршрут, направляющий весь исходящий трафик в Internet gateway.
- Создать security group с разрешающими правилами на SSH и ICMP. Привязать данную security-group на все создаваемые в данном ДЗ виртуалки
- Создать в этой подсети виртуалку и убедиться, что инстанс имеет публичный IP. Подключиться к ней, убедиться что есть доступ к интернету.
- Добавить NAT gateway в public subnet.
3. Приватная подсеть.
- Создать в vpc subnet с названием private, сетью 10.10.2.0/24
- Создать отдельную таблицу маршрутизации и привязать ее к private-подсети
- Добавить Route, направляющий весь исходящий трафик private сети в NAT.
- Создать виртуалку в приватной сети.
- Подключиться к ней по SSH по приватному IP через виртуалку, созданную ранее в публичной подсети и убедиться, что с виртуалки есть выход в интернет.

Resource terraform
- [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
- [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)
- [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)
