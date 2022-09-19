# 13.1 контейнеры, поды, deployment, statefulset, services, endpoints - Роман Поцелуев
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

**Ответ:**

Для развертывания приложения применяются следующие манифесты:
* [Создание пространства имен](./src/manifests/10-stage/10-namespace.yml)
* [Создание хранилища данных](./src/manifests/10-stage/20-pv.yml)
* [Создание пода базы данных и сервиса](./src/manifests/10-stage/30-db.yml)
* [Создание пода бэкенда и фронта](./src/manifests/10-stage/40-main.yml)

```BASH
  $ kubectl config set-context --current --namespace=stage
Context "kubernetes-admin@cluster.local" modified.

  $ kubectl get all -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
pod/main-75bccb8d58-2pgvv   2/2     Running   0          71m   10.233.69.12   worker01   <none>           <none>
pod/postgres-db-0           1/1     Running   0          71m   10.233.69.13   worker01   <none>           <none>

NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/postgres-db-cip   ClusterIP   10.233.40.149   <none>        5432/TCP   71m   app=postgres-db

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS         IMAGES                                           SELECTOR
deployment.apps/main   1/1     1            1           71m   frontend,backend   rpot/13-01-frontend:0.1,rpot/13-01-backend:0.1   app=13-01-main

NAME                              DESIRED   CURRENT   READY   AGE   CONTAINERS         IMAGES                                           SELECTOR
replicaset.apps/main-75bccb8d58   1         1         1       71m   frontend,backend   rpot/13-01-frontend:0.1,rpot/13-01-backend:0.1   app=13-01-main,pod-template-hash=75bccb8d58

NAME                           READY   AGE   CONTAINERS    IMAGES
statefulset.apps/postgres-db   1/1     71m   postgres-db   postgres:13-alpine

  $ kubectl get ep -o wide
NAME              ENDPOINTS           AGE
postgres-db-cip   10.233.69.13:5432   73m

  $ kubectl get pv
NAME            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                       STORAGECLASS   REASON   AGE
pv-production   256Mi      RWO            Retain           Bound    production/postgres-db-disk-postgres-db-0                           135m
pv-stage        256Mi      RWO            Retain           Bound    stage/postgres-db-disk-postgres-db-0                                76m
```

## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

**Ответ:**

Для развертывания приложения применяются следующие манифесты:

* [Создание пространства имен](./src/manifests/20-production/10-namespace.yml)
* [Создание хранилища данных](./src/manifests/20-production/20-pv.yml)
* [Создание пода базы данных и сервиса](./src/manifests/20-production/30-db.yml)
* [Создание пода бэкенда и сервиса](./src/manifests/20-production/40-backend.yml)
* [Создание пода фронта и сервиса](./src/manifests/20-production/50-frontend.yml)

```BASH
  $ kubectl config set-context --current --namespace=production
Context "kubernetes-admin@cluster.local" modified.

  $ kubectl get all -o wide
NAME                           READY   STATUS    RESTARTS   AGE    IP            NODE       NOMINATED NODE   READINESS GATES
pod/backend-6d9bc855fc-s7n6q   1/1     Running   0          116m   10.233.69.6   worker01   <none>           <none>
pod/frontend-b764b69ff-s2887   1/1     Running   0          84m    10.233.69.9   worker01   <none>           <none>
pod/postgres-db-0              1/1     Running   0          132m   10.233.69.4   worker01   <none>           <none>

NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE    SELECTOR
service/backend-cip       ClusterIP      10.233.36.71    <none>        9000/TCP       116m   app=13-01-backend
service/frontend-lb       LoadBalancer   10.233.37.117   <pending>     80:31270/TCP   84m    app=13-01-frontend
service/postgres-db-cip   ClusterIP      10.233.37.31    <none>        5432/TCP       132m   app=postgres-db

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES                    SELECTOR
deployment.apps/backend    1/1     1            1           116m   backend      rpot/13-01-backend:0.1    app=13-01-backend
deployment.apps/frontend   1/1     1            1           84m    frontend     rpot/13-01-frontend:0.1   app=13-01-frontend

NAME                                 DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES                    SELECTOR
replicaset.apps/backend-6d9bc855fc   1         1         1       116m   backend      rpot/13-01-backend:0.1    app=13-01-backend,pod-template-hash=6d9bc855fc
replicaset.apps/frontend-b764b69ff   1         1         1       84m    frontend     rpot/13-01-frontend:0.1   app=13-01-frontend,pod-template-hash=b764b69ff

NAME                           READY   AGE    CONTAINERS    IMAGES
statefulset.apps/postgres-db   1/1     132m   postgres-db   postgres:13-alpine

  $ kubectl get ep -o wide
NAME              ENDPOINTS          AGE
backend-cip       10.233.69.6:9000   117m
frontend-lb       10.233.69.9:80     85m
postgres-db-cip   10.233.69.4:5432   133m

  $ curl 51.250.72.68:31270
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>
```

## Задание 3 (*): добавить endpoint на внешний ресурс api
Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
* добавлен endpoint до внешнего api (например, геокодер).

**Ответ:**

* [манифест создания сервиса и точки подключения](./src/manifests/30-endpoint/10-endpoint.yml)

```BASH
  $ kubectl get svc -n default
NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
external-geocode   ClusterIP   10.233.1.100   <none>        443/TCP   10m
kubernetes         ClusterIP   10.233.0.1     <none>        443/TCP   146m

  $ kubectl get ep -n default
NAME               ENDPOINTS           AGE
external-geocode   13.248.207.97:443   10m
kubernetes         10.0.0.33:6443      146m

  $ kubectl exec -it frontend-b764b69ff-s2887 -- sh
Defaulted container "frontend" out of: frontend, wait-backend (init)

# curl -sk 'https://external-geocode/data/reverse-geocode-client?latitude=59.938180&longitude=30.314808&localityLanguage=en'
{
  "latitude": 59.93818,
  "longitude": 30.314808,
  "continent": "Europe",
  "lookupSource": "coordinates",
  "continentCode": "EU",
  "localityLanguageRequested": "en",
  "city": "Saint Petersburg",
  "countryName": "Russia",
  "countryCode": "RU",
  "postcode": "",
  "principalSubdivision": "Northwestern Federal District",
  "principalSubdivisionCode": "",
  "plusCode": "9GFGW8Q7+7W",
  "locality": "Admiral Island",
  "localityInfo": {
```