# Домашнее задание к занятию "08.05 Тестирование Roles"

Наша основная цель - настроить тестирование наших ролей. Задача: сделать сценарии тестирования для vector. Ожидаемый результат: все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test -s centos7` внутри корневой директории clickhouse-role, посмотрите на вывод команды.
2. Перейдите в каталог с ролью vector-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.
3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
4. Добавьте несколько assert'ов в verify.yml файл для  проверки работоспособности vector-role (проверка, что конфиг валидный, проверка успешности запуска, etc). Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
5. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

__Ответ:__

Ссылка на репозиторий: https://github.com/RPotsel/vector-role

Версия с тестированием molecule: https://github.com/RPotsel/vector-role/releases/tag/1.2

<details><summary>Вывод команды molecule test</summary>

```BASH
COMMAND: yamllint .
ansible-lint .

WARNING: PATH altered to include /usr/bin
WARNING  Computed fully qualified role name of vector-role does not follow current galaxy requirements.
Please edit meta/main.yml and assure we can correctly determine full role name:

galaxy_info:
role_name: my_name  # if absent directory name hosting role is used instead
namespace: my_galaxy_namespace  # if absent, author is used instead

Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names

As an alternative, you can add 'role-name' to either skip_list or warn_list.

WARNING  Loading custom .yamllint config file, this extends our internal yamllint config.
WARNING  Listing 1 violation(s) that are fatal
[91mrole-name[0m[2m:[0m [31mRole name vector-role does not match ``^[a-z][a-z0-9_]+$`` pattern[0m
[34mmeta/main.yml[0m:1


Finished with [1;36m0[0m [1;35mfailure[0m[1m([0ms[1m)[0m, [1;36m1[0m [1;35mwarning[0m[1m([0ms[1m)[0m on [1;36m10[0m files.

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
[33mchanged: [localhost] => (item=centos_8)[0m
[33mchanged: [localhost] => (item=ubuntu)[0m
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) deletion to complete] *******************************
[32mok: [localhost] => (item=centos_8)[0m
[32mok: [localhost] => (item=ubuntu)[0m
[32mok: [localhost] => (item=centos_7)[0m

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=2   [0m [33mchanged=1   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0


PLAY [Create] ******************************************************************

TASK [Log into a Docker registry] **********************************************
[36mskipping: [localhost] => (item=None) [0m
[36mskipping: [localhost] => (item=None) [0m
[36mskipping: [localhost] => (item=None) [0m
[36mskipping: [localhost][0m

TASK [Check presence of custom Dockerfiles] ************************************
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:8', 'name': 'centos_8', 'privileged': True, 'run': "sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* &&  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*\n"})[0m
[32mok: [localhost] => (item={'command': '/sbin/init', 'dockerfile': 'Dockerfile.j2', 'env': {'DEBIAN_FRONTEND': 'noninteractive', 'TZ': 'Etc/GMT+4'}, 'image': 'ubuntu:20.04', 'name': 'ubuntu', 'privileged': True})[0m
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Create Dockerfiles from image names] *************************************
[33mchanged: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:8', 'name': 'centos_8', 'privileged': True, 'run': "sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* &&  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*\n"})[0m
[33mchanged: [localhost] => (item={'command': '/sbin/init', 'dockerfile': 'Dockerfile.j2', 'env': {'DEBIAN_FRONTEND': 'noninteractive', 'TZ': 'Etc/GMT+4'}, 'image': 'ubuntu:20.04', 'name': 'ubuntu', 'privileged': True})[0m
[33mchanged: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Discover local Docker images] ********************************************
[32mok: [localhost] => (item={'diff': [], 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_8', 'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653662799.4923196-41948-52886019545778/source', 'md5sum': '22890838e8cb3602c39967ff38065d60', 'checksum': '230c89511ef848f4a48543b78bf4ae77fbcae414', 'changed': True, 'uid': 1000, 'gid': 1000, 'owner': 'rpot', 'group': 'rpot', 'mode': '0600', 'state': 'file', 'size': 450, 'invocation': {'module_args': {'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653662799.4923196-41948-52886019545778/source', 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_8', 'mode': '0600', 'follow': False, '_original_basename': 'Dockerfile.j2', 'checksum': '230c89511ef848f4a48543b78bf4ae77fbcae414', 'backup': False, 'force': True, 'unsafe_writes': False, 'content': None, 'validate': None, 'directory_mode': None, 'remote_src': None, 'local_follow': None, 'owner': None, 'group': None, 'seuser': None, 'serole': None, 'selevel': None, 'setype': None, 'attributes': None}}, 'failed': False, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:8', 'name': 'centos_8', 'privileged': True, 'run': "sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* &&  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*\n"}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})[0m
[32mok: [localhost] => (item={'diff': [], 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_ubuntu_20_04', 'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653662801.2662406-41948-244934905692775/source', 'md5sum': '1f10a038b42efcd77b39488763effab6', 'checksum': 'a6bef63e592df4f5792a84fc3efb5f36872ac724', 'changed': True, 'uid': 1000, 'gid': 1000, 'owner': 'rpot', 'group': 'rpot', 'mode': '0600', 'state': 'file', 'size': 346, 'invocation': {'module_args': {'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653662801.2662406-41948-244934905692775/source', 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_ubuntu_20_04', 'mode': '0600', 'follow': False, '_original_basename': 'Dockerfile.j2', 'checksum': 'a6bef63e592df4f5792a84fc3efb5f36872ac724', 'backup': False, 'force': True, 'unsafe_writes': False, 'content': None, 'validate': None, 'directory_mode': None, 'remote_src': None, 'local_follow': None, 'owner': None, 'group': None, 'seuser': None, 'serole': None, 'selevel': None, 'setype': None, 'attributes': None}}, 'failed': False, 'item': {'command': '/sbin/init', 'dockerfile': 'Dockerfile.j2', 'env': {'DEBIAN_FRONTEND': 'noninteractive', 'TZ': 'Etc/GMT+4'}, 'image': 'ubuntu:20.04', 'name': 'ubuntu', 'privileged': True}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})[0m
[32mok: [localhost] => (item={'diff': [], 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_7', 'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653662802.5391567-41948-101389546741929/source', 'md5sum': '872034d0702b14037969bd9009bd8e92', 'checksum': 'c33460bc2b768d364164db57197365476531c7ed', 'changed': True, 'uid': 1000, 'gid': 1000, 'owner': 'rpot', 'group': 'rpot', 'mode': '0600', 'state': 'file', 'size': 273, 'invocation': {'module_args': {'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653662802.5391567-41948-101389546741929/source', 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_7', 'mode': '0600', 'follow': False, '_original_basename': 'Dockerfile.j2', 'checksum': 'c33460bc2b768d364164db57197365476531c7ed', 'backup': False, 'force': True, 'unsafe_writes': False, 'content': None, 'validate': None, 'directory_mode': None, 'remote_src': None, 'local_follow': None, 'owner': None, 'group': None, 'seuser': None, 'serole': None, 'selevel': None, 'setype': None, 'attributes': None}}, 'failed': False, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True}, 'ansible_loop_var': 'item', 'i': 2, 'ansible_index_var': 'i'})[0m

TASK [Build an Ansible compatible image (new)] *********************************
[32mok: [localhost] => (item=molecule_local/centos:8)[0m
[32mok: [localhost] => (item=molecule_local/ubuntu:20.04)[0m
[33mchanged: [localhost] => (item=molecule_local/centos:7)[0m

TASK [Create docker network(s)] ************************************************

TASK [Determine the CMD directives] ********************************************
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:8', 'name': 'centos_8', 'privileged': True, 'run': "sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* &&  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*\n"})[0m
[32mok: [localhost] => (item={'command': '/sbin/init', 'dockerfile': 'Dockerfile.j2', 'env': {'DEBIAN_FRONTEND': 'noninteractive', 'TZ': 'Etc/GMT+4'}, 'image': 'ubuntu:20.04', 'name': 'ubuntu', 'privileged': True})[0m
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Create molecule instance(s)] *********************************************
[33mchanged: [localhost] => (item=centos_8)[0m
[33mchanged: [localhost] => (item=ubuntu)[0m
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) creation to complete] *******************************
[33mchanged: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '313289330766.42557', 'results_file': '/home/rpot/.ansible_async/313289330766.42557', 'changed': True, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:8', 'name': 'centos_8', 'privileged': True, 'run': "sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* &&  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*\n"}, 'ansible_loop_var': 'item'})[0m
[33mchanged: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '450916495451.42585', 'results_file': '/home/rpot/.ansible_async/450916495451.42585', 'changed': True, 'item': {'command': '/sbin/init', 'dockerfile': 'Dockerfile.j2', 'env': {'DEBIAN_FRONTEND': 'noninteractive', 'TZ': 'Etc/GMT+4'}, 'image': 'ubuntu:20.04', 'name': 'ubuntu', 'privileged': True}, 'ansible_loop_var': 'item'})[0m
[33mchanged: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '980163860042.42612', 'results_file': '/home/rpot/.ansible_async/980163860042.42612', 'changed': True, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True}, 'ansible_loop_var': 'item'})[0m

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=7   [0m [33mchanged=4   [0m unreachable=0    failed=0    [36mskipped=2   [0m rescued=0    ignored=0


PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
[32mok: [ubuntu][0m
[32mok: [centos_8][0m
[32mok: [centos_7][0m

TASK [Include vector-role] *****************************************************

TASK [vector-role : Vector | Install] ******************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/install.yml for centos_7, centos_8, ubuntu[0m

TASK [vector-role : Vector | Install package for CentOS] ***********************
[36mskipping: [ubuntu][0m
[33mchanged: [centos_7][0m
[33mchanged: [centos_8][0m

TASK [vector-role : Vector | Install package for Ubuntu] ***********************
[36mskipping: [centos_7][0m
[36mskipping: [centos_8][0m
Selecting previously unselected package vector.
(Reading database ... 8651 files and directories currently installed.)
Preparing to unpack .../vector_0.21.2-1_amd64qy19orex.deb ...
Unpacking vector (0.21.2-1) ...
Setting up vector (0.21.2-1) ...
systemd-journal:x:102:
[33mchanged: [ubuntu][0m

TASK [vector-role : Vector | Configure] ****************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/config.yml for centos_7, centos_8, ubuntu[0m

TASK [vector-role : Vector | Configure vector] *********************************
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-43292m5qigs7v/tmpqoz1pimh/vector.yml.j2[0m
[36m@@ -0,0 +1,18 @@[0m
[32m+sinks:[0m
[32m+    to_clickhouse:[0m
[32m+        compression: gzip[0m
[32m+        database: logs[0m
[32m+        endpoint: http://127.0.0.1:8123[0m
[32m+        healthcheck: false[0m
[32m+        inputs:[0m
[32m+        - our_log[0m
[32m+        skip_unknown_fields: true[0m
[32m+        table: my_table[0m
[32m+        type: clickhouse[0m
[32m+sources:[0m
[32m+    our_log:[0m
[32m+        ignore_older_secs: 600[0m
[32m+        include:[0m
[32m+        - /var/log/**/*.log[0m
[32m+        read_from: beginning[0m
[32m+        type: file[0m

[33mchanged: [ubuntu][0m
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-43292m5qigs7v/tmpgiwt9a59/vector.yml.j2[0m
[36m@@ -0,0 +1,18 @@[0m
[32m+sinks:[0m
[32m+    to_clickhouse:[0m
[32m+        compression: gzip[0m
[32m+        database: logs[0m
[32m+        endpoint: http://127.0.0.1:8123[0m
[32m+        healthcheck: false[0m
[32m+        inputs:[0m
[32m+        - our_log[0m
[32m+        skip_unknown_fields: true[0m
[32m+        table: my_table[0m
[32m+        type: clickhouse[0m
[32m+sources:[0m
[32m+    our_log:[0m
[32m+        ignore_older_secs: 600[0m
[32m+        include:[0m
[32m+        - /var/log/**/*.log[0m
[32m+        read_from: beginning[0m
[32m+        type: file[0m

[33mchanged: [centos_8][0m
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-43292m5qigs7v/tmpexpg6yqg/vector.yml.j2[0m
[36m@@ -0,0 +1,18 @@[0m
[32m+sinks:[0m
[32m+    to_clickhouse:[0m
[32m+        compression: gzip[0m
[32m+        database: logs[0m
[32m+        endpoint: http://127.0.0.1:8123[0m
[32m+        healthcheck: false[0m
[32m+        inputs:[0m
[32m+        - our_log[0m
[32m+        skip_unknown_fields: true[0m
[32m+        table: my_table[0m
[32m+        type: clickhouse[0m
[32m+sources:[0m
[32m+    our_log:[0m
[32m+        ignore_older_secs: 600[0m
[32m+        include:[0m
[32m+        - /var/log/**/*.log[0m
[32m+        read_from: beginning[0m
[32m+        type: file[0m

[33mchanged: [centos_7][0m

TASK [vector-role : Vector | Service] ******************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/service.yml for centos_7, centos_8, ubuntu[0m

TASK [vector-role : Vector | create systemd unit] ******************************
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-43292m5qigs7v/tmpjcym9ejk/vector.service.j2[0m
[36m@@ -0,0 +1,11 @@[0m
[32m+[Unit][0m
[32m+Description=Vector service[0m
[32m+After=network.target[0m
[32m+Requires=network-online.target[0m
[32m+[Service][0m
[32m+User=root[0m
[32m+Group=0[0m
[32m+ExecStart=/usr/bin/vector --config-yaml vector.yml --watch-config[0m
[32m+Restart=always[0m
[32m+[Install][0m
[32m+WantedBy=multi-user.target[0m

[33mchanged: [centos_7][0m
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-43292m5qigs7v/tmp33ccku5r/vector.service.j2[0m
[36m@@ -0,0 +1,11 @@[0m
[32m+[Unit][0m
[32m+Description=Vector service[0m
[32m+After=network.target[0m
[32m+Requires=network-online.target[0m
[32m+[Service][0m
[32m+User=root[0m
[32m+Group=0[0m
[32m+ExecStart=/usr/bin/vector --config-yaml vector.yml --watch-config[0m
[32m+Restart=always[0m
[32m+[Install][0m
[32m+WantedBy=multi-user.target[0m

[33mchanged: [ubuntu][0m
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-43292m5qigs7v/tmp7fnv5tpg/vector.service.j2[0m
[36m@@ -0,0 +1,11 @@[0m
[32m+[Unit][0m
[32m+Description=Vector service[0m
[32m+After=network.target[0m
[32m+Requires=network-online.target[0m
[32m+[Service][0m
[32m+User=root[0m
[32m+Group=0[0m
[32m+ExecStart=/usr/bin/vector --config-yaml vector.yml --watch-config[0m
[32m+Restart=always[0m
[32m+[Install][0m
[32m+WantedBy=multi-user.target[0m

[33mchanged: [centos_8][0m

RUNNING HANDLER [vector-role : start_vector] ***********************************
[33mchanged: [ubuntu][0m
[33mchanged: [centos_8][0m
[33mchanged: [centos_7][0m

PLAY RECAP *********************************************************************
[33mcentos_7[0m                   : [32mok=8   [0m [33mchanged=4   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0
[33mcentos_8[0m                   : [32mok=8   [0m [33mchanged=4   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0
[33mubuntu[0m                     : [32mok=8   [0m [33mchanged=4   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0


PLAY [Verify] ******************************************************************

TASK [Ensure vector service is started and enabled] ****************************
[32mok: [ubuntu][0m
[32mok: [centos_8][0m
[32mok: [centos_7][0m

TASK [Validate vector config file] *********************************************
[32mok: [ubuntu][0m
[32mok: [centos_8][0m
[32mok: [centos_7][0m

TASK [Debug out var] ***********************************************************
[32mok: [centos_7] => {[0m
[32m    "validate_result.stdout_lines": [[0m
[32m        "√ Loaded [\"vector.yml\"]",[0m
[32m        "-----------------------",[0m
[32m        "              Validated"[0m
[32m    ][0m
[32m}[0m
[32mok: [centos_8] => {[0m
[32m    "validate_result.stdout_lines": [[0m
[32m        "√ Loaded [\"vector.yml\"]",[0m
[32m        "-----------------------",[0m
[32m        "              Validated"[0m
[32m    ][0m
[32m}[0m
[32mok: [ubuntu] => {[0m
[32m    "validate_result.stdout_lines": [[0m
[32m        "√ Loaded [\"vector.yml\"]",[0m
[32m        "-----------------------",[0m
[32m        "              Validated"[0m
[32m    ][0m
[32m}[0m

PLAY RECAP *********************************************************************
[32mcentos_7[0m                   : [32mok=3   [0m changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
[32mcentos_8[0m                   : [32mok=3   [0m changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
[32mubuntu[0m                     : [32mok=3   [0m changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
[33mchanged: [localhost] => (item=centos_8)[0m
[33mchanged: [localhost] => (item=ubuntu)[0m
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) deletion to complete] *******************************
[33mchanged: [localhost] => (item=centos_8)[0m
[33mchanged: [localhost] => (item=ubuntu)[0m
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=2   [0m [33mchanged=2   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0
```
</details>

### Tox

1. Добавьте в директорию с vector-role файлы из [директории](./example)
2. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it <image_name> /bin/bash`, где path_to_repo - путь до корня репозитория с vector-role на вашей файловой системе.
3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.
5. Создайте облегчённый сценарий для `molecule`. Проверьте его на исполнимость.
6. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.
8. Запустите команду `tox`. Убедитесь, что всё отработало успешно.
9. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в репозитории. Ссылка на репозиторий являются ответами на домашнее задание. Не забудьте указать в ответе теги решений Tox и Molecule заданий.

__Ответ:__

Времени разобраться почему не заработал предложенный [Dockerfile](https://github.com/netology-code/mnt-homeworks/blob/MNT-13/08-ansible-05-testing/Dockerfile) не было и найти или создать контейнер в котором, как понял, запускались контейнеры для проверки кода тоже. Поэтому tox запускал на ВМ.

Ссылка на репозиторий: https://github.com/RPotsel/vector-role

Версия с тестированием molecule: https://github.com/RPotsel/vector-role/releases/tag/1.3

<details><summary>Вывод команды tox</summary>

```BASH
py3713-ansible210 installed: ansible==2.10.7,ansible-base==2.10.17,ansible-compat==2.1.0,ansible-lint==5.1.3,arrow==1.2.2,attrs==21.4.0,bcrypt==3.2.2,binaryornot==0.4.4,bracex==2.3,Cerberus==1.3.2,certifi==2022.5.18.1,cffi==1.15.0,chardet==4.0.0,charset-normalizer==2.0.12,click==8.1.3,click-help-colors==0.9.1,commonmark==0.9.1,cookiecutter==1.7.3,cryptography==37.0.2,distro==1.7.0,docker==5.0.3,enrich==1.2.7,idna==3.3,importlib-resources==5.7.1,Jinja2==3.1.2,jinja2-time==0.2.0,jmespath==1.0.0,jsonschema==4.5.1,lxml==4.8.0,MarkupSafe==2.1.1,molecule==3.4.0,molecule-docker==1.1.0,packaging==21.3,paramiko==2.11.0,pathspec==0.9.0,pluggy==0.13.1,poyo==0.5.0,pycparser==2.21,Pygments==2.12.0,PyNaCl==1.5.0,pyparsing==3.0.9,pyrsistent==0.18.1,python-dateutil==2.8.2,python-slugify==6.1.2,PyYAML==5.4.1,requests==2.27.1,rich==12.4.4,ruamel.yaml==0.17.21,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.0.1,text-unidecode==1.3,typing_extensions==4.2.0,urllib3==1.26.9,wcmatch==8.3,websocket-client==1.3.2,yamllint==1.26.3,zipp==3.8.0
py3713-ansible210 run-test-pre: PYTHONHASHSEED='4254715060'
py3713-ansible210 run-test: commands[0] | molecule test
[34mINFO    [0m default scenario test matrix: dependency, destroy, create, converge, verify, cleanup, destroy
[34mINFO    [0m Performing prerun[33m...[0m
[34mINFO    [0m Guessed [35m/home/rpot/projects/[0m[95mvector-role[0m as project root directory
[31mWARNING [0m Computed fully qualified role name of vector-role does not follow current galaxy requirements.
Please edit meta/main.yml and assure we can correctly determine full role name:

galaxy_info:
role_name: my_name  # if absent directory name hosting role is used instead
namespace: my_galaxy_namespace  # if absent, author is used instead

Namespace: [4;94mhttps://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations[0m
Role: [4;94mhttps://galaxy.ansible.com/docs/contributing/creating_role.html#role-names[0m

As an alternative, you can add [32m'role-name'[0m to either skip_list or warn_list.

[34mINFO    [0m Using [35m/home/rpot/.cache/ansible-lint/9c86ea/roles/[0m[95mvector-role[0m symlink to current repository in order to enable Ansible to find the role using its expected full name.
[34mINFO    [0m Added [33mANSIBLE_ROLES_PATH[0m=~[35m/.ansible/[0m[95mroles[0m:[35m/usr/share/ansible/[0m[95mroles[0m:[35m/etc/ansible/[0m[95mroles[0m:[35m/home/rpot/.cache/ansible-lint/9c86ea/[0m[95mroles[0m
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdependency[0m
[31mWARNING [0m Skipping, missing the requirements file.
[31mWARNING [0m Skipping, missing the requirements file.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdestroy[0m
[34mINFO    [0m Sanity checks: [32m'docker'[0m

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) deletion to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).[0m
[32mok: [localhost] => (item=centos_7)[0m

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=2   [0m [33mchanged=1   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mcreate[0m

PLAY [Create] ******************************************************************

TASK [Log into a Docker registry] **********************************************
[36mskipping: [localhost] => (item=None) [0m
[36mskipping: [localhost][0m

TASK [Check presence of custom Dockerfiles] ************************************
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Create Dockerfiles from image names] *************************************
[33mchanged: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Discover local Docker images] ********************************************
[32mok: [localhost] => (item={'diff': [], 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_7', 'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653842451.6291487-101423-33842054936636/source', 'md5sum': '872034d0702b14037969bd9009bd8e92', 'checksum': 'c33460bc2b768d364164db57197365476531c7ed', 'changed': True, 'uid': 1000, 'gid': 1000, 'owner': 'rpot', 'group': 'rpot', 'mode': '0600', 'state': 'file', 'size': 273, 'invocation': {'module_args': {'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653842451.6291487-101423-33842054936636/source', 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_7', 'mode': '0600', 'follow': False, '_original_basename': 'Dockerfile.j2', 'checksum': 'c33460bc2b768d364164db57197365476531c7ed', 'backup': False, 'force': True, 'unsafe_writes': False, 'content': None, 'validate': None, 'directory_mode': None, 'remote_src': None, 'local_follow': None, 'owner': None, 'group': None, 'seuser': None, 'serole': None, 'selevel': None, 'setype': None, 'attributes': None}}, 'failed': False, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})[0m

TASK [Build an Ansible compatible image (new)] *********************************
[32mok: [localhost] => (item=molecule_local/centos:7)[0m

TASK [Create docker network(s)] ************************************************

TASK [Determine the CMD directives] ********************************************
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Create molecule instance(s)] *********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) creation to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).[0m
[33mchanged: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '236386152915.101569', 'results_file': '/home/rpot/.ansible_async/236386152915.101569', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True}, 'ansible_loop_var': 'item'})[0m

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=7   [0m [33mchanged=3   [0m unreachable=0    failed=0    [36mskipped=2   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mconverge[0m

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
[32mok: [centos_7][0m

TASK [Include vector-role] *****************************************************

TASK [vector-role : Vector | Install] ******************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/install.yml for centos_7[0m

TASK [vector-role : Vector | Install package for CentOS] ***********************
[33mchanged: [centos_7][0m

TASK [vector-role : Vector | Install package for Ubuntu] ***********************
[36mskipping: [centos_7][0m

TASK [vector-role : Vector | Configure] ****************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/config.yml for centos_7[0m

TASK [vector-role : Vector | Configure vector] *********************************
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-101847bjft7a46/tmpy6gt0s4_/vector.yml.j2[0m
[36m@@ -0,0 +1,18 @@[0m
[32m+sinks:[0m
[32m+    to_clickhouse:[0m
[32m+        compression: gzip[0m
[32m+        database: logs[0m
[32m+        endpoint: http://127.0.0.1:8123[0m
[32m+        healthcheck: false[0m
[32m+        inputs:[0m
[32m+        - our_log[0m
[32m+        skip_unknown_fields: true[0m
[32m+        table: my_table[0m
[32m+        type: clickhouse[0m
[32m+sources:[0m
[32m+    our_log:[0m
[32m+        ignore_older_secs: 600[0m
[32m+        include:[0m
[32m+        - /var/log/**/*.log[0m
[32m+        read_from: beginning[0m
[32m+        type: file[0m

[1;35m[WARNING]: The value "0" (type int) was converted to "u'0'" (type string). If[0m
[1;35mthis does not look like what you expect, quote the entire value to ensure it[0m
[1;35mdoes not change.[0m
[33mchanged: [centos_7][0m

TASK [vector-role : Vector | Service] ******************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/service.yml for centos_7[0m

TASK [vector-role : Vector | create systemd unit] ******************************
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-101847bjft7a46/tmpe_9ga9dh/vector.service.j2[0m
[36m@@ -0,0 +1,11 @@[0m
[32m+[Unit][0m
[32m+Description=Vector service[0m
[32m+After=network.target[0m
[32m+Requires=network-online.target[0m
[32m+[Service][0m
[32m+User=root[0m
[32m+Group=0[0m
[32m+ExecStart=/usr/bin/vector --config-yaml vector.yml --watch-config[0m
[32m+Restart=always[0m
[32m+[Install][0m
[32m+WantedBy=multi-user.target[0m

[33mchanged: [centos_7][0m

RUNNING HANDLER [vector-role : start_vector] ***********************************
[33mchanged: [centos_7][0m

PLAY RECAP *********************************************************************
[33mcentos_7[0m                   : [32mok=8   [0m [33mchanged=4   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mverify[0m
[34mINFO    [0m Running Ansible Verifier

PLAY [Verify] ******************************************************************

TASK [Ensure vector service is started and enabled] ****************************
[32mok: [centos_7][0m

TASK [Validate vector config file] *********************************************
[32mok: [centos_7][0m

TASK [Debug out var] ***********************************************************
[32mok: [centos_7] => {[0m
[32m    "validate_result.stdout_lines": [[0m
[32m        "√ Loaded [\"vector.yml\"]",[0m
[32m        "-----------------------",[0m
[32m        "              Validated"[0m
[32m    ][0m
[32m}[0m

PLAY RECAP *********************************************************************
[32mcentos_7[0m                   : [32mok=3   [0m changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[34mINFO    [0m Verifier completed successfully.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mcleanup[0m
[31mWARNING [0m Skipping, cleanup playbook not configured.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdestroy[0m

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) deletion to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).[0m
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=2   [0m [33mchanged=2   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m Pruning extra files from scenario ephemeral directory
py3713-ansible30 installed: ansible==3.0.0,ansible-base==2.10.17,ansible-compat==2.1.0,ansible-lint==5.1.3,arrow==1.2.2,attrs==21.4.0,bcrypt==3.2.2,binaryornot==0.4.4,bracex==2.3,Cerberus==1.3.2,certifi==2022.5.18.1,cffi==1.15.0,chardet==4.0.0,charset-normalizer==2.0.12,click==8.1.3,click-help-colors==0.9.1,commonmark==0.9.1,cookiecutter==1.7.3,cryptography==37.0.2,distro==1.7.0,docker==5.0.3,enrich==1.2.7,idna==3.3,importlib-resources==5.7.1,Jinja2==3.1.2,jinja2-time==0.2.0,jmespath==1.0.0,jsonschema==4.5.1,lxml==4.8.0,MarkupSafe==2.1.1,molecule==3.4.0,molecule-docker==1.1.0,packaging==21.3,paramiko==2.11.0,pathspec==0.9.0,pluggy==0.13.1,poyo==0.5.0,pycparser==2.21,Pygments==2.12.0,PyNaCl==1.5.0,pyparsing==3.0.9,pyrsistent==0.18.1,python-dateutil==2.8.2,python-slugify==6.1.2,PyYAML==5.4.1,requests==2.27.1,rich==12.4.4,ruamel.yaml==0.17.21,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.0.1,text-unidecode==1.3,typing_extensions==4.2.0,urllib3==1.26.9,wcmatch==8.3,websocket-client==1.3.2,yamllint==1.26.3,zipp==3.8.0
py3713-ansible30 run-test-pre: PYTHONHASHSEED='4254715060'
py3713-ansible30 run-test: commands[0] | molecule test
[34mINFO    [0m default scenario test matrix: dependency, destroy, create, converge, verify, cleanup, destroy
[34mINFO    [0m Performing prerun[33m...[0m
[34mINFO    [0m Guessed [35m/home/rpot/projects/[0m[95mvector-role[0m as project root directory
[31mWARNING [0m Computed fully qualified role name of vector-role does not follow current galaxy requirements.
Please edit meta/main.yml and assure we can correctly determine full role name:

galaxy_info:
role_name: my_name  # if absent directory name hosting role is used instead
namespace: my_galaxy_namespace  # if absent, author is used instead

Namespace: [4;94mhttps://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations[0m
Role: [4;94mhttps://galaxy.ansible.com/docs/contributing/creating_role.html#role-names[0m

As an alternative, you can add [32m'role-name'[0m to either skip_list or warn_list.

[34mINFO    [0m Using [35m/home/rpot/.cache/ansible-lint/9c86ea/roles/[0m[95mvector-role[0m symlink to current repository in order to enable Ansible to find the role using its expected full name.
[34mINFO    [0m Added [33mANSIBLE_ROLES_PATH[0m=~[35m/.ansible/[0m[95mroles[0m:[35m/usr/share/ansible/[0m[95mroles[0m:[35m/etc/ansible/[0m[95mroles[0m:[35m/home/rpot/.cache/ansible-lint/9c86ea/[0m[95mroles[0m
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdependency[0m
[31mWARNING [0m Skipping, missing the requirements file.
[31mWARNING [0m Skipping, missing the requirements file.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdestroy[0m
[34mINFO    [0m Sanity checks: [32m'docker'[0m

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) deletion to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).[0m
[32mok: [localhost] => (item=centos_7)[0m

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=2   [0m [33mchanged=1   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mcreate[0m

PLAY [Create] ******************************************************************

TASK [Log into a Docker registry] **********************************************
[36mskipping: [localhost] => (item=None) [0m
[36mskipping: [localhost][0m

TASK [Check presence of custom Dockerfiles] ************************************
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Create Dockerfiles from image names] *************************************
[33mchanged: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Discover local Docker images] ********************************************
[32mok: [localhost] => (item={'diff': [], 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_7', 'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653842595.7424197-103981-7389056239523/source', 'md5sum': '872034d0702b14037969bd9009bd8e92', 'checksum': 'c33460bc2b768d364164db57197365476531c7ed', 'changed': True, 'uid': 1000, 'gid': 1000, 'owner': 'rpot', 'group': 'rpot', 'mode': '0600', 'state': 'file', 'size': 273, 'invocation': {'module_args': {'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653842595.7424197-103981-7389056239523/source', 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_7', 'mode': '0600', 'follow': False, '_original_basename': 'Dockerfile.j2', 'checksum': 'c33460bc2b768d364164db57197365476531c7ed', 'backup': False, 'force': True, 'unsafe_writes': False, 'content': None, 'validate': None, 'directory_mode': None, 'remote_src': None, 'local_follow': None, 'owner': None, 'group': None, 'seuser': None, 'serole': None, 'selevel': None, 'setype': None, 'attributes': None}}, 'failed': False, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})[0m

TASK [Build an Ansible compatible image (new)] *********************************
[32mok: [localhost] => (item=molecule_local/centos:7)[0m

TASK [Create docker network(s)] ************************************************

TASK [Determine the CMD directives] ********************************************
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Create molecule instance(s)] *********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) creation to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).[0m
[33mchanged: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '761099482371.104127', 'results_file': '/home/rpot/.ansible_async/761099482371.104127', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True}, 'ansible_loop_var': 'item'})[0m

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=7   [0m [33mchanged=3   [0m unreachable=0    failed=0    [36mskipped=2   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mconverge[0m

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
[32mok: [centos_7][0m

TASK [Include vector-role] *****************************************************

TASK [vector-role : Vector | Install] ******************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/install.yml for centos_7[0m

TASK [vector-role : Vector | Install package for CentOS] ***********************
[33mchanged: [centos_7][0m

TASK [vector-role : Vector | Install package for Ubuntu] ***********************
[36mskipping: [centos_7][0m

TASK [vector-role : Vector | Configure] ****************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/config.yml for centos_7[0m

TASK [vector-role : Vector | Configure vector] *********************************
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-104388suzo6imr/tmpubuyc0h8/vector.yml.j2[0m
[36m@@ -0,0 +1,18 @@[0m
[32m+sinks:[0m
[32m+    to_clickhouse:[0m
[32m+        compression: gzip[0m
[32m+        database: logs[0m
[32m+        endpoint: http://127.0.0.1:8123[0m
[32m+        healthcheck: false[0m
[32m+        inputs:[0m
[32m+        - our_log[0m
[32m+        skip_unknown_fields: true[0m
[32m+        table: my_table[0m
[32m+        type: clickhouse[0m
[32m+sources:[0m
[32m+    our_log:[0m
[32m+        ignore_older_secs: 600[0m
[32m+        include:[0m
[32m+        - /var/log/**/*.log[0m
[32m+        read_from: beginning[0m
[32m+        type: file[0m

[1;35m[WARNING]: The value "0" (type int) was converted to "u'0'" (type string). If[0m
[1;35mthis does not look like what you expect, quote the entire value to ensure it[0m
[1;35mdoes not change.[0m
[33mchanged: [centos_7][0m

TASK [vector-role : Vector | Service] ******************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/service.yml for centos_7[0m

TASK [vector-role : Vector | create systemd unit] ******************************
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-104388suzo6imr/tmpoxdzj4bd/vector.service.j2[0m
[36m@@ -0,0 +1,11 @@[0m
[32m+[Unit][0m
[32m+Description=Vector service[0m
[32m+After=network.target[0m
[32m+Requires=network-online.target[0m
[32m+[Service][0m
[32m+User=root[0m
[32m+Group=0[0m
[32m+ExecStart=/usr/bin/vector --config-yaml vector.yml --watch-config[0m
[32m+Restart=always[0m
[32m+[Install][0m
[32m+WantedBy=multi-user.target[0m

[33mchanged: [centos_7][0m

RUNNING HANDLER [vector-role : start_vector] ***********************************
[33mchanged: [centos_7][0m

PLAY RECAP *********************************************************************
[33mcentos_7[0m                   : [32mok=8   [0m [33mchanged=4   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mverify[0m
[34mINFO    [0m Running Ansible Verifier

PLAY [Verify] ******************************************************************

TASK [Ensure vector service is started and enabled] ****************************
[32mok: [centos_7][0m

TASK [Validate vector config file] *********************************************
[32mok: [centos_7][0m

TASK [Debug out var] ***********************************************************
[32mok: [centos_7] => {[0m
[32m    "validate_result.stdout_lines": [[0m
[32m        "√ Loaded [\"vector.yml\"]",[0m
[32m        "-----------------------",[0m
[32m        "              Validated"[0m
[32m    ][0m
[32m}[0m

PLAY RECAP *********************************************************************
[32mcentos_7[0m                   : [32mok=3   [0m changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[34mINFO    [0m Verifier completed successfully.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mcleanup[0m
[31mWARNING [0m Skipping, cleanup playbook not configured.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdestroy[0m

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) deletion to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).[0m
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=2   [0m [33mchanged=2   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m Pruning extra files from scenario ephemeral directory
py39-ansible210 installed: ansible==2.10.7,ansible-base==2.10.17,ansible-compat==2.1.0,ansible-lint==5.1.3,arrow==1.2.2,attrs==21.4.0,bcrypt==3.2.2,binaryornot==0.4.4,bracex==2.3,Cerberus==1.3.2,certifi==2022.5.18.1,cffi==1.15.0,chardet==4.0.0,charset-normalizer==2.0.12,click==8.1.3,click-help-colors==0.9.1,commonmark==0.9.1,cookiecutter==1.7.3,cryptography==37.0.2,distro==1.7.0,docker==5.0.3,enrich==1.2.7,idna==3.3,Jinja2==3.1.2,jinja2-time==0.2.0,jmespath==1.0.0,jsonschema==4.5.1,lxml==4.8.0,MarkupSafe==2.1.1,molecule==3.4.0,molecule-docker==1.1.0,packaging==21.3,paramiko==2.11.0,pathspec==0.9.0,pluggy==0.13.1,poyo==0.5.0,pycparser==2.21,Pygments==2.12.0,PyNaCl==1.5.0,pyparsing==3.0.9,pyrsistent==0.18.1,python-dateutil==2.8.2,python-slugify==6.1.2,PyYAML==5.4.1,requests==2.27.1,rich==12.4.4,ruamel.yaml==0.17.21,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.0.1,text-unidecode==1.3,urllib3==1.26.9,wcmatch==8.3,websocket-client==1.3.2,yamllint==1.26.3
py39-ansible210 run-test-pre: PYTHONHASHSEED='4254715060'
py39-ansible210 run-test: commands[0] | molecule test
[34mINFO    [0m default scenario test matrix: dependency, destroy, create, converge, verify, cleanup, destroy
[34mINFO    [0m Performing prerun[33m...[0m
[34mINFO    [0m Guessed [35m/home/rpot/projects/[0m[95mvector-role[0m as project root directory
[31mWARNING [0m Computed fully qualified role name of vector-role does not follow current galaxy requirements.
Please edit meta/main.yml and assure we can correctly determine full role name:

galaxy_info:
role_name: my_name  # if absent directory name hosting role is used instead
namespace: my_galaxy_namespace  # if absent, author is used instead

Namespace: [4;94mhttps://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations[0m
Role: [4;94mhttps://galaxy.ansible.com/docs/contributing/creating_role.html#role-names[0m

As an alternative, you can add [32m'role-name'[0m to either skip_list or warn_list.

[34mINFO    [0m Using [35m/home/rpot/.cache/ansible-lint/9c86ea/roles/[0m[95mvector-role[0m symlink to current repository in order to enable Ansible to find the role using its expected full name.
[34mINFO    [0m Added [33mANSIBLE_ROLES_PATH[0m=~[35m/.ansible/[0m[95mroles[0m:[35m/usr/share/ansible/[0m[95mroles[0m:[35m/etc/ansible/[0m[95mroles[0m:[35m/home/rpot/.cache/ansible-lint/9c86ea/[0m[95mroles[0m
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdependency[0m
[31mWARNING [0m Skipping, missing the requirements file.
[31mWARNING [0m Skipping, missing the requirements file.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdestroy[0m
[34mINFO    [0m Sanity checks: [32m'docker'[0m

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) deletion to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).[0m
[32mok: [localhost] => (item=centos_7)[0m

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=2   [0m [33mchanged=1   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mcreate[0m

PLAY [Create] ******************************************************************

TASK [Log into a Docker registry] **********************************************
[36mskipping: [localhost] => (item=None) [0m
[36mskipping: [localhost][0m

TASK [Check presence of custom Dockerfiles] ************************************
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Create Dockerfiles from image names] *************************************
[33mchanged: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Discover local Docker images] ********************************************
[32mok: [localhost] => (item={'diff': [], 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_7', 'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653842745.8814888-106555-64521530967136/source', 'md5sum': '872034d0702b14037969bd9009bd8e92', 'checksum': 'c33460bc2b768d364164db57197365476531c7ed', 'changed': True, 'uid': 1000, 'gid': 1000, 'owner': 'rpot', 'group': 'rpot', 'mode': '0600', 'state': 'file', 'size': 273, 'invocation': {'module_args': {'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653842745.8814888-106555-64521530967136/source', 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_7', 'mode': '0600', 'follow': False, '_original_basename': 'Dockerfile.j2', 'checksum': 'c33460bc2b768d364164db57197365476531c7ed', 'backup': False, 'force': True, 'unsafe_writes': False, 'content': None, 'validate': None, 'directory_mode': None, 'remote_src': None, 'local_follow': None, 'owner': None, 'group': None, 'seuser': None, 'serole': None, 'selevel': None, 'setype': None, 'attributes': None}}, 'failed': False, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})[0m

TASK [Build an Ansible compatible image (new)] *********************************
[32mok: [localhost] => (item=molecule_local/centos:7)[0m

TASK [Create docker network(s)] ************************************************

TASK [Determine the CMD directives] ********************************************
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Create molecule instance(s)] *********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) creation to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).[0m
[33mchanged: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '373046767671.106696', 'results_file': '/home/rpot/.ansible_async/373046767671.106696', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True}, 'ansible_loop_var': 'item'})[0m

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=7   [0m [33mchanged=3   [0m unreachable=0    failed=0    [36mskipped=2   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mconverge[0m

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
[32mok: [centos_7][0m

TASK [Include vector-role] *****************************************************

TASK [vector-role : Vector | Install] ******************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/install.yml for centos_7[0m

TASK [vector-role : Vector | Install package for CentOS] ***********************
[33mchanged: [centos_7][0m

TASK [vector-role : Vector | Install package for Ubuntu] ***********************
[36mskipping: [centos_7][0m

TASK [vector-role : Vector | Configure] ****************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/config.yml for centos_7[0m

TASK [vector-role : Vector | Configure vector] *********************************
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-106956tduoveqn/tmpj_dvlrkt/vector.yml.j2[0m
[36m@@ -0,0 +1,18 @@[0m
[32m+sinks:[0m
[32m+    to_clickhouse:[0m
[32m+        compression: gzip[0m
[32m+        database: logs[0m
[32m+        endpoint: http://127.0.0.1:8123[0m
[32m+        healthcheck: false[0m
[32m+        inputs:[0m
[32m+        - our_log[0m
[32m+        skip_unknown_fields: true[0m
[32m+        table: my_table[0m
[32m+        type: clickhouse[0m
[32m+sources:[0m
[32m+    our_log:[0m
[32m+        ignore_older_secs: 600[0m
[32m+        include:[0m
[32m+        - /var/log/**/*.log[0m
[32m+        read_from: beginning[0m
[32m+        type: file[0m

[1;35m[WARNING]: The value "0" (type int) was converted to "u'0'" (type string). If[0m
[1;35mthis does not look like what you expect, quote the entire value to ensure it[0m
[1;35mdoes not change.[0m
[33mchanged: [centos_7][0m

TASK [vector-role : Vector | Service] ******************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/service.yml for centos_7[0m

TASK [vector-role : Vector | create systemd unit] ******************************
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-106956tduoveqn/tmpe2yyay3f/vector.service.j2[0m
[36m@@ -0,0 +1,11 @@[0m
[32m+[Unit][0m
[32m+Description=Vector service[0m
[32m+After=network.target[0m
[32m+Requires=network-online.target[0m
[32m+[Service][0m
[32m+User=root[0m
[32m+Group=0[0m
[32m+ExecStart=/usr/bin/vector --config-yaml vector.yml --watch-config[0m
[32m+Restart=always[0m
[32m+[Install][0m
[32m+WantedBy=multi-user.target[0m

[33mchanged: [centos_7][0m

RUNNING HANDLER [vector-role : start_vector] ***********************************
[33mchanged: [centos_7][0m

PLAY RECAP *********************************************************************
[33mcentos_7[0m                   : [32mok=8   [0m [33mchanged=4   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mverify[0m
[34mINFO    [0m Running Ansible Verifier

PLAY [Verify] ******************************************************************

TASK [Ensure vector service is started and enabled] ****************************
[32mok: [centos_7][0m

TASK [Validate vector config file] *********************************************
[32mok: [centos_7][0m

TASK [Debug out var] ***********************************************************
[32mok: [centos_7] => {[0m
[32m    "validate_result.stdout_lines": [[0m
[32m        "√ Loaded [\"vector.yml\"]",[0m
[32m        "-----------------------",[0m
[32m        "              Validated"[0m
[32m    ][0m
[32m}[0m

PLAY RECAP *********************************************************************
[32mcentos_7[0m                   : [32mok=3   [0m changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[34mINFO    [0m Verifier completed successfully.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mcleanup[0m
[31mWARNING [0m Skipping, cleanup playbook not configured.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdestroy[0m

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) deletion to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).[0m
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=2   [0m [33mchanged=2   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m Pruning extra files from scenario ephemeral directory
py39-ansible30 installed: ansible==3.0.0,ansible-base==2.10.17,ansible-compat==2.1.0,ansible-lint==5.1.3,arrow==1.2.2,attrs==21.4.0,bcrypt==3.2.2,binaryornot==0.4.4,bracex==2.3,Cerberus==1.3.2,certifi==2022.5.18.1,cffi==1.15.0,chardet==4.0.0,charset-normalizer==2.0.12,click==8.1.3,click-help-colors==0.9.1,commonmark==0.9.1,cookiecutter==1.7.3,cryptography==37.0.2,distro==1.7.0,docker==5.0.3,enrich==1.2.7,idna==3.3,Jinja2==3.1.2,jinja2-time==0.2.0,jmespath==1.0.0,jsonschema==4.5.1,lxml==4.8.0,MarkupSafe==2.1.1,molecule==3.4.0,molecule-docker==1.1.0,packaging==21.3,paramiko==2.11.0,pathspec==0.9.0,pluggy==0.13.1,poyo==0.5.0,pycparser==2.21,Pygments==2.12.0,PyNaCl==1.5.0,pyparsing==3.0.9,pyrsistent==0.18.1,python-dateutil==2.8.2,python-slugify==6.1.2,PyYAML==5.4.1,requests==2.27.1,rich==12.4.4,ruamel.yaml==0.17.21,ruamel.yaml.clib==0.2.6,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.0.1,text-unidecode==1.3,urllib3==1.26.9,wcmatch==8.3,websocket-client==1.3.2,yamllint==1.26.3
py39-ansible30 run-test-pre: PYTHONHASHSEED='4254715060'
py39-ansible30 run-test: commands[0] | molecule test
[34mINFO    [0m default scenario test matrix: dependency, destroy, create, converge, verify, cleanup, destroy
[34mINFO    [0m Performing prerun[33m...[0m
[34mINFO    [0m Guessed [35m/home/rpot/projects/[0m[95mvector-role[0m as project root directory
[31mWARNING [0m Computed fully qualified role name of vector-role does not follow current galaxy requirements.
Please edit meta/main.yml and assure we can correctly determine full role name:

galaxy_info:
role_name: my_name  # if absent directory name hosting role is used instead
namespace: my_galaxy_namespace  # if absent, author is used instead

Namespace: [4;94mhttps://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations[0m
Role: [4;94mhttps://galaxy.ansible.com/docs/contributing/creating_role.html#role-names[0m

As an alternative, you can add [32m'role-name'[0m to either skip_list or warn_list.

[34mINFO    [0m Using [35m/home/rpot/.cache/ansible-lint/9c86ea/roles/[0m[95mvector-role[0m symlink to current repository in order to enable Ansible to find the role using its expected full name.
[34mINFO    [0m Added [33mANSIBLE_ROLES_PATH[0m=~[35m/.ansible/[0m[95mroles[0m:[35m/usr/share/ansible/[0m[95mroles[0m:[35m/etc/ansible/[0m[95mroles[0m:[35m/home/rpot/.cache/ansible-lint/9c86ea/[0m[95mroles[0m
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdependency[0m
[31mWARNING [0m Skipping, missing the requirements file.
[31mWARNING [0m Skipping, missing the requirements file.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdestroy[0m
[34mINFO    [0m Sanity checks: [32m'docker'[0m

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) deletion to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).[0m
[32mok: [localhost] => (item=centos_7)[0m

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=2   [0m [33mchanged=1   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mcreate[0m

PLAY [Create] ******************************************************************

TASK [Log into a Docker registry] **********************************************
[36mskipping: [localhost] => (item=None) [0m
[36mskipping: [localhost][0m

TASK [Check presence of custom Dockerfiles] ************************************
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Create Dockerfiles from image names] *************************************
[33mchanged: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Discover local Docker images] ********************************************
[32mok: [localhost] => (item={'diff': [], 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_7', 'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653842905.954034-109067-107559278305379/source', 'md5sum': '872034d0702b14037969bd9009bd8e92', 'checksum': 'c33460bc2b768d364164db57197365476531c7ed', 'changed': True, 'uid': 1000, 'gid': 1000, 'owner': 'rpot', 'group': 'rpot', 'mode': '0600', 'state': 'file', 'size': 273, 'invocation': {'module_args': {'src': '/home/rpot/.ansible/tmp/ansible-tmp-1653842905.954034-109067-107559278305379/source', 'dest': '/home/rpot/.cache/molecule/vector-role/default/Dockerfile_centos_7', 'mode': '0600', 'follow': False, '_original_basename': 'Dockerfile.j2', 'checksum': 'c33460bc2b768d364164db57197365476531c7ed', 'backup': False, 'force': True, 'unsafe_writes': False, 'content': None, 'validate': None, 'directory_mode': None, 'remote_src': None, 'local_follow': None, 'owner': None, 'group': None, 'seuser': None, 'serole': None, 'selevel': None, 'setype': None, 'attributes': None}}, 'failed': False, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})[0m

TASK [Build an Ansible compatible image (new)] *********************************
[32mok: [localhost] => (item=molecule_local/centos:7)[0m

TASK [Create docker network(s)] ************************************************

TASK [Determine the CMD directives] ********************************************
[32mok: [localhost] => (item={'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True})[0m

TASK [Create molecule instance(s)] *********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) creation to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).[0m
[33mchanged: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '63387190203.109209', 'results_file': '/home/rpot/.ansible_async/63387190203.109209', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'dockerfile': 'Dockerfile.j2', 'image': 'centos:7', 'name': 'centos_7', 'privileged': True}, 'ansible_loop_var': 'item'})[0m

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=7   [0m [33mchanged=3   [0m unreachable=0    failed=0    [36mskipped=2   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mconverge[0m

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
[32mok: [centos_7][0m

TASK [Include vector-role] *****************************************************

TASK [vector-role : Vector | Install] ******************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/install.yml for centos_7[0m

TASK [vector-role : Vector | Install package for CentOS] ***********************
[33mchanged: [centos_7][0m

TASK [vector-role : Vector | Install package for Ubuntu] ***********************
[36mskipping: [centos_7][0m

TASK [vector-role : Vector | Configure] ****************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/config.yml for centos_7[0m

TASK [vector-role : Vector | Configure vector] *********************************
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-1094639u_vxuzx/tmpep5tbjuu/vector.yml.j2[0m
[36m@@ -0,0 +1,18 @@[0m
[32m+sinks:[0m
[32m+    to_clickhouse:[0m
[32m+        compression: gzip[0m
[32m+        database: logs[0m
[32m+        endpoint: http://127.0.0.1:8123[0m
[32m+        healthcheck: false[0m
[32m+        inputs:[0m
[32m+        - our_log[0m
[32m+        skip_unknown_fields: true[0m
[32m+        table: my_table[0m
[32m+        type: clickhouse[0m
[32m+sources:[0m
[32m+    our_log:[0m
[32m+        ignore_older_secs: 600[0m
[32m+        include:[0m
[32m+        - /var/log/**/*.log[0m
[32m+        read_from: beginning[0m
[32m+        type: file[0m

[1;35m[WARNING]: The value "0" (type int) was converted to "u'0'" (type string). If[0m
[1;35mthis does not look like what you expect, quote the entire value to ensure it[0m
[1;35mdoes not change.[0m
[33mchanged: [centos_7][0m

TASK [vector-role : Vector | Service] ******************************************
[36mincluded: /home/rpot/projects/vector-role/tasks/service.yml for centos_7[0m

TASK [vector-role : Vector | create systemd unit] ******************************
[31m--- before[0m
[32m+++ after: /home/rpot/.ansible/tmp/ansible-local-1094639u_vxuzx/tmplphljy68/vector.service.j2[0m
[36m@@ -0,0 +1,11 @@[0m
[32m+[Unit][0m
[32m+Description=Vector service[0m
[32m+After=network.target[0m
[32m+Requires=network-online.target[0m
[32m+[Service][0m
[32m+User=root[0m
[32m+Group=0[0m
[32m+ExecStart=/usr/bin/vector --config-yaml vector.yml --watch-config[0m
[32m+Restart=always[0m
[32m+[Install][0m
[32m+WantedBy=multi-user.target[0m

[33mchanged: [centos_7][0m

RUNNING HANDLER [vector-role : start_vector] ***********************************
[33mchanged: [centos_7][0m

PLAY RECAP *********************************************************************
[33mcentos_7[0m                   : [32mok=8   [0m [33mchanged=4   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mverify[0m
[34mINFO    [0m Running Ansible Verifier

PLAY [Verify] ******************************************************************

TASK [Ensure vector service is started and enabled] ****************************
[32mok: [centos_7][0m

TASK [Validate vector config file] *********************************************
[32mok: [centos_7][0m

TASK [Debug out var] ***********************************************************
[32mok: [centos_7] => {[0m
[32m    "validate_result.stdout_lines": [[0m
[32m        "√ Loaded [\"vector.yml\"]",[0m
[32m        "-----------------------",[0m
[32m        "              Validated"[0m
[32m    ][0m
[32m}[0m

PLAY RECAP *********************************************************************
[32mcentos_7[0m                   : [32mok=3   [0m changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[34mINFO    [0m Verifier completed successfully.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mcleanup[0m
[31mWARNING [0m Skipping, cleanup playbook not configured.
[34mINFO    [0m [2;36mRunning [0m[2;32mdefault[0m[2;36m > [0m[2;32mdestroy[0m

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Wait for instance(s) deletion to complete] *******************************
[1;30mFAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).[0m
[33mchanged: [localhost] => (item=centos_7)[0m

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
[33mlocalhost[0m                  : [32mok=2   [0m [33mchanged=2   [0m unreachable=0    failed=0    [36mskipped=1   [0m rescued=0    ignored=0

[34mINFO    [0m Pruning extra files from scenario ephemeral directory
___________________________________ summary ____________________________________
  py3713-ansible210: commands succeeded
  py3713-ansible30: commands succeeded
  py39-ansible210: commands succeeded
  py39-ansible30: commands succeeded
  congratulations :)

```
</details>

## Необязательная часть

1. Проделайте схожие манипуляции для создания роли lighthouse.
2. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
3. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.
4. Выложите свои roles в репозитории. В ответ приведите ссылки.
