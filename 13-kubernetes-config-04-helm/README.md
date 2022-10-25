# 13.4 инструменты для упрощения написания конфигурационных файлов. Helm и Jsonnet - Роман Поцелуев
В работе часто приходится применять системы автоматической генерации конфигураций. Для изучения нюансов использования разных инструментов нужно попробовать упаковать приложение каждым из них.

## Задание 1: подготовить helm чарт для приложения
Необходимо упаковать приложение в чарт для деплоя в разные окружения. Требования:
* каждый компонент приложения деплоится отдельным deployment’ом/statefulset’ом;
* в переменных чарта измените образ приложения для изменения версии.

**Ответ**

[Helm чарт](./src/helm/)

## Задание 2: запустить 2 версии в разных неймспейсах
Подготовив чарт, необходимо его проверить. Попробуйте запустить несколько копий приложения:
* одну версию в namespace=app1;
* вторую версию в том же неймспейсе;
* третью версию в namespace=app2.

**Ответ:**

```BASH
  $ helm install hw134 helm -n app1 --create-namespace
NAME: hw134
LAST DEPLOYED: Mon Oct 17 13:13:42 2022
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None

  $ helm install hw134v2 helm -n app1 --create-namespace
NAME: hw134v2
LAST DEPLOYED: Mon Oct 17 13:13:53 2022
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None

  $ helm install hw134 helm -n app2 --create-namespace
NAME: hw134
LAST DEPLOYED: Mon Oct 17 13:14:01 2022
NAMESPACE: app2
STATUS: deployed
REVISION: 1
TEST SUITE: None

  $ kubectl get pods -n app1
NAME                                READY   STATUS    RESTARTS   AGE
hw134-backend-9f87f678d-ppgln       1/1     Running   0          6m23s
hw134-frontend-5c4f545d44-d6bp2     1/1     Running   0          6m23s
hw134-postgres-db-0                 1/1     Running   0          6m23s
hw134v2-backend-7698d9fd8d-kl6rf    1/1     Running   0          6m12s
hw134v2-frontend-76f4676b8d-xknwr   1/1     Running   0          6m12s
hw134v2-postgres-db-0               1/1     Running   0          6m12s
multitool-5958664c8b-f9qs8          1/1     Running   0          2m22s

  $ kubectl get pods -n app2
NAME                              READY   STATUS    RESTARTS   AGE
hw134-backend-9f87f678d-n9gjr     1/1     Running   0          6m6s
hw134-frontend-5c4f545d44-6vfl4   1/1     Running   0          6m6s
hw134-postgres-db-0               1/1     Running   0          6m6s

  $ kubectl get svc -A
NAMESPACE     NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
app1          hw134-backend-svc         ClusterIP      10.233.2.227    <none>        9000/TCP                 21m
app1          hw134-frontend-svc        LoadBalancer   10.233.8.83     <pending>     80:31252/TCP             21m
app1          hw134-postgres-db-svc     ClusterIP      10.233.38.196   <none>        5432/TCP                 21m
app1          hw134v2-backend-svc       ClusterIP      10.233.61.210   <none>        9000/TCP                 20m
app1          hw134v2-frontend-svc      LoadBalancer   10.233.11.152   <pending>     80:30960/TCP             20m
app1          hw134v2-postgres-db-svc   ClusterIP      10.233.23.186   <none>        5432/TCP                 20m
app2          hw134-backend-svc         ClusterIP      10.233.58.31    <none>        9000/TCP                 20m
app2          hw134-frontend-svc        LoadBalancer   10.233.41.58    <pending>     80:32254/TCP             20m
app2          hw134-postgres-db-svc     ClusterIP      10.233.61.193   <none>        5432/TCP                 20m
default       kubernetes                ClusterIP      10.233.0.1      <none>        443/TCP                  121m
kube-system   coredns                   ClusterIP      10.233.0.3      <none>        53/UDP,53/TCP,9153/TCP   117m

 $ kubectl exec multitool-5958664c8b-f9qs8 -n app1 -- curl -s hw134-frontend-svc
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

## Задание 3 (*): повторить упаковку на jsonnet
Для изучения другого инструмента стоит попробовать повторить опыт упаковки из задания 1, только теперь с помощью инструмента jsonnet.

**Ответ:**

[jsonnet скрипт](./src/jsonnet/apps.jsonnet)

```JSON
  $ jsonnet apps.jsonnet 
[
   {
      "apiVersion": "v1",
      "kind": "PersistentVolume",
      "metadata": {
         "name": "pv",
         "namespace": "prod"
      },
      "spec": {
         "accessModes": [
            "ReadWriteOnce"
         ],
         "capacity": {
            "storage": "256Mi"
         },
         "hostPath": {
            "path": "/data/pv"
         }
      }
   },
   {
      "apiVersion": "apps/v1",
      "kind": "StatefulSet",
      "metadata": {
         "labels": {
            "app": "postgres-db"
         },
         "name": "postgres-db",
         "namespace": "prod"
      },
      "spec": {
         "replicas": 1,
         "selector": {
            "matchLabels": {
               "app": "postgres-db"
            }
         },
         "serviceName": "postgres-db-service",
         "template": {
            "metadata": {
               "labels": {
                  "app": "postgres-db"
               }
            },
            "spec": {
               "containers": [
                  {
                     "env": [
                        {
                           "name": "POSTGRES_USER",
                           "value": "postgres"
                        },
                        {
                           "name": "POSTGRES_PASSWORD",
                           "value": "postgres"
                        },
                        {
                           "name": "POSTGRES_DB",
                           "value": "news"
                        }
                     ],
                     "image": "postgres:13-alpine",
                     "imagePullPolicy": "IfNotPresent",
                     "name": "postgres-db",
                     "ports": [
                        {
                           "containerPort": 5432,
                           "name": "postgres",
                           "protocol": "TCP"
                        }
                     ],
                     "resources": {
                        "limits": {
                           "cpu": "500m",
                           "memory": "512Mi"
                        },
                        "requests": {
                           "cpu": "250m",
                           "memory": "265Mi"
                        }
                     },
                     "volumeMounts": [
                        {
                           "mountPath": "/var/lib/postgres/data",
                           "name": "postgres-db-disk"
                        }
                     ]
                  }
               ]
            }
         },
         "volumeClaimTemplates": [
            {
               "metadata": {
                  "name": "postgres-db-disk"
               },
               "spec": {
                  "accessModes": [
                     "ReadWriteOnce"
                  ],
                  "resources": {
                     "requests": {
                        "storage": "256Mi"
                     }
                  },
                  "volumeName": "pv-production"
               }
            }
         ]
      }
   },
   {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
         "labels": {
            "app": "postgres-db"
         },
         "name": "postgres-db-cip",
         "namespace": "prod"
      },
      "spec": {
         "ports": [
            {
               "name": "postgres-db",
               "port": 5432,
               "protocol": "TCP",
               "targetPort": 5432
            }
         ],
         "selector": {
            "app": "postgres-db"
         },
         "type": "ClusterIP"
      }
   },
   {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": {
         "labels": {
            "app": "backend"
         },
         "name": "backend",
         "namespace": "prod"
      },
      "spec": {
         "replicas": 1,
         "selector": {
            "matchLabels": {
               "app": "backend"
            }
         },
         "template": {
            "metadata": {
               "labels": {
                  "app": "backend"
               }
            },
            "spec": {
               "containers": [
                  {
                     "env": [
                        {
                           "name": "DATABASE_URL",
                           "value": "postgres://postgres:postgres@postgres-db-cip:5432/news"
                        }
                     ],
                     "image": "rpot/13-01-backend:0.1",
                     "imagePullPolicy": "IfNotPresent",
                     "name": "backend"
                  }
               ],
               "initContainers": [
                  {
                     "command": [
                        "sh",
                        "-ec",
                        "until (pg_isready -h postgres-db-cip -p 5432 -U postgres); do\n  echo 'Wait postgres service'\n  sleep 1\ndone\n"
                     ],
                     "image": "postgres:13-alpine",
                     "imagePullPolicy": "IfNotPresent",
                     "name": "wait-postgres"
                  }
               ]
            }
         }
      }
   },
   {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
         "labels": {
            "app": "backend"
         },
         "name": "backend-cip",
         "namespace": "prod"
      },
      "spec": {
         "ports": [
            {
               "name": "backend",
               "port": 9000,
               "protocol": "TCP",
               "targetPort": 9000
            }
         ],
         "selector": {
            "app": "backend"
         },
         "type": "ClusterIP"
      }
   },
   {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": {
         "labels": {
            "app": "frontend"
         },
         "name": "frontend",
         "namespace": "prod"
      },
      "spec": {
         "replicas": 1,
         "selector": {
            "matchLabels": {
               "app": "frontend"
            }
         },
         "template": {
            "metadata": {
               "labels": {
                  "app": "frontend"
               }
            },
            "spec": {
               "containers": [
                  {
                     "env": [
                        {
                           "name": "BASE_URL",
                           "value": "http://backend-cip:9000"
                        }
                     ],
                     "image": "rpot/13-01-frontend:0.1",
                     "imagePullPolicy": "IfNotPresent",
                     "name": "frontend"
                  }
               ],
               "initContainers": [
                  {
                     "args": [
                        "while [ $(curl -ksw %{http_code} backend-cip:9000/api/news/ -o /dev/null) -ne 200 ]; do sleep 5; echo \"Waiting for backend service.\"; done"
                     ],
                     "command": [
                        "/bin/sh",
                        "-ec"
                     ],
                     "image": "praqma/network-multitool:alpine-extra",
                     "imagePullPolicy": "IfNotPresent",
                     "name": "wait-backend"
                  }
               ]
            }
         }
      }
   },
   {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
         "labels": {
            "app": "frontend"
         },
         "name": "frontend-lb",
         "namespace": "prod"
      },
      "spec": {
         "ports": [
            {
               "name": "frontend",
               "port": 80,
               "protocol": "TCP",
               "targetPort": 80
            }
         ],
         "selector": {
            "app": "frontend"
         },
         "type": "LoadBalancer"
      }
   }
]
```
