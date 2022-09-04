# 12.5 Сетевые решения CNI - Роман Поцелуев
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.

## Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования:

* установка производится через ansible/kubespray;
* после применения следует настроить политику доступа к hello world извне.

**Ответ:**

* Созданные с помощью скриптов [terraform](./src/terraform/) ВМ кластера kubernetes в Yandex Cloud

```BASH
  $ yc compute instance list
+----------------------+-----------+---------------+---------+----------------+-------------+
|          ID          |   NAME    |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+-----------+---------------+---------+----------------+-------------+
| fhm5omou9f0v6j4p50b6 | worker01  | ru-central1-a | RUNNING | 84.252.130.163 | 10.0.0.4    |
| fhmdq6a7heho0udv3kqv | control01 | ru-central1-a | RUNNING | 84.252.130.201 | 10.0.0.10   |
+----------------------+-----------+---------------+---------+----------------+-------------+
```

* Проверка установки CNI Calico

```BASH
ubuntu@control01:~$ ls /etc/cni/net.d
10-calico.conflist  calico.conflist.template  calico-kubeconfig

ubuntu@control01:~$ ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             10.0.0.10/24 fe80::d20d:ddff:fe19:478b/64 
kube-ipvs0       DOWN           10.233.0.1/32 10.233.0.3/32 10.233.6.92/32 10.233.19.219/32 
vxlan.calico     UNKNOWN        10.233.120.64/32 fe80::645b:dbff:fecd:b3c2/64 
cali846a55759d7@if3 UP             fe80::ecee:eeff:feee:eeee/64 
calic779cccdc69@if3 UP             fe80::ecee:eeff:feee:eeee/64 
nodelocaldns     DOWN           169.254.25.10/32 
```

* Создание [ресурсов](./src/manifests/main/)

```BASH
ubuntu@control01:~$ kubectl apply -f ./manifests/main/
deployment.apps/hello-world created
service/hello-world created
deployment.apps/backend created
service/backend created
ubuntu@control01:~$ kubectl get nodes,deploy,service -o wide
NAME             STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
node/control01   Ready    control-plane   69m   v1.24.4   10.0.0.10     <none>        Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.8
node/worker01    Ready    <none>          67m   v1.24.4   10.0.0.4      <none>        Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.8

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS          IMAGES                                  SELECTOR
deployment.apps/backend       1/1     1            1           10s   network-multitool   praqma/network-multitool:alpine-extra   app=backend
deployment.apps/hello-world   1/1     1            1           10s   echoserver          k8s.gcr.io/echoserver:1.4               app=hello-world

NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE   SELECTOR
service/backend       ClusterIP      10.233.19.219   <none>        80/TCP           10s   app=backend
service/hello-world   LoadBalancer   10.233.6.92     <pending>     8080:31954/TCP   10s   app=hello-world
service/kubernetes    ClusterIP      10.233.0.1      <none>        443/TCP          69m   <none>
```

* Проверка доступа к сервисам внутри ВМ кластера, доступ есть

```BASH
ubuntu@control01:~$ curl -s -m 1 10.233.6.92:8080 | egrep "client|uri|host"
client_address=10.233.120.64
request_uri=http://10.233.6.92:8080/
host=10.233.6.92:8080

ubuntu@control01:~$ curl -s -m 1 10.233.19.219
Praqma Network MultiTool (with NGINX) - backend-869fd89bdc-x4r6f - 10.233.69.8

ubuntu@control01:~$ kubectl exec backend-869fd89bdc-x4r6f -- curl -s -m 1 hello-world:8080 | egrep "client|uri|host"
client_address=10.233.69.8
request_uri=http://hello-world:8080/
host=hello-world:8080
```

* Проверка доступа к hello world снаружи к nodePort, доступ есть

```BASH
rpot@rp-srv-ntlg03:~$ curl -m 1 -s http://84.252.130.201:31954 | egrep "client|uri|host"
client_address=10.233.120.64
request_uri=http://84.252.130.201:8080/
host=84.252.130.201:31954
```

* Установка [политики](./src/manifests/network-policy/00-default-ingress-deny.yml) запрета входящего трафика для default подов и проверка доступа к сервисам внутри ВМ кластера, доступа нет

```BASH
ubuntu@control01:~$ kubectl apply -f ./manifests/network-policy/00-default-ingress-deny.yml
networkpolicy.networking.k8s.io/default-deny-all created

ubuntu@control01:~$ kubectl get netpol -A
NAMESPACE   NAME                   POD-SELECTOR   AGE
default     default-ingress-deny   <none>         39s

ubuntu@control01:~$ curl -m 1 10.233.6.92:8080
curl: (28) Connection timed out after 1000 milliseconds

ubuntu@control01:~$ curl -m 1 10.233.19.219
curl: (28) Connection timed out after 1001 milliseconds

ubuntu@control01:~$ kubectl exec backend-869fd89bdc-x4r6f -- curl -m 1 hello-world:8080
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:05 --:--:--     0
curl: (28) Resolving timed out after 1000 milliseconds
command terminated with exit code 28
```

* Проверка доступа к hello world снаружи к nodePort, доступа нет

```BASH
rpot@rp-srv-ntlg03:~$ curl -m 1  http://84.252.130.201:31954
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0
curl: (28) Connection timed out after 1002 milliseconds
```

* Установка [политики](./src/manifests/network-policy/10-hello-world.yml) для пода hello world

```BASH
ubuntu@control01:~$ kubectl apply -f ./manifests/network-policy/10-hello-world.yml
networkpolicy.networking.k8s.io/hello-world created
ubuntu@control01:~$ kubectl get netpol -A
NAMESPACE   NAME                   POD-SELECTOR      AGE
default     default-ingress-deny   <none>            19m
default     hello-world            app=hello-world   2s
```

* Проверка доступа к hello-world внутри ВМ, доступ есть

```BASH
ubuntu@control01:~$ curl -m 1 -s hello-world:8080 | egrep "client|uri|host"
client_address=10.233.120.64
request_uri=http://hello-world:8080/
host=hello-world:8080

ubuntu@control01:~$ kubectl exec backend-869fd89bdc-x4r6f -- curl -m 1 -s hello-world:8080 | egrep "client|uri|host"
client_address=10.233.69.8
request_uri=http://hello-world:8080/
host=hello-world:8080
```

* Проверка доступа к hello world снаружи к nodePort, доступ есть

```BASH
rpot@rp-srv-ntlg03:~$ curl -m 1 -s http://84.252.130.201:31954 | egrep "client|uri|host"
client_address=10.233.120.64
request_uri=http://84.252.130.201:8080/
host=84.252.130.201:31954
```

## Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования:

* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.

**Ответ:**

* Установка утилиты

```BASH
ubuntu@control01:~$ curl -L https://github.com/projectcalico/calico/releases/download/v3.24.1/calicoctl-linux-amd64 -o calicoctl
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 56.7M  100 56.7M    0     0  17.8M      0  0:00:03  0:00:03 --:--:-- 20.2M
ubuntu@control01:~$ chmod +x ./calicoctl
```

* Консоли node ipPool и profile

```BASH
ubuntu@control01:~$ calicoctl get node -o wide
NAME        ASN       IPV4           IPV6
control01   (64512)   10.0.0.10/24
worker01    (64512)   10.0.0.4/24

ubuntu@control01:~$ calicoctl get ipPool -o wide
NAME           CIDR             NAT    IPIPMODE   VXLANMODE   DISABLED   DISABLEBGPEXPORT   SELECTOR
default-pool   10.233.64.0/18   true   Never      Always      false      false              all()

ubuntu@control01:~$ calicoctl get profile
NAME
projectcalico-default-allow
kns.default
kns.kube-node-lease
kns.kube-public
kns.kube-system
ksa.default.default
ksa.kube-node-lease.default
ksa.kube-public.default
ksa.kube-system.attachdetach-controller
ksa.kube-system.bootstrap-signer
ksa.kube-system.calico-node
ksa.kube-system.certificate-controller
ksa.kube-system.clusterrole-aggregation-controller
ksa.kube-system.coredns
ksa.kube-system.cronjob-controller
ksa.kube-system.daemon-set-controller
ksa.kube-system.default
ksa.kube-system.deployment-controller
ksa.kube-system.disruption-controller
ksa.kube-system.dns-autoscaler
ksa.kube-system.endpoint-controller
ksa.kube-system.endpointslice-controller
ksa.kube-system.endpointslicemirroring-controller
ksa.kube-system.ephemeral-volume-controller
ksa.kube-system.expand-controller
ksa.kube-system.generic-garbage-collector
ksa.kube-system.horizontal-pod-autoscaler
ksa.kube-system.job-controller
ksa.kube-system.kube-proxy
ksa.kube-system.namespace-controller
ksa.kube-system.node-controller
ksa.kube-system.nodelocaldns
ksa.kube-system.persistent-volume-binder
ksa.kube-system.pod-garbage-collector
ksa.kube-system.pv-protection-controller
ksa.kube-system.pvc-protection-controller
ksa.kube-system.replicaset-controller
ksa.kube-system.replication-controller
ksa.kube-system.resourcequota-controller
ksa.kube-system.root-ca-cert-publisher
ksa.kube-system.service-account-controller
ksa.kube-system.service-controller
ksa.kube-system.statefulset-controller
ksa.kube-system.token-cleaner
ksa.kube-system.ttl-after-finished-controller
ksa.kube-system.ttl-controller
```
