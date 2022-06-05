# 08.04 Создание собственных modules - Роман Поцелуев

## Подготовка к выполнению
1. Создайте пустой публичных репозиторий в любом своём проекте: `my_own_collection`
2. Скачайте репозиторий ansible: `git clone https://github.com/ansible/ansible.git` по любому удобному вам пути
3. Зайдите в директорию ansible: `cd ansible`
4. Создайте виртуальное окружение: `python3 -m venv venv`
5. Активируйте виртуальное окружение: `. venv/bin/activate`. Дальнейшие действия производятся только в виртуальном окружении
6. Установите зависимости `pip install -r requirements.txt`
7. Запустить настройку окружения `. hacking/env-setup`
8. Если все шаги прошли успешно - выйти из виртуального окружения `deactivate`
9. Ваше окружение настроено, для того чтобы запустить его, нужно находиться в директории `ansible` и выполнить конструкцию `. venv/bin/activate && . hacking/env-setup`

## Основная часть

Наша цель - написать собственный module, который мы можем использовать в своей role, через playbook. Всё это должно быть собрано в виде collection и отправлено в наш репозиторий.

1. В виртуальном окружении создать новый `my_own_module.py` файл
2. Наполнить его содержимым из [статьи](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html#creating-a-module).
3. Заполните файл в соответствии с требованиями ansible так, чтобы он выполнял основную задачу: module должен создавать текстовый файл на удалённом хосте по пути, определённом в параметре `path`, с содержимым, определённым в параметре `content`.

__Ответ:___

[Код модуля](src/my_own_module.py)

4. Проверьте module на исполняемость локально.

__Ответ:___

Код запроса playload.json:
```JSON
{
    "ANSIBLE_MODULE_ARGS": {
        "path": "./my_test_file.txt",
        "content": "Test content 1"
    }
}
```

Результат выполнения:

```BASH
(venv) $ python -m ansible.modules.my_own_module tmp/playload.json
{"changed": true, "invocation": {"module_args": {"path": "./my_test_file.txt", "content": "Test content 1"}}}

(venv) $ python -m ansible.modules.my_own_module tmp/playload.json
{"changed": false, "invocation": {"module_args": {"path": "./my_test_file.txt", "content": "Test content 1"}}}
```

5. Напишите single task playbook и используйте module в нём.
__Ответ:___

Код запроса playbook:
```YAML
---
- name: test my new module
  hosts: localhost
  tasks:
  - name: run the new module
    my_own_module:
      path: './my_test_file.txt'
      content: "Test content 1"
```

Результат выполнения:

```BASH
$ ansible-playbook tmp/testmod.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features
under development. This is a rapidly changing source of code and can become unstable at any point.
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [test my new module] **********************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************
ok: [localhost]

TASK [run the new module] **********************************************************************************************************************************************
changed: [localhost]

PLAY RECAP *************************************************************************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

(venv) rpot@rp-srv-ntlg03:~/projects/ansible$ ansible-playbook tmp/testmod.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features
under development. This is a rapidly changing source of code and can become unstable at any point.
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [test my new module] **********************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************
ok: [localhost]

TASK [run the new module] **********************************************************************************************************************************************
ok: [localhost]

PLAY RECAP *************************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

6. Проверьте через playbook на идемпотентность.

__Ответ:__

Выполнено в п.5

7. Выйдите из виртуального окружения.
8. Инициализируйте новую collection: `ansible-galaxy collection init my_own_namespace.yandex_cloud_elk`

__Ответ:__

```BASH
$ ansible-galaxy collection init my_own_collection.yc_clickhouse_stack
- Collection my_own_collection.yc_clickhouse_stack was created successfully
```

9. В данную collection перенесите свой module в соответствующую директорию.

__Ответ:__

https://github.com/RPotsel/my_own_collection/blob/main/yc_clickhouse_stack/plugins/modules/my_own_module.py

10. Single task playbook преобразуйте в single task role и перенесите в collection. У role должны быть default всех параметров module

__Ответ:__

https://github.com/RPotsel/my_own_collection/tree/main/yc_clickhouse_stack/roles/08-ansible-06

11. Создайте playbook для использования этой role.

__Ответ:__

[Каталог с кодом](./src/use_collection/)

```BASH
$ ansible-playbook playbook.yml 
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Testing collection playbook] *************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************
ok: [localhost]

TASK [my_own_collection.yc_clickhouse_stack.08-ansible-06 : test my new role] ******************************************************************************************
changed: [localhost]

PLAY RECAP *************************************************************************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

12. Заполните всю документацию по collection, выложите в свой репозиторий, поставьте тег `1.0.0` на этот коммит.

__Ответ:__

https://github.com/RPotsel/my_own_collection/releases/tag/1.0.0

13. Создайте .tar.gz этой collection: `ansible-galaxy collection build` в корневой директории collection.

__Ответ:__

```BASH
$ ansible-galaxy collection build
Created collection for my_own_collection.yc_clickhouse_stack at /home/rpot/projects/my_own_collection/yc_clickhouse_stack/my_own_collection-yc_clickhouse_stack-1.0.1.tar.gz
```

14. Создайте ещё одну директорию любого наименования, перенесите туда single task playbook и архив c collection.

__Ответ:__

```BASH
$ mv my_own_collection-yc_clickhouse_stack-1.0.1.tar.gz ~/projects/devops-netology/08-ansible-06-module/src/use_collection/
```

15. Установите collection из локального архива: `ansible-galaxy collection install <archivename>.tar.gz`

__Ответ:__

```BASH
$ cd ~/projects/devops-netology/08-ansible-06-module/src/use_collection/
$ rm -rf collections/
$ ansible-galaxy collection install my_own_collection-yc_clickhouse_stack-1.0.1.tar.gz -p ./collections
Starting galaxy collection install process
[WARNING]: The specified collections path '/home/rpot/projects/devops-netology/08-ansible-06-module/src/use_collection/collections' is not part of the configured
Ansible collections paths '/home/rpot/.ansible/collections:/usr/share/ansible/collections'. The installed collection won't be picked up in an Ansible run.
Process install dependency map
Starting collection install process
Installing 'my_own_collection.yc_clickhouse_stack:1.0.1' to '/home/rpot/projects/devops-netology/08-ansible-06-module/src/use_collection/collections/ansible_collections/my_own_collection/yc_clickhouse_stack'
my_own_collection.yc_clickhouse_stack:1.0.1 was installed successfully
```

16. Запустите playbook, убедитесь, что он работает.

__Ответ:__

```BASH
$ ansible-playbook playbook.yml 
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Testing collection playbook] *************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************
ok: [localhost]

TASK [my_own_collection.yc_clickhouse_stack.08-ansible-06 : test my new role] ******************************************************************************************
changed: [localhost]

PLAY RECAP *************************************************************************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

17. В ответ необходимо прислать ссылку на репозиторий с collection

https://github.com/RPotsel/my_own_collection/

## Необязательная часть

1. Реализуйте свой собственный модуль для создания хостов в Yandex Cloud.
2. Модуль может (и должен) иметь зависимость от `yc`, основной функционал: создание ВМ с нужным сайзингом на основе нужной ОС. Дополнительные модули по созданию кластеров Clickhouse, MySQL и прочего реализовывать не надо, достаточно простейшего создания ВМ.
3. Модуль может формировать динамическое inventory, но данная часть не является обязательной, достаточно, чтобы он делал хосты с указанной спецификацией в YAML.
4. Протестируйте модуль на идемпотентность, исполнимость. При успехе - добавьте данный модуль в свою коллекцию.
5. Измените playbook так, чтобы он умел создавать инфраструктуру под inventory, а после устанавливал весь ваш стек Observability на нужные хосты и настраивал его.
6. В итоге, ваша коллекция обязательно должна содержать: clickhouse-role(если есть своя), lighthouse-role, vector-role, два модуля: my_own_module и модуль управления Yandex Cloud хостами и playbook, который демонстрирует создание Observability стека.
