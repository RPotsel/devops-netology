# 08.03 Использование Yandex Cloud - Роман Поцелуев

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.

__Ответ:__

Создание ВМ в Yandex Cloud выполняется [скриптами терраформа](./src/terraform/).

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.

__Ответ:__

Выполнено. Для дополнительно установлены пакеты epel-release, nginx и git.

2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.

__Ответ:__

Сайт lighthouse запущен на порту 80.

```JINJA
server {
    listen 80;
    server_name localhost;

    access_log   /var/log/nginx/{{ lighthouse_access_log_name }}.log  main;

    location / {
        root {{ lighthouse_location_dir }};
        index index.html;
    }
}
```

4. Приготовьте свой собственный inventory файл `prod.yml`.

__Ответ:__

Файл inventory формируется в скриптами терраформ в который подставляются ip адреса ВМ.

```YAML
    clickhouse:
      hosts:
        clickhouse-01:
          ansible_host: ${yandex_compute_instance.node01.network_interface.0.nat_ip_address}
          ansible_connection: ssh
          ansible_user: centos
          ansible_become_user: root
    vector:
      hosts:
        vector-01:
          ansible_host: ${yandex_compute_instance.node02.network_interface.0.nat_ip_address}
          ansible_connection: ssh
          ansible_user: centos
          ansible_become_user: root
    lighthouse:
      hosts:
        lighthouse-01:
          ansible_host: ${yandex_compute_instance.node03.network_interface.0.nat_ip_address}
          ansible_connection: ssh
          ansible_user: centos
          ansible_become_user: root
```

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

__Ответ:__

Выполнено.

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

__Ответ:__

Выполнено.

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

__Ответ:__

Выполнено.

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

__Ответ:__

Выполнено.

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

__Ответ:__

Выполнено.

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

__Ответ:__

https://github.com/RPotsel/netology-0803