# 12.2 Команды для работы с Kubernetes - Роман Поцелуев
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2).

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods

**Ответ:**

```BASH
ubuntu@minikube:~$ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 -r 2
deployment.apps/hello-node created
ubuntu@minikube:~$ kubectl get deployment
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           22s
ubuntu@minikube:~$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6d5f754cc9-d2flq   1/1     Running   0          57s
hello-node-6d5f754cc9-p4wcs   1/1     Running   0          57s
ubuntu@minikube:~$ 
```

## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе.
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования:
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

**Ответ:**

```BASH
# Создание папки для ключей
ubuntu@minikube:~$ mkdir roman && cd roman
# Создание закрытый ключ:
ubuntu@minikube:~/roman$ openssl genrsa -out roman.key 2048
Generating RSA private key, 2048 bit long modulus (2 primes)
.....................................+++++
..+++++
e is 65537 (0x010001)
# Создание запрос на подпись сертификата (certificate signing request, CSR)
ubuntu@minikube:~/roman$ openssl req -new -key roman.key -out roman.csr -subj "/CN=roman"
# Подписание CSR в Kubernetes CA
ubuntu@minikube:~/roman$ openssl x509 -req -in roman.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out roman.crt -days 500
Signature ok
subject=CN = roman
Getting CA Private Key
# Создание пользователя внутри Kubernetes:
ubuntu@minikube:~/roman$ kubectl config set-credentials roman --client-certificate=~/roman/roman.crt --client-key=~/roman/roman.key
User "roman" set.
# Создание пространства имен и приложния для проверки
ubuntu@minikube:~/roman$ kubectl create ns development
namespace/development created
ubuntu@minikube:~/roman$ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --namespace=development
deployment.apps/hello-node created
# Создание роли
ubuntu@minikube:~/roman$ cat ~/manifests/20-role.yml 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: development-role
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
ubuntu@minikube:~/roman$ kubectl apply -f ~/manifests/20-role.yml 
role.rbac.authorization.k8s.io/development-role created
# Привязка роли
ubuntu@minikube:~/roman$ cat ~/manifests/21-rolebinding.yml 
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: development-rolebinding
  namespace: development
subjects:
- kind: User
  name: roman
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: development-role
  apiGroup: rbac.authorization.k8s.io
ubuntu@minikube:~/roman$ kubectl apply -f ~/manifests/21-rolebinding.yml 
rolebinding.rbac.authorization.k8s.io/development-rolebinding created
# Создение контекста для пользователя и переключение на него
ubuntu@minikube:~/roman$ kubectl config set-context development --namespace=development --cluster=minikube --user=roman
Context "development" created.
ubuntu@minikube:~/roman$ kubectl config use-context development
Switched to context "development".
# Проверка доступа
ubuntu@minikube:~/roman$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6d5f754cc9-k9zpq   1/1     Running   0          26m
ubuntu@minikube:~/roman$ kubectl get pods -A
Error from server (Forbidden): pods is forbidden: User "roman" cannot list resource "pods" in API group "" at the cluster scope
ubuntu@minikube:~/roman$ kubectl logs pods/hello-node-6d5f754cc9-k9zpq
ubuntu@minikube:~/roman$ kubectl delete pod hello-node-6d5f754cc9-k9zpq
Error from server (Forbidden): pods "hello-node-6d5f754cc9-k9zpq" is forbidden: User "roman" cannot delete resource "pods" in API group "" in the namespace "development"
```

## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

**Ответ:**

```BASH
ubuntu@minikube:~$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6d5f754cc9-d2flq   1/1     Running   0          3m36s
hello-node-6d5f754cc9-p4wcs   1/1     Running   0          3m36s
ubuntu@minikube:~$ kubectl scale deployment hello-node --replicas=5
deployment.apps/hello-node scaled
ubuntu@minikube:~$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6d5f754cc9-5lbpd   1/1     Running   0          3s
hello-node-6d5f754cc9-d2flq   1/1     Running   0          3m47s
hello-node-6d5f754cc9-gj2wn   1/1     Running   0          3s
hello-node-6d5f754cc9-p4wcs   1/1     Running   0          3m47s
hello-node-6d5f754cc9-xbmhp   1/1     Running   0          3s
```
