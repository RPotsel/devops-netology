# 14.1 Создание и использование секретов

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Выполните приведённые ниже команды в консоли, получите вывод команд. Сохраните задачу 1 как справочный материал.

### Как создать секрет?

```
openssl genrsa -out cert.key 4096
openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key
```

### Как просмотреть список секретов?

```
kubectl get secrets
kubectl get secret
```

### Как просмотреть секрет?

```
kubectl get secret domain-cert
kubectl describe secret domain-cert
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get secret domain-cert -o yaml
kubectl get secret domain-cert -o json
```

### Как выгрузить секрет и сохранить его в файл?

```
kubectl get secrets -o json > secrets.json
kubectl get secret domain-cert -o yaml > domain-cert.yml
```

### Как удалить секрет?

```
kubectl delete secret domain-cert
```

### Как загрузить секрет из файла?

```
kubectl apply -f domain-cert.yml
```

**Ответ:**

```
  $ openssl genrsa -out cert.key 4096

  $ openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'

  $ kubectl create secret tls domain-cert --cert=cert.crt --key=cert.key
secret/domain-cert created

  $ kubectl get secrets
NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      41s

  $ kubectl describe secret domain-cert
Name:         domain-cert
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1944 bytes
tls.key:  3272 bytes

  $ kubectl get secrets -o json > secrets.json

  $ kubectl get secret domain-cert -o yaml > domain-cert.yml
 
  $ kubectl delete secret domain-cert
secret "domain-cert" deleted

  $ kubectl apply -f domain-cert.yml
secret/domain-cert created
```

## Задача 2 (*): Работа с секретами внутри модуля

Выберите любимый образ контейнера, подключите секреты и проверьте их доступность как в виде переменных окружения, так и в виде примонтированного тома.

**Ответ:**

* Сертификаты и данные загружаются из файлов в объекты `tls` и `Opaque` с помощью аргументов `kubectl`. [Манифест приложения](./src/app.yaml) монтирует созданные сертификаты в указанный том и передаёт данные `Opaque` в переменные окружения. Требуемая информация выводится в `stdout`.

```
  $ kubectl create secret tls domain-cert --cert=cert.crt --key=cert.key
secret/domain-cert created

  $ kubectl create secret generic credentials --from-env-file ./credentials.txt
secret/credentials created

  $ kubectl apply -f app.yaml 
pod/secret-test-pod created

  $ kubectl get secrets 
NAME                TYPE                       DATA   AGE
credentials         Opaque                     2      38s
domain-cert         kubernetes.io/tls          2      105m

  $ kubectl get po
NAME              READY   STATUS      RESTARTS   AGE
secret-test-pod   0/1     Completed   0          40s

  $ kubectl logs pod/secret-test-pod 
total 0
lrwxrwxrwx    1 root     root            14 Oct 31 18:06 tls.crt -> ..data/tls.crt
lrwxrwxrwx    1 root     root            14 Oct 31 18:06 tls.key -> ..data/tls.key
SECRET_PASSWORD=t0p-Secret
SECRET_USERNAME=admin
```
