# 08.01 Введение в Ansible - Роман Поцелуев

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.

__Ответ:__
```BASH
$ ansible --version
ansible [core 2.12.4]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/rpot/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.8/dist-packages/ansible
  ansible collection location = /home/rpot/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]
  jinja version = 2.10.1
  libyaml = True
```

2. Создайте свой собственный публичный репозиторий на github с произвольным именем.

__Ответ:_

3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

__Ответ:_

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

__Ответ:__

```BASH
$ ansible-playbook site.yml -i inventory/test.yml

PLAY [Print os facts] **********************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [localhost]

TASK [Print OS] ****************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP *********************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.

__Ответ:__

```BASH
$ ansible-inventory -i inventory/test.yml --graph
@all:
  |--@inside:
  |  |--localhost
  |--@ungrouped:
$ ansible-inventory -i inventory/test.yml --host localhost
{
    "ansible_connection": "local",
    "some_fact": 12
}
```

После замены:

```BASH
$ ansible-inventory -i inventory/test.yml --host localhost
{
    "ansible_connection": "local",
    "some_fact": "all default fact"
}
```

3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

__Ответ:__

```BASH
$ docker ps -a
CONTAINER ID   IMAGE          COMMAND       CREATED              STATUS              PORTS     NAMES
eaced2304272   ubuntu:20.04   "bash"        About a minute ago   Up About a minute             ubuntu
f927003d1a16   centos:7       "/bin/bash"   About a minute ago   Up About a minute             centos7
```

4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

__Ответ:__

```BASH
$ ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] **********************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ****************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP *********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.

__Ответ:__

```BASH
$ ansible-inventory -i inventory/prod.yml --list
{
    "_meta": {
        "hostvars": {
            "centos7": {
                "ansible_connection": "docker",
                "some_fact": "el default fact"
            },
            "ubuntu": {
                "ansible_connection": "docker",
                "some_fact": "deb default fact"
            }
        }
    },
    "all": {
        "children": [
            "deb",
            "el",
            "ungrouped"
        ]
    },
    "deb": {
        "hosts": [
            "ubuntu"
        ]
    },
    "el": {
        "hosts": [
            "centos7"
        ]
    }
}
```

6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

__Ответ:__

```BASH
$ ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] **********************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ****************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

__Ответ:__

```BASH
$ cat group_vars/{deb,el}/*
---
  some_fact: "deb default fact"---
  some_fact: "el default fact"
$ ansible-vault encrypt group_vars/{deb,el}/*
New Vault password: 
Confirm New Vault password: 
Encryption successful
$ cat group_vars/{deb,el}/*
$ANSIBLE_VAULT;1.1;AES256
65313263396164323235626366663561303731376131373065303337333735376634313438316136
6131616633313866393561663531393739613862633463380a656631643131623631303636386365
31353934663661323531383134643633653737633362383630363730376262396139373538623736
3539653539303766310a383032323663313037656431333435303331363534656633363036313361
34636137623263656465646237373135663037653064616639333232363630393962613262323562
6534626634306431323265366165636333653338356537653664
$ANSIBLE_VAULT;1.1;AES256
66653961343466306138313065343234626162646234306162373337623234343931313431346338
6138323731353430623265613633613436366265633639310a343334376564353936363063616237
63653633373361336238393961333963343735626466386330326563303438346434323437653037
3439306665316464310a326333393965363233383631663661383264636531326661343138643862
35383561303162336430633036313966353630393733333037316366653539666539666534336330
6231393132353031383162313863653130326162633763303561
```

8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

__Ответ:__

```BASH
 $ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] **********************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ****************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

__Ответ:__

Список плагинов подключения можно вывести командой `ansible-doc -t connection -l`, для работы на `control node` нужно использовать `local`.

10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

__Ответ:__

```BASH
$ cat inventory/prod.yml 
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```

11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

__Ответ:__

```BASH
$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] **********************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ****************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.

__Ответ:__

```BASH
$ ansible-vault decrypt group_vars/{deb,el}/*
Vault password: 
Decryption successful
```

2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.

__Ответ:__

```BASH
$ ansible-vault encrypt_string PaSSw0rd
New Vault password: 
Confirm New Vault password: 
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          36316631346265636565633865666561323261383035303733303561393434636531353833386365
          3537623061666362653166353961313434363534396664370a626432386564386362663263316564
          63653164326362626436616630633437353331396261623934333861343934383133396136366138
          3630316434323733360a353165616636636430366666633734356637326537653837346633326361
          6538
Encryption successful

$ cat group_vars/all/examp.yml 
---
  some_fact: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          36316631346265636565633865666561323261383035303733303561393434636531353833386365
          3537623061666362653166353961313434363534396664370a626432386564386362663263316564
          63653164326362626436616630633437353331396261623934333861343934383133396136366138
          3630316434323733360a353165616636636430366666633734356637326537653837346633326361
          6538
```

3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.

__Ответ:__

```BASH
$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] **********************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ****************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).

__Ответ:__

```BASH
$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] **********************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [fedora]
ok: [centos7]

TASK [Print OS] ****************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [fedora] => {
    "msg": "Fedora"
}

TASK [Print fact] **************************************************************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora] => {
    "msg": "PaSSw0rd"
}

TASK [Print hellow] ************************************************************************************************************************
skipping: [centos7]
skipping: [ubuntu]
skipping: [localhost]
ok: [fedora] => {
    "msg": "Hello world!"
}

PLAY RECAP *********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
fedora                     : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.

__Ответ:__

```BASH
$ cat start_lab.sh 
#!/usr/bin/env bash
docker-compose up -d
ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
docker-compose down
```

6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

__Ответ:__

https://github.com/RPotsel/netology-0801
