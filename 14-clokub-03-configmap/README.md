# 14.3 Карты конфигураций

## Задача 1: Работа с картами конфигураций через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать карту конфигураций?

```
kubectl create configmap nginx-config --from-file=nginx.conf
kubectl create configmap domain --from-literal=name=netology.ru
```

### Как просмотреть список карт конфигураций?

```
kubectl get configmaps
kubectl get configmap
```

### Как просмотреть карту конфигурации?

```
kubectl get configmap nginx-config
kubectl describe configmap domain
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get configmap nginx-config -o yaml
kubectl get configmap domain -o json
```

### Как выгрузить карту конфигурации и сохранить его в файл?

```
kubectl get configmaps -o json > configmaps.json
kubectl get configmap nginx-config -o yaml > nginx-config.yml
```

### Как удалить карту конфигурации?

```
kubectl delete configmap nginx-config
```

### Как загрузить карту конфигурации из файла?

```
kubectl apply -f nginx-config.yml
```

**Ответ**

```BASH
 $ kubectl create configmap nginx-config --from-file=nginx.conf
configmap/nginx-config created
 
  $ kubectl create configmap domain --from-literal=name=netology.ru
configmap/domain created
 
  $ kubectl get configmaps
NAME               DATA   AGE
kube-root-ca.crt   1      12d
nginx-config       1      74s
domain             1      53s
 
  $ kubectl get configmap
NAME               DATA   AGE
kube-root-ca.crt   1      12d
nginx-config       1      84s
domain             1      63s
 
  $ kubectl get configmap nginx-config
NAME           DATA   AGE
nginx-config   1      103s
 
  $ kubectl describe configmap domain
Name:         domain
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
name:
----
netology.ru

BinaryData
====

Events:  <none>

  $ kubectl get configmap nginx-config -o yaml
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2022-11-09T17:47:13Z"
  name: nginx-config
  namespace: default
  resourceVersion: "121943"
  uid: 25219ace-c6d8-47e6-a842-ed6b5964ce67

  $ kubectl get configmap domain -o json
{
    "apiVersion": "v1",
    "data": {
        "name": "netology.ru"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2022-11-09T17:47:34Z",
        "name": "domain",
        "namespace": "default",
        "resourceVersion": "121981",
        "uid": "479cdc0d-d45e-4457-929e-c057198490e3"
    }
}

  $ kubectl get configmaps -o json > configmaps.json

  $ kubectl get configmap nginx-config -o yaml > nginx-config.yml

  $ kubectl delete configmap nginx-config
configmap "nginx-config" deleted

  $ kubectl apply -f nginx-config.yml
configmap/nginx-config created
```

## Задача 2 (*): Работа с картами конфигураций внутри модуля

Выбрать любимый образ контейнера, подключить карты конфигураций и проверить их доступность как в виде переменных окружения, так и в виде примонтированного тома.

**Ответ**

Изменен файл [манифеста](./src/vault/20-vault.yml) из прошлой лекции по хранению хранению секретов в репозитории `Vault`. Добавлена [карта конфигурации](./src/vault/00-config.yml) в которой хранится конфигурация `config.hcl` и переменная `VAULT_ADDR`.

```BASH
  $ kubectl apply -f .
configmap/vault-config created
persistentvolumeclaim/pvc-vault created
statefulset.apps/vault created
service/vault created

  $ kubectl get all
NAME          READY   STATUS    RESTARTS   AGE
pod/vault-0   1/1     Running   0          71s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/kubernetes   ClusterIP   10.152.183.1    <none>        443/TCP    13d
service/vault        ClusterIP   10.152.183.25   <none>        8200/TCP   71s

NAME                     READY   AGE
statefulset.apps/vault   1/1     71s

  $ kubectl get configmaps 
NAME               DATA   AGE
kube-root-ca.crt   1      13d
vault-config       2      3m1s

  $ kubectl logs pod/vault-0 
==> Vault server configuration:

                     Cgo: disabled
              Go Version: go1.19.2
              Listener 1: tcp (addr: "[::]:8200", cluster address: "[::]:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
               Log Level: debug
                   Mlock: supported: true, enabled: true
           Recovery Mode: false
                 Storage: file
                 Version: Vault v1.12.1, built 2022-10-27T12:32:05Z
             Version Sha: e34f8a14fb7a88af4640b09f3ddbb5646b946d9c

2022-11-09T19:40:01.390Z [INFO]  proxy environment: http_proxy="" https_proxy="" no_proxy=""
2022-11-09T19:40:01.391Z [WARN]  no `api_addr` value specified in config or in VAULT_API_ADDR; falling back to detection if possible, but this value should be manually set
==> Vault server started! Log data will stream in below:
2022-11-09T19:40:01.392Z [DEBUG] core: set config: sanitized config="{\"api_addr\":\"\",\"cache_size\":0,\"cluster_addr\":\"\",\"cluster_cipher_suites\":\"\",\"cluster_name\":\"\",\"default_lease_ttl\":0,\"default_max_request_duration\":0,\"disable_cache\":false,\"disable_clustering\":false,\"disable_indexing\":false,\"disable_mlock\":false,\"disable_performance_standby\":false,\"disable_printable_check\":false,\"disable_sealwrap\":false,\"disable_sentinel_trace\":false,\"enable_response_header_hostname\":false,\"enable_response_header_raft_node_id\":false,\"enable_ui\":true,\"listeners\":[{\"config\":{\"address\":\"[::]:8200\",\"tls_disable\":1},\"type\":\"tcp\"}],\"log_format\":\"unspecified\",\"log_level\":\"debug\",\"log_requests_level\":\"\",\"max_lease_ttl\":0,\"pid_file\":\"\",\"plugin_directory\":\"\",\"plugin_file_permissions\":0,\"plugin_file_uid\":0,\"raw_storage_endpoint\":false,\"seals\":[{\"disabled\":false,\"type\":\"shamir\"}],\"storage\":{\"cluster_addr\":\"\",\"disable_clustering\":false,\"redirect_addr\":\"\",\"type\":\"file\"}}"

2022-11-09T19:40:01.392Z [DEBUG] storage.cache: creating LRU cache: size=0
2022-11-09T19:40:02.100Z [INFO]  core: Initializing version history cache for core
2022-11-09T19:40:02.101Z [DEBUG] cluster listener addresses synthesized: cluster_addresses=[[::]:8201]
2022-11-09T19:40:02.101Z [DEBUG] would have sent systemd notification (systemd not present): notification=READY=1
```