# Домашнее задание к занятию "14.5 SecurityContext, NetworkPolicies"

## Задача 1: Рассмотрите пример 14.5/example-security-context.yml

Создайте модуль

```
kubectl apply -f 14.5/example-security-context.yml
```

Проверьте установленные настройки внутри контейнера

```
kubectl logs security-context-demo
uid=1000 gid=3000 groups=3000
```

**Ответ**

```
  $ kubectl apply -f example-security-context.yml 
pod/security-context-demo created

  $ kubectl logs security-context-demo
uid=1000 gid=3000 groups=3000
```

## Задача 2 (*): Рассмотрите пример 14.5/example-network-policy.yml

Создайте два модуля. Для первого модуля разрешите доступ к внешнему миру и ко второму контейнеру. Для второго модуля разрешите связь только с первым контейнером. Проверьте корректность настроек.

**Ответ**

Подготовлены манифесты:

* [`NetworkPolicy` по умолчанию, запрещает весь трафик, кроме DNS внутри кластера](./src/02/00-np-default.yml)
* [`NetworkPolicy` с правилами для первого модуля](./src/02/01-np-mod1.yml)
* [`NetworkPolicy` с правилами для второго модуля](./src/02/02-np-mod2.yml)
* [Описание первого модуля](./src/02/10-app-mod1.yml)
* [Описание второго модуля](./src/02/11-app-mod2.yml)

```
  $ kubectl apply -f .
networkpolicy.networking.k8s.io/default created
networkpolicy.networking.k8s.io/module01 created
networkpolicy.networking.k8s.io/module02 created
pod/module01 created
service/module01 created
pod/module02 created
service/module02 created

  $ kubectl exec module01 -- nc -zv module02 1280
Connection to module02 1280 port [tcp/*] succeeded!

  $ kubectl exec module01 -- nc -zv ya.ru 443
Connection to ya.ru 443 port [tcp/https] succeeded!

  $ kubectl exec module02 -- nc -zv module01 1180
Connection to module01 1180 port [tcp/*] succeeded!
```
