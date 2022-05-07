# Описание playbook

Playbook выполняет развертывание СУБД Clickhouse с созданием БД logs и роутер событий Vector.

В файле inventory/prod.yml указывается ip адрес сервера на котором будет разворачиваться БД. В файле group_vars/clickhouse/vars.yaml указывается версия требуемого ПО.

Используемые теги:

- packages - установка пакетов
- create_db - создание БД logs