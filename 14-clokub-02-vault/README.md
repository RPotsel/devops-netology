# 14.2 Синхронизация секретов с внешними сервисами. Vault.

## Задача 1: Работа с модулем Vault

Запустить модуль Vault конфигураций через утилиту kubectl в установленном minikube

```
kubectl apply -f 14.2/vault-pod.yml
```

**Ответ:**
```
  $ kubectl apply -f vault-pod.yml 
pod/14.2-netology-vault created

  $ kubectl get po
NAME                  READY   STATUS    RESTARTS   AGE
14.2-netology-vault   1/1     Running   0          13s
```

Получить значение внутреннего IP пода

```
kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
```
Примечание: jq - утилита для работы с JSON в командной строке

**Ответ:**
```
  $ kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
[{"ip":"10.1.47.157"}]
```

Запустить второй модуль для использования в качестве клиента

```
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Установить дополнительные пакеты

```
dnf -y install pip
pip install hvac
```

**Ответ:**
```
  $ kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
If you don't see a command prompt, try pressing enter.
sh-5.2# dnf -y install pip
Fedora 36 - x86_64                                                                                       4.8 MB/s |  81 MB     00:16    
Fedora 36 openh264 (From Cisco) - x86_64                                                                 2.0 kB/s | 2.5 kB     00:01    
Fedora Modular 36 - x86_64                                                                               1.5 MB/s | 2.4 MB     00:01    
Fedora 36 - x86_64 - Updates                                                                             3.8 MB/s |  30 MB     00:07    
Fedora Modular 36 - x86_64 - Updates                                                                     328 kB/s | 2.8 MB     00:08    
Last metadata expiration check: 0:00:01 ago on Fri Nov  4 17:17:47 2022.
Dependencies resolved.
=========================================================================================================================================
 Package                                Architecture               Version                             Repository                   Size
=========================================================================================================================================
Installing:
 python3-pip                            noarch                     21.3.1-3.fc36                       updates                     1.8 M
Installing weak dependencies:
 libxcrypt-compat                       x86_64                     4.4.28-1.fc36                       fedora                       90 k
 python3-setuptools                     noarch                     59.6.0-2.fc36                       fedora                      936 k

Transaction Summary
=========================================================================================================================================
Install  3 Packages

Total download size: 2.8 M
Installed size: 14 M
Downloading Packages:
(1/3): libxcrypt-compat-4.4.28-1.fc36.x86_64.rpm                                                         218 kB/s |  90 kB     00:00    
(2/3): python3-setuptools-59.6.0-2.fc36.noarch.rpm                                                       937 kB/s | 936 kB     00:00    
(3/3): python3-pip-21.3.1-3.fc36.noarch.rpm                                                              1.4 MB/s | 1.8 MB     00:01    
-----------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                    728 kB/s | 2.8 MB     00:03     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                 1/1 
  Installing       : python3-setuptools-59.6.0-2.fc36.noarch                                                                         1/3 
  Installing       : libxcrypt-compat-4.4.28-1.fc36.x86_64                                                                           2/3 
  Installing       : python3-pip-21.3.1-3.fc36.noarch                                                                                3/3 
  Running scriptlet: python3-pip-21.3.1-3.fc36.noarch                                                                                3/3 
  Verifying        : libxcrypt-compat-4.4.28-1.fc36.x86_64                                                                           1/3 
  Verifying        : python3-setuptools-59.6.0-2.fc36.noarch                                                                         2/3 
  Verifying        : python3-pip-21.3.1-3.fc36.noarch                                                                                3/3 

Installed:
  libxcrypt-compat-4.4.28-1.fc36.x86_64         python3-pip-21.3.1-3.fc36.noarch         python3-setuptools-59.6.0-2.fc36.noarch        

Complete!
sh-5.2# pip install hvac
Collecting hvac
  Downloading hvac-1.0.2-py3-none-any.whl (143 kB)
     |████████████████████████████████| 143 kB 4.4 MB/s            
Collecting requests<3.0.0,>=2.27.1
  Downloading requests-2.28.1-py3-none-any.whl (62 kB)
     |████████████████████████████████| 62 kB 1.3 MB/s             
Collecting pyhcl<0.5.0,>=0.4.4
  Downloading pyhcl-0.4.4.tar.gz (61 kB)
     |████████████████████████████████| 61 kB 4.9 MB/s             
  Installing build dependencies ... done
  Getting requirements to build wheel ... done
  Preparing metadata (pyproject.toml) ... done
Collecting certifi>=2017.4.17
  Downloading certifi-2022.9.24-py3-none-any.whl (161 kB)
     |████████████████████████████████| 161 kB 1.0 MB/s            
Collecting urllib3<1.27,>=1.21.1
  Downloading urllib3-1.26.12-py2.py3-none-any.whl (140 kB)
     |████████████████████████████████| 140 kB 273 kB/s            
Collecting charset-normalizer<3,>=2
  Downloading charset_normalizer-2.1.1-py3-none-any.whl (39 kB)
Collecting idna<4,>=2.5
  Downloading idna-3.4-py3-none-any.whl (61 kB)
     |████████████████████████████████| 61 kB 161 kB/s            
Building wheels for collected packages: pyhcl
  Building wheel for pyhcl (pyproject.toml) ... done
  Created wheel for pyhcl: filename=pyhcl-0.4.4-py3-none-any.whl size=50148 sha256=c12c33a36262dcd1713a522b3ed5de2ca9b88fbbb85ae8973d15a13c7652c344
  Stored in directory: /root/.cache/pip/wheels/6c/ad/33/e11e917cf04cb1533cab6e7aaa8cee93c950aa82c32398b83e
Successfully built pyhcl
Installing collected packages: urllib3, idna, charset-normalizer, certifi, requests, pyhcl, hvac
Successfully installed certifi-2022.9.24 charset-normalizer-2.1.1 hvac-1.0.2 idna-3.4 pyhcl-0.4.4 requests-2.28.1 urllib3-1.26.12
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
```

Запустить интепретатор Python и выполнить следующий код, предварительно поменяв IP и токен

```
import hvac
client = hvac.Client(
    url='http://10.10.133.71:8200',
    token='aiphohTaa0eeHei'
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```

**Ответ:**
```
sh-5.2# python3
Python 3.10.7 (main, Sep  7 2022, 00:00:00) [GCC 12.2.1 20220819 (Red Hat 12.2.1-1)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import hvac
>>> 
>>> client = hvac.Client(
...     url='http://10.1.47.157:8200',
...     token='aiphohTaa0eeHei'
... )
>>> client.is_authenticated()
True
>>> 
>>> # Пишем секрет
>>> client.secrets.kv.v2.create_or_update_secret(
...     path='hvac',
...     secret=dict(netology='Big secret!!!'),
... )
{'request_id': 'dd24c0e3-2dda-146b-6e44-ed25b0305aa1', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'created_time': '2022-11-04T17:21:58.542163763Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>> 
>>> # Читаем секрет
>>> client.secrets.kv.v2.read_secret_version(
...     path='hvac',
... )
{'request_id': '940ecd22-6b80-bffa-f1dd-6ba0b2c4ab20', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'netology': 'Big secret!!!'}, 'metadata': {'created_time': '2022-11-04T17:21:58.542163763Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 1}}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>> 
```

## Задача 2 (*): Работа с секретами внутри модуля

* На основе образа fedora создать модуль;
* Создать секрет, в котором будет указан токен;
* Подключить секрет к модулю;
* Запустить модуль и проверить доступность сервиса Vault.

**Ответ:**

Для работы с секретами внутри модуля созданы следующие объекты:

* [Манифест](./src/manifests/20-vault.yml) пода для Vault c [монтированием](./src/manifests/10-pvc.yml) тома для хранилища и описанием сервиса для обращения из внешнего окружения
* [Dockerfile](./src/Dockerfile), [скрипт для запроса секрета](./src/get_secret_v2.py) и [манифест модуля](./src/manifests/30-app.yml)

Проверка работы:

* Разворачивание сервисов

```BASH
  $ kubectl apply -f manifests/
persistentvolumeclaim/pvc-vault created
statefulset.apps/vault created
service/vault created
pod/14-2-secret created

  $ kubectl get all
NAME              READY   STATUS    RESTARTS   AGE
pod/14-2-secret   1/1     Running   0          2m7s
pod/vault-0       1/1     Running   0          2m7s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/kubernetes   ClusterIP   10.152.183.1    <none>        443/TCP    10d
service/vault        ClusterIP   10.152.183.91   <none>        8200/TCP   2m7s

NAME                     READY   AGE
statefulset.apps/vault   1/1     2m7s
```

* Подключение к vault поду, инициализация и распечатывание

```BASH
  $ kubectl exec -it pod/vault-0 -- sh

/ # vault operator init -key-shares=1 -key-threshold=1
Unseal Key 1: O+Y956+OljrE78C679LPrc/0qHFtBXrjF1HIwsj4Vvw=

Initial Root Token: hvs.Ak5ngBQmGvTudPcuDogUgcWM

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated root key. Without at least 1 keys to
reconstruct the root key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.

/ # vault operator unseal O+Y956+OljrE78C679LPrc/0qHFtBXrjF1HIwsj4Vvw=
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.12.1
Build Date      2022-10-27T12:32:05Z
Storage Type    file
Cluster Name    vault-cluster-8be87a78
Cluster ID      e8f41e83-1a45-759e-aa8c-2941d4095884
HA Enabled      false
```

* Создание токена пользователя и политики доступа к данным из под Initial Root Token

```BASH
/ # vault login hvs.Ak5ngBQmGvTudPcuDogUgcWM
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.Ak5ngBQmGvTudPcuDogUgcWM
token_accessor       3bujxv7hmSWFQ7k6uqtki9io
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
/ # vault secrets enable -path=secret/ kv
Success! Enabled the kv secrets engine at: secret/
/ # vault kv put secret/test/hello foo=world excited=yes
Success! Data written to: secret/test/hello
/ # vault kv get secret/test/hello
===== Data =====
Key        Value
---        -----
excited    yes
foo        world
/ # vault token create -policy=my-policy
WARNING! The following warnings were returned from Vault:

  * Policy "my-policy" does not exist

Key                  Value
---                  -----
token                hvs.CAESIL8-nb7GC2Vz5ZWGm3IsmuOleGdJ9ycSEkWvZij18d1QGh4KHGh2cy5ENTR3WWwxMTJYS1ZJQkI1RUdPMjJqVHQ
token_accessor       vxZUVVwW18P5sRhFQcGi8NCQ
token_duration       768h
token_renewable      true
token_policies       ["default" "my-policy"]
identity_policies    []
policies             ["default" "my-policy"]
/ # vault policy write my-policy - << EOF
> path "secret/test/*" {
>   capabilities = ["read"]
> }
> EOF
Success! Uploaded policy: my-policy
/ # vault login
Token (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.CAESIL8-nb7GC2Vz5ZWGm3IsmuOleGdJ9ycSEkWvZij18d1QGh4KHGh2cy5ENTR3WWwxMTJYS1ZJQkI1RUdPMjJqVHQ
token_accessor       vxZUVVwW18P5sRhFQcGi8NCQ
token_duration       767h59m
token_renewable      true
token_policies       ["default" "my-policy"]
identity_policies    []
policies             ["default" "my-policy"]
/ # vault kv get secret/test/hello
===== Data =====
Key        Value
---        -----
excited    yes
foo        world
/ # vault secrets enable -version=2 kv
Success! Enabled the kv secrets engine at: kv/
/ # exit
```

* Подключение к модулю, запрос секрета через `python` скрипт и `curl`

```
  $ kubectl exec -it pod/14-2-secret -- bash

[root@14-2-secret app]# python3 get_secret_v2.py hvs.CAESIL8-nb7GC2Vz5ZWGm3IsmuOleGdJ9ycSEkWvZij18d1QGh4KHGh2cy5ENTR3WWwxMTJYS1ZJQkI1RUdPMjJqVHQ
{'excited': 'yes', 'foo': 'world'}

[root@14-2-secret app]# curl --header "X-Vault-Token: hvs.CAESIL8-nb7GC2Vz5ZWGm3IsmuOleGdJ9ycSEkWvZij18d1QGh4KHGh2cy5ENTR3WWwxMTJYS1ZJQkI1RUdPMjJqVHQ" http://vault:8200/v1/secret/test/hello
{"request_id":"8d8a001e-e9f8-67a7-69de-d5976b9a04a4","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"excited":"yes","foo":"world"},"wrap_info":null,"warnings":null,"auth":null}
```
