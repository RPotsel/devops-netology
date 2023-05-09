# 13.2 разделы и монтирование
Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
* установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
* добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

* ответ `helm install nfs-server stable/nfs-server-provisioner`

```BASH
  $ helm install nfs-server stable/nfs-server-provisioner
WARNING: This chart is deprecated
NAME: nfs-server
LAST DEPLOYED: Wed Sep 21 04:57:32 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The NFS Provisioner service has now been installed.

A storage class named 'nfs' has now been created
and is available to provision dynamic volumes.

You can use this storageclass by creating a `PersistentVolumeClaim` with the
correct storageClassName attribute. For example:

    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: test-dynamic-volume-claim
    spec:
      storageClassName: "nfs"
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi
```

## Задание 1: подключить для тестового конфига общую папку
В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

**Ответ:**

Приложения развернуты из [манифестов](./src/manifests/10-stage/) предыдущего задания, в контейнеры backend и была frontend [добавлена точка монтирования томов и локальный том](./src/manifests/10-stage/40-main.yml#L30-L45).

```BASH
# список подов
  $ kubectl get po
NAME                    READY   STATUS    RESTARTS   AGE
main-7bc5f765cf-4lmjk   2/2     Running   0          13m
postgres-db-0           1/1     Running   0          13m

# какие тома подключены
  $ kubectl describe po main-7bc5f765cf-4lmjk | grep Mounts: -A2
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-cpgcx (ro)
Containers:
--
    Mounts:
      /static from my-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-cpgcx (ro)
--
    Mounts:
      /static from my-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-cpgcx (ro)

# Создание файлов в контейнерах и поверка их видимости
  $ kubectl exec main-7bc5f765cf-4lmjk -c frontend -- sh -c "echo '42' > /static/42.txt"

  $ kubectl exec main-7bc5f765cf-4lmjk -c backend -- sh -c "echo '43' > /static/43.txt"

  $ kubectl exec main-7bc5f765cf-4lmjk -c frontend -- ls -la /static
total 16
drwxrwxrwx 2 root root 4096 Sep 21 05:18 .
drwxr-xr-x 1 root root 4096 Sep 21 05:01 ..
-rw-r--r-- 1 root root    3 Sep 21 05:17 42.txt
-rw-r--r-- 1 root root    3 Sep 21 05:18 43.txt
```

## Задание 2: подключить общую папку для прода
Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.

**Ответ:**

Установлен nfs-server через helm: `helm install nfs-server stable/nfs-server-provisioner` и пакет `nfs-common` на рабочую ноду. Приложения развернуты из [манифестов](./src/manifests/20-production/) предыдущего задания, [добавлен манифест заявки на том](./src/manifests/20-production/21-pvc.yml) и описание подключения томов для [фронтенда](./src/manifests/20-production/50-frontend.yml#L31-L37) и [бэкенда](./src/manifests/20-production/40-backend.yml#L37-L43)

```BASH
# Список классов
  $ kubectl get sc
NAME   PROVISIONER                                       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs    cluster.local/nfs-server-nfs-server-provisioner   Delete          Immediate           true                   3h46m

# Список томов
  $ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                       STORAGECLASS   REASON   AGE
pv-production                              256Mi      RWO            Retain           Bound    production/postgres-db-disk-postgres-db-0                           21m
pv-stage                                   256Mi      RWO            Retain           Bound    stage/postgres-db-disk-postgres-db-0                                3h41m
pvc-f86fc1e9-27d5-4a9b-a904-445eaf58b889   100Mi      RWX            Delete           Bound    production/pvc-nfs      

# Список заявок
  $ kubectl get pvc
NAME                             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
postgres-db-disk-postgres-db-0   Bound    pv-production                              256Mi      RWO                           24m
pvc-nfs                          Bound    pvc-f86fc1e9-27d5-4a9b-a904-445eaf58b889   100Mi      RWX            nfs            24m

# Список подключенных томов
  $ kubectl describe po backend-76bcbc8b55-hx9lh | grep Mounts: -A2
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jv42r (ro)
Containers:
--
    Mounts:
      /static from nfs-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jv42r (ro)

# Создание файлов в контейнерах и поверка их видимости
  $ kubectl exec frontend-67bcd4cfcf-cjtvn -- sh -c "echo '42' > /static/42-nfs.txt"
Defaulted container "frontend" out of: frontend, wait-backend (init)

  $ kubectl exec backend-76bcbc8b55-hx9lh -- sh -c "echo '42' > /static/43-nfs.txt"
Defaulted container "backend" out of: backend, wait-postgres (init)

  $ kubectl exec frontend-67bcd4cfcf-cjtvn -- ls -la /static
Defaulted container "frontend" out of: frontend, wait-backend (init)
total 16
drwxrwsrwx 2 root root 4096 Sep 21 08:54 .
drwxr-xr-x 1 root root 4096 Sep 21 08:42 ..
-rw-r--r-- 1 root root    3 Sep 21 08:52 42-nfs.txt
-rw-r--r-- 1 root root    3 Sep 21 08:54 43-nfs.txt
```
