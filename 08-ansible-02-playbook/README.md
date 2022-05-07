# 08.02 Работа с Playbook - Роман Поцелуев

## Основная часть

1. Приготовьте свой собственный inventory файл `prod.yml`.

__Ответ:__

Указан сервер на котором будут проводиться работы и способ подключения.

```YAML
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: 192.168.1.54
      ansible_connection: ssh
```

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).

__Ответ:__

```YAML
- name: Install Vector
  hosts: clickhouse
  tasks:
    - name: Get Vector distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/0.21.1/vector-0.21.1-1.x86_64.rpm"
        dest: "./vector-0.21.1-1.x86_64.rpm"
        mode: 0444
        validate_certs: false
    - name: Install Vector packages
      become: true
      ansible.builtin.yum:
        name:
          - vector-0.21.1-1.x86_64.rpm
      notify: Start vector service
      tags: packages
```

3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.

__Ответ:__

Выполнено

4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.

__Ответ:__

Выполнено

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

__Ответ:__

```BASH
$ ansible-lint site.yml 
WARNING: PATH altered to include /usr/bin
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
WARNING  Listing 3 violation(s) that are fatal
risky-file-permissions: File permissions unset or incorrect.
site.yml:17 Task/Handler: Get clickhouse distrib

risky-file-permissions: File permissions unset or incorrect.
site.yml:23 Task/Handler: Get clickhouse distrib

risky-file-permissions: File permissions unset or incorrect.
site.yml:43 Task/Handler: Get Vector distrib

You can skip specific rules or tags by adding them to your configuration file:
# .config/ansible-lint.yml
warn_list:  # or 'skip_list' to silence them completely
  - experimental  # all rules tagged as experimental

Finished with 0 failure(s), 3 warning(s) on 1 files.
```

Проверка показала, что в заданиях на получение дистрибутивов не указан параметр для установки прав на скачиваемые архивы. После установки параметра `mode` предупреждение ушло.

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

__Ответ:__

```BASH
$ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] ******************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] **************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] **************************************************************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] *********************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system"]}

PLAY RECAP *********************************************************************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0
```

При запуске с параметром `--check` файл дистрибутива из задания Get clickhouse distrib не сохраняется на диск, поэтому возникает ошибка при выполнении задания Install clickhouse packages.

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

__Ответ:__

```BASH
$ ansible-playbook -i inventory/prod.yml site.yml --diff --ask-become-pass
BECOME password: 

PLAY [Install Clickhouse] ******************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] **************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1000, "group": "rpot", "item": "clickhouse-common-static", "mode": "0444", "msg": "Request failed", "owner": "rpot", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] **************************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] *********************************************************************************************************
changed: [clickhouse-01]

RUNNING HANDLER [Start clickhouse service] *************************************************************************************************
changed: [clickhouse-01]

TASK [Create database] *********************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "cmd": ["clickhouse-client", "-q", "create database logs;"], "delta": "0:00:00.334925", "end": "2022-05-07 13:02:07.346027", "failed_when_result": true, "msg": "non-zero return code", "rc": 210, "start": "2022-05-07 13:02:07.011102", "stderr": "Code: 210. DB::NetException: Connection refused (localhost:9000). (NETWORK_ERROR)", "stderr_lines": ["Code: 210. DB::NetException: Connection refused (localhost:9000). (NETWORK_ERROR)"], "stdout": "", "stdout_lines": []}

PLAY RECAP *********************************************************************************************************************************
clickhouse-01              : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0
```

Ошибка при создании базы данных возникает только при первом выполнении palybook, т.к. служба СУБД не успевает подняться после установки. Добавлена конструкция проверки запуска службы на порту 9000.

```YAML
    - name: "Wait for Clickhouse Server to Become Ready"
      wait_for:
        port: 9000
        delay: 5
```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

__Ответ:__

При повторных запусках вывод был одинаковый:

```BASH
 ansible-playbook -i inventory/prod.yml site.yml --diff --ask-become-pass
BECOME password: 

PLAY [Install Clickhouse] ******************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] **************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1000, "group": "rpot", "item": "clickhouse-common-static", "mode": "0444", "msg": "Request failed", "owner": "rpot", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] **************************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] *********************************************************************************************************
ok: [clickhouse-01]

TASK [Create database] *********************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install Vector] **********************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get Vector distrib] ******************************************************************************************************************
ok: [clickhouse-01]

TASK [Install Vector packages] *************************************************************************************************************
ok: [clickhouse-01]

PLAY RECAP *********************************************************************************************************************************
clickhouse-01              : ok=7    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   

rpot@rp-srv-ntlg03:~/projects/netology-0802$ ansible-playbook -i inventory/prod.yml site.yml --diff --ask-become-pass
BECOME password: 

PLAY [Install Clickhouse] ******************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] **************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1000, "group": "rpot", "item": "clickhouse-common-static", "mode": "0444", "msg": "Request failed", "owner": "rpot", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1000, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] **************************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] *********************************************************************************************************
ok: [clickhouse-01]

TASK [Wait for Clickhouse Server to Become Ready] ******************************************************************************************
ok: [clickhouse-01]

TASK [Create database] *********************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install Vector] **********************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************
ok: [clickhouse-01]

TASK [Get Vector distrib] ******************************************************************************************************************
ok: [clickhouse-01]

TASK [Install Vector packages] *************************************************************************************************************
ok: [clickhouse-01]

PLAY RECAP *********************************************************************************************************************************
clickhouse-01              : ok=8    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
```

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

__Ответ:__

Выполнено

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

__Ответ:__

https://github.com/RPotsel/netology-0802
