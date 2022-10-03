# 13.3 работа с kubectl - Роман Поцелуев
## Задание 1: проверить работоспособность каждого компонента
Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.

**Ответ:**

* Список ресурсов после создания

```BASH
$ kubectl get all
NAME                             READY   STATUS    RESTARTS   AGE
pod/backend-6d9bc855fc-c7bl7     1/1     Running   0          32m
pod/frontend-75fd9dc795-f5lk6    1/1     Running   0          115m
pod/multitool-5958664c8b-t55sb   1/1     Running   0          111m
pod/postgres-db-0                1/1     Running   0          115m

NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/backend-cip       ClusterIP      10.233.25.213   <none>        9000/TCP       115m
service/frontend-lb       LoadBalancer   10.233.39.98    <pending>     80:31202/TCP   115m
service/postgres-db-cip   ClusterIP      10.233.28.249   <none>        5432/TCP       115m

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend     1/1     1            1           115m
deployment.apps/frontend    1/1     1            1           115m
deployment.apps/multitool   1/1     1            1           111m

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/backend-6d9bc855fc     1         1         1       115m
replicaset.apps/frontend-75fd9dc795    1         1         1       115m
replicaset.apps/multitool-5958664c8b   1         1         1       111m

NAME                           READY   AGE
statefulset.apps/postgres-db   1/1     115m
```

* Выполнение запросов с помощью `exec`
```BASH
$ kubectl exec multitool-5958664c8b-t55sb -- curl -s frontend-lb
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

$ kubectl exec frontend-75fd9dc795-f5lk6 -- curl -s backend-cip:9000
Defaulted container "frontend" out of: frontend, wait-backend (init)
{"detail":"Not Found"}

$ kubectl exec multitool-5958664c8b-t55sb -- psql postgresql://postgres:postgres@postgres-db-cip:5432 -c "\l"
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 news      | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(4 rows)
```

* Выполнение запросов с помощью `port-forward`

```BASH
$ nohup kubectl port-forward frontend-75fd9dc795-f5lk6 8081:80 >/dev/null 2>&1 &
[1] 69164
rpot@rp-nb-h02:~/projects/devops-netology/13-kubernetes-config-03-kubectl/src/manifests

$ curl -s localhost:8081
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

$ nohup kubectl port-forward postgres-db-0 5431:5432 >/dev/null 2>&1 &
[1] 69790

$ psql postgresql://postgres:postgres@localhost:5431 -c "\l"
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 news      | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(4 rows)
```

## Задание 2: ручное масштабирование

При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.

**Ответ:**

* Изменение количества копий с помощью команд `scale` и `patch`

```BASH
$ kubectl get po -o wide 
NAME                         READY   STATUS    RESTARTS   AGE    IP             NODE       NOMINATED NODE   READINESS GATES
backend-6d9bc855fc-c7bl7     1/1     Running   0          28m    10.233.94.68   worker02   <none>           <none>
frontend-75fd9dc795-f5lk6    1/1     Running   0          112m   10.233.94.66   worker02   <none>           <none>
multitool-5958664c8b-t55sb   1/1     Running   0          108m   10.233.69.3    worker01   <none>           <none>
postgres-db-0                1/1     Running   0          112m   10.233.94.67   worker02   <none>           <none>

$ kubectl scale --replicas=3 deployment backend 
deployment.apps/backend scaled

$ kubectl patch deployment frontend -p '{"spec":{"replicas":3}}' --type=merge
deployment.apps/frontend patched

$ kubectl get po -o wide 
NAME                         READY   STATUS    RESTARTS   AGE    IP             NODE       NOMINATED NODE   READINESS GATES
backend-6d9bc855fc-c7bl7     1/1     Running   0          30m    10.233.94.68   worker02   <none>           <none>
backend-6d9bc855fc-drbf8     1/1     Running   0          34s    10.233.69.11   worker01   <none>           <none>
backend-6d9bc855fc-g76mk     1/1     Running   0          34s    10.233.69.12   worker01   <none>           <none>
frontend-75fd9dc795-f5lk6    1/1     Running   0          113m   10.233.94.66   worker02   <none>           <none>
frontend-75fd9dc795-khs4g    1/1     Running   0          26s    10.233.69.14   worker01   <none>           <none>
frontend-75fd9dc795-zv25b    1/1     Running   0          26s    10.233.69.13   worker01   <none>           <none>
multitool-5958664c8b-t55sb   1/1     Running   0          109m   10.233.69.3    worker01   <none>           <none>
postgres-db-0                1/1     Running   0          113m   10.233.94.67   worker02   <none>           <none>

$ kubectl scale --replicas=1 deployment backend 
deployment.apps/backend scaled

$ kubectl patch deployment frontend -p '{"spec":{"replicas":1}}' --type=merge
deployment.apps/frontend patched

$ kubectl get po -o wide 
NAME                         READY   STATUS        RESTARTS   AGE    IP             NODE       NOMINATED NODE   READINESS GATES
backend-6d9bc855fc-c7bl7     1/1     Running       0          30m    10.233.94.68   worker02   <none>           <none>
frontend-75fd9dc795-f5lk6    1/1     Running       0          114m   10.233.94.66   worker02   <none>           <none>
multitool-5958664c8b-t55sb   1/1     Running       0          110m   10.233.69.3    worker01   <none>           <none>
postgres-db-0                1/1     Running       0          114m   10.233.94.67   worker02   <none>           <none>
```
