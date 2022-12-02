# Домашнее задание к занятию "14.4 Сервис-аккаунты"

## Задача 1: Работа с сервис-аккаунтами через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните задачу 1 как справочный материал.

### Как создать сервис-аккаунт?

```
kubectl create serviceaccount netology
```

### Как просмотреть список сервис-акаунтов?

```
kubectl get serviceaccounts
kubectl get serviceaccount
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get serviceaccount netology -o yaml
kubectl get serviceaccount default -o json
```

### Как выгрузить сервис-акаунты и сохранить его в файл?

```
kubectl get serviceaccounts -o json > serviceaccounts.json
kubectl get serviceaccount netology -o yaml > netology.yml
```

### Как удалить сервис-акаунт?

```
kubectl delete serviceaccount netology
```

### Как загрузить сервис-акаунт из файла?

```
kubectl apply -f netology.yml
```

**Ответ**

```
  $ kubectl create sa netology
serviceaccount/netology created

  $ kubectl get sa
NAME       SECRETS   AGE
default    0         16d
netology   0         101s

  $ kubectl get sa netology -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-11-13T13:26:44Z"
  name: netology
  namespace: default
  resourceVersion: "157327"
  uid: 0e1593de-b609-479c-98f6-5cecedffaeef

  $ kubectl get sa netology -o json
{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2022-11-13T13:26:44Z",
        "name": "netology",
        "namespace": "default",
        "resourceVersion": "157327",
        "uid": "0e1593de-b609-479c-98f6-5cecedffaeef"
    }
}

  $ kubectl get sa -o json > serviceaccounts.json

  $ kubectl get sa netology -o yaml > netology.yml

  $ kubectl delete sa netology
serviceaccount "netology" deleted

  $ kubectl apply -f netology.yml
serviceaccount/netology created
```

## Задача 2 (*): Работа с сервис-акаунтами внутри модуля

Выбрать любимый образ контейнера, подключить сервис-акаунты и проверить доступность API Kubernetes

```
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Просмотреть переменные среды

```
env | grep KUBE
```

Получить значения переменных

```
K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
SADIR=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat $SADIR/token)
CACERT=$SADIR/ca.crt
NAMESPACE=$(cat $SADIR/namespace)
```

Подключаемся к API

```
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
```

В случае с minikube может быть другой адрес и порт, который можно взять здесь

```
cat ~/.kube/config
```

или здесь

```
kubectl cluster-info
```

**Ответ**

[Манифест](./src/00-app.yml) создает сервисный аккаунт и запускает контейнер `multitool`, в котором проверяется доступность API Kubernetes.

```
  $ kubectl apply -f 00-app.yml 
serviceaccount/netology created
pod/multitool created

  $ kubectl exec -it multitool -- sh

/ # env | grep KUBE
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.152.183.1:443
KUBERNETES_PORT_443_TCP_ADDR=10.152.183.1
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP=tcp://10.152.183.1:443
KUBERNETES_SERVICE_HOST=10.152.183.1
/ # K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
/ # SADIR=/var/run/secrets/kubernetes.io/serviceaccount
/ # TOKEN=$(cat $SADIR/token)
/ # CACERT=$SADIR/ca.crt
/ # NAMESPACE=$(cat $SADIR/namespace)

/ # curl -sH "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/ | head
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      "name": "bindings",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
/ # 
```
