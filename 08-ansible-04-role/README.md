# 8.4 Работа с Roles - Роман Поцелуев

[Playbook](./playbook/) выполняет развертывание СУБД ClickHouse, роутера событий Vector и легковесного веб-интерфейса для ClickHouse - LightHouse на ВМ.

Для создания ВМ в YC используются скрипты [terraform](./terraform/), которые создают три ВМ `clickhouse-01`, `vector-01`, `lighthouse-01` и формируют файл `inventory/prod.yml` с параметрами подключения к ним, после выполнения команды `destroy` файл удаляется.
Согласно задания созданы две роли [lighthouse-role](https://github.com/RPotsel/lighthouse-role) и [vector-role](https://github.com/RPotsel/vector-role), которые размещены в отдельных репозиториях и выполняют действия по развертыванию Vector и LightHouse. Для загрузки ролей в playbook используется файл [requirements.yml](./playbook/requirements.yml).
