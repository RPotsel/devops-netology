# 13.5 поддержка нескольких окружений на примере Qbec - Роман Поцелуев
Приложение обычно существует в нескольких окружениях. Для удобства работы следует использовать соответствующие инструменты, например, Qbec.

## Задание 1: подготовить приложение для работы через qbec
Приложение следует упаковать в qbec. Окружения должно быть 2: stage и production. 

Требования:
* stage окружение должно поднимать каждый компонент приложения в одном экземпляре;
* production окружение — каждый компонент в трёх экземплярах;
* для production окружения нужно добавить endpoint на внешний адрес.

**Ответ:**

* [Упакованное приложение](./src/qbec/)

* Проверка конфигурации на корректность:

```BASH
  $ qbec validate stage
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 192ms
3 components evaluated in 45ms
✔ services backend-cip -n stage (source backend) is valid
✔ deployments frontend -n stage (source frontend) is valid
✔ services frontend-lb -n stage (source frontend) is valid
✔ deployments backend -n stage (source backend) is valid
✔ persistentvolumes pv-stage (source db) is valid
✔ services postgres-db-cip -n stage (source db) is valid
✔ statefulsets postgres-db -n stage (source db) is valid
---
stats:
  valid: 7

command took 650ms

  $ qbec validate prod
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 194ms
4 components evaluated in 40ms
✔ services backend-cip -n production (source backend) is valid
✔ endpoints external-ep -n production (source endpoint) is valid
✔ services external-ep -n production (source endpoint) is valid
✔ persistentvolumes pv-prod (source db) is valid
✔ deployments frontend -n production (source frontend) is valid
✔ services frontend-lb -n production (source frontend) is valid
✔ services postgres-db-cip -n production (source db) is valid
✔ statefulsets postgres-db -n production (source db) is valid
✔ deployments backend -n production (source backend) is valid
---
stats:
  valid: 9

command took 610ms
```

* Развертывание в `stage`

```BASH
  $ qbec apply stage
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 191ms
3 components evaluated in 82ms

will synchronize 7 object(s)

Do you want to continue [y/n]: y
3 components evaluated in 42ms
create deployments backend -n stage (source backend)
W1025 13:21:03.147441   25080 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
create deployments frontend -n stage (source frontend)
create statefulsets postgres-db -n stage (source db)
create services backend-cip -n stage (source backend)
create services postgres-db-cip -n stage (source db)
create services frontend-lb -n stage (source frontend)
server objects load took 1.453s
---
stats:
  created:
  - deployments backend -n stage (source backend)
  - deployments frontend -n stage (source frontend)
  - statefulsets postgres-db -n stage (source db)
  - services backend-cip -n stage (source backend)
  - services postgres-db-cip -n stage (source db)
  - services frontend-lb -n stage (source frontend)
  same: 1

waiting for readiness of 3 objects
  - deployments backend -n stage
  - deployments frontend -n stage
  - statefulsets postgres-db -n stage

  0s    : deployments frontend -n stage :: 0 of 1 updated replicas are available
  0s    : deployments backend -n stage :: 0 of 1 updated replicas are available
✓ 0s    : statefulsets postgres-db -n stage :: 1 new pods updated (2 remaining)
✓ 52s   : deployments backend -n stage :: successfully rolled out (1 remaining)
✓ 1m9s  : deployments frontend -n stage :: successfully rolled out (0 remaining)

✓ 1m9s: rollout complete
command took 1m13.25s

  $ kubectl get pods -n stage
NAME                        READY   STATUS    RESTARTS   AGE
backend-554f5fb88d-l9vhk    1/1     Running   0          112s
frontend-774d7ff56b-jmht5   1/1     Running   0          112s
postgres-db-0               1/1     Running   0          112s

  $ kubectl get svc -n stage
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
backend-cip       ClusterIP      10.233.31.127   <none>        9000/TCP       2m17s
frontend-lb       LoadBalancer   10.233.17.83    <pending>     80:31684/TCP   2m17s
postgres-db-cip   ClusterIP      10.233.20.75    <none>        5432/TCP       2m17s
```

* Развертывание в `prod`

```BASH
  $ qbec apply prod
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 193ms
4 components evaluated in 52ms

will synchronize 9 object(s)

Do you want to continue [y/n]: y
4 components evaluated in 33ms
create persistentvolumes pv-prod (source db)
create endpoints external-ep -n production (source endpoint)
W1025 13:24:10.400723   25414 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
create deployments backend -n production (source backend)
create deployments frontend -n production (source frontend)
create statefulsets postgres-db -n production (source db)
I1025 13:24:11.159499   25414 request.go:665] Waited for 1.036553028s due to client-side throttling, not priority and fairness, request: GET:https://178.154.241.63:6443/api/v1/persistentvolumes?labelSelector=qbec.io%2Fapplication%3Ddemo%2Cqbec.io%2Fenvironment%3Dprod%2C%21qbec.io%2Ftag&limit=1000
create services backend-cip -n production (source backend)
create services postgres-db-cip -n production (source db)
create services external-ep -n production (source endpoint)
create services frontend-lb -n production (source frontend)
server objects load took 1.642s
---
stats:
  created:
  - persistentvolumes pv-prod (source db)
  - endpoints external-ep -n production (source endpoint)
  - deployments backend -n production (source backend)
  - deployments frontend -n production (source frontend)
  - statefulsets postgres-db -n production (source db)
  - services backend-cip -n production (source backend)
  - services postgres-db-cip -n production (source db)
  - services external-ep -n production (source endpoint)
  - services frontend-lb -n production (source frontend)

waiting for readiness of 3 objects
  - deployments backend -n production
  - deployments frontend -n production
  - statefulsets postgres-db -n production

✓ 0s    : statefulsets postgres-db -n production :: 1 new pods updated (2 remaining)
  0s    : deployments backend -n production :: 0 of 3 updated replicas are available
  0s    : deployments frontend -n production :: 0 of 3 updated replicas are available
  9s    : deployments backend -n production :: 1 of 3 updated replicas are available
  9s    : deployments backend -n production :: 2 of 3 updated replicas are available
✓ 9s    : deployments backend -n production :: successfully rolled out (1 remaining)
  14s   : deployments frontend -n production :: 1 of 3 updated replicas are available
  14s   : deployments frontend -n production :: 2 of 3 updated replicas are available
✓ 14s   : deployments frontend -n production :: successfully rolled out (0 remaining)

✓ 14s: rollout complete
command took 19.6s

  $ kubectl get pods -n production
NAME                        READY   STATUS    RESTARTS   AGE
backend-554f5fb88d-4pjvb    1/1     Running   0          33s
backend-554f5fb88d-75tjs    1/1     Running   0          33s
backend-554f5fb88d-h6hhl    1/1     Running   0          33s
frontend-774d7ff56b-mr59f   1/1     Running   0          33s
frontend-774d7ff56b-qww49   1/1     Running   0          33s
frontend-774d7ff56b-rjtb8   1/1     Running   0          33s
postgres-db-0               1/1     Running   0          33s

  $ kubectl get svc -n production
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
backend-cip       ClusterIP      10.233.0.229    <none>        9000/TCP       51s
external-ep       ClusterIP      10.233.47.64    <none>        443/TCP        50s
frontend-lb       LoadBalancer   10.233.13.201   <pending>     80:30791/TCP   50s
postgres-db-cip   ClusterIP      10.233.24.51    <none>        5432/TCP       50s
```