# Самоконтроль выполнения задания

1. Где расположен файл с `some_fact` из второго пункта задания?

__Ответ:__

```BASH
$ cat group_vars/all/examp.yml
---
  some_fact: "all default fact"
```

2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

__Ответ:__

```BASH
ansible-playbook site.yml -i inventory/test.yml
```

3. Какой командой можно зашифровать файл?

__Ответ:__

```BASH
ansible-vault encrypt group_vars/{deb,el}/*
```

4. Какой командой можно расшифровать файл?

__Ответ:__

```BASH
ansible-vault decrypt group_vars/{deb,el}/*
```

5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

__Ответ:__

```BASH
ansible-vault view group_vars/{deb,el}/*
```

6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

__Ответ:__

```BASH
ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
```

7. Как называется модуль подключения к host на windows?

__Ответ:__

[winrm](https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html) и [ansible.builtin.psrp](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/psrp_connection.html)

8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

__Ответ:__

```BASH
ansible-doc -t connection ssh
```

9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

__Ответ:__

```BASH
[remote_user](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ssh_connection.html#parameter-remote_user)
```
