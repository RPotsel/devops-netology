# 6.3. MySQL

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

__Ответ:__

Загрузим бэкап БД при инициализации СУБД инструкцией подключения тома `./db/test_dump.sql:/docker-entrypoint-initdb.d/init.sql:ro`, при этом в логах контейнера видно выполнение скрипта `[Note] [Entrypoint]: /usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/init.sql`

```YAML
version: '3.9'

volumes:
  data: {}
  backup: {}

services:
  mysql:
    container_name: mysql_container
    image: mysql:8
    restart: always
    environment:
      MYSQL_DATABASE: "test_db"
      MYSQL_ROOT_PASSWORD: ${ADMIN_PASSWORD:-changeme}
    ports:
      - '3306:3306'
    volumes:
      - data:/var/lib/mysql
      - ./db/test_dump.sql:/docker-entrypoint-initdb.d/init.sql:ro
      - ./db:/src:ro
      - ./db/my.cnf:/etc/mysql/my.cnf:ro
```

Выведем информацию о СУБД

```
$ docker exec -it mysql_container mysql -h localhost -u root -proot
mysql: [Warning] Using a password on the command line interface can be insecure.
...
mysql> \s
--------------
mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          8
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.28 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 59 sec
```

Выведем количество записей с `price` > 300

```
mysql> USE test_db;
Database changed
mysql> SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привилегии пользователю `test` на операции SELECT базы `test_db`.

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и **приведите в ответе к задаче**.

__Ответ:__

```SQL
-- Создание пользователя 
CREATE USER 'test'@'localhost' 
    IDENTIFIED WITH mysql_native_password BY 'test-pass'
    WITH MAX_CONNECTIONS_PER_HOUR 100
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2
    ATTRIBUTE '{"fname":"James", "lname":"Pretty"}';

-- Предоставление привилегий
GRANT SELECT ON test_db.* TO 'test'@'localhost';
FLUSH PRIVILEGES;

-- Получение данных о пользователе
SHOW GRANTS FOR 'test'@'localhost';
SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user = 'test';
```

```
mysql> \. /src/6.3.2.sql
Query OK, 0 rows affected (0.02 sec)

Query OK, 0 rows affected, 1 warning (0.02 sec)

Query OK, 0 rows affected (0.02 sec)

+---------------------------------------------------+
| Grants for test@localhost                         |
+---------------------------------------------------+
| GRANT USAGE ON *.* TO `test`@`localhost`          |
| GRANT SELECT ON `test_db`.* TO `test`@`localhost` |
+---------------------------------------------------+
2 rows in set (0.00 sec)

+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

__Ответ:__

Подсистема хранения данных, является компонентой СУБД MySQL и играет важ­ную роль в методах запроса данных. Все поддерживае­мые подсистемы хранения можно увидеть с помощью команды `SHOW ENGINES`. Для MySQL версии 8 их 9. По умолчанию используется InnoDB, которая поддерживают ACID-совместимые фиксации транзакций, от­кат и возможности аварийного восстановления для защиты пользовательских данных.

Команда `SHOW PROFILE` инструмент профилирования запросов, который позволяет оценить длительность выполнения операций отдельного запроса на СУБД.

```
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> USE test_db;
Database changed

mysql> SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'test_db';
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
1 row in set (0.00 sec)

mysql> SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)

mysql> ALTER TABLE orders ENGINE = 'MyISAM';
Query OK, 5 rows affected (0.08 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.01 sec)

mysql> ALTER TABLE orders ENGINE = 'InnoDB';
Query OK, 5 rows affected (0.10 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+-----------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                   |
+----------+------------+-----------------------------------------------------------------------------------------+
|        1 | 0.00015475 | SELECT DATABASE()                                                                       |
|        2 | 0.00161400 | show databases                                                                          |
|        3 | 0.01074225 | show tables                                                                             |
|        4 | 0.00368325 | SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'test_db' |
|        5 | 0.00041100 | SELECT COUNT(*) FROM orders WHERE price > 300                                           |
|        6 | 0.08734125 | ALTER TABLE orders ENGINE = 'MyISAM'                                                    |
|        7 | 0.00060675 | SELECT COUNT(*) FROM orders WHERE price > 300                                           |
|        8 | 0.10924025 | ALTER TABLE orders ENGINE = 'InnoDB'                                                    |
+----------+------------+-----------------------------------------------------------------------------------------+
8 rows in set, 1 warning (0.00 sec)

mysql> SHOW PROFILE FOR QUERY 5;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000085 |
| Executing hook on transaction  | 0.000007 |
| starting                       | 0.000009 |
| checking permissions           | 0.000008 |
| Opening tables                 | 0.000042 |
| init                           | 0.000008 |
| System lock                    | 0.000010 |
| optimizing                     | 0.000012 |
| statistics                     | 0.000020 |
| preparing                      | 0.000026 |
| executing                      | 0.000119 |
| end                            | 0.000011 |
| query end                      | 0.000005 |
| waiting for handler commit     | 0.000011 |
| closing tables                 | 0.000010 |
| freeing items                  | 0.000017 |
| cleaning up                    | 0.000012 |
+--------------------------------+----------+
17 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буфера с незакомиченными транзакциями 1 Мб
- Буфер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

__Ответ:__

Для настройки работы СУБД MySQL на движке InnoDB согласно ТЗ используем следующие параметры:

- `innodb_flush_log_at_trx_commit` - управляет балансом между строгим соответствием ACID для операций фиксации и более высокой производительностью. 
  - Значение по умолчанию 1 требуется для полного соответствия требованиям ACID. Журналы записываются и сбрасываются на диск при каждой фиксации транзакции.
  - При значении 0 журналы записываются и сбрасываются на диск один раз в секунду. Транзакции, журналы которых не были очищены, могут быть потеряны в результате сбоя.
  - При значении 2 журналы записываются после каждой фиксации транзакции и сбрасываются на диск один раз в секунду. Транзакции, журналы которых не были очищены, могут быть потеряны в результате сбоя.
- `innodb_file_per_table` - значения {OFF|ON}, значение по умолчанию ON, если этот параметр включен, таблицы по умолчанию создаются в табличных пространствах типа «файл на таблицу». Если этот параметр отключен, таблицы по умолчанию создаются в системном табличном пространстве. Для создания сжатой таблицы в табличном пространстве «файл на таблицу» `innodb_file_per_table` должен быть включен. После настройки параметра, можно указывать опцию `ROW_FORMAT=COMPRESSED` в команде `CREATE TABLE` или `ALTER TABLE` для сжатия таблиц.
- `innodb_compression_level` - указывает уровень сжатия от 0 до 9 (по умолчанию 6) zlib для использования для InnoDB сжатых таблиц и индексов. Более высокое значение позволяет разместить больше данных на устройстве хранения за счет увеличения нагрузки на ЦП при сжатии.
- `innodb_log_buffer_size` - размер буфера в InnoDB, используемого для записи файлов журнала на диск. По умолчанию 16 МБ. Большой буфер журнала позволяет выполнять большие транзакции без необходимости записи журнала на диск перед фиксацией транзакции.
- `innodb_buffer_pool_size` - размер буферного пула, область памяти, в которой InnoDB кэшируются данные таблицы и индекса. Значение по умолчанию - 134217728 байт (128 МБ).
- `innodb_log_file_size` - размер в байтах каждого файла журнала в группе журналов. Общий размер файлов журнала (`innodb_log_file_size* innodb_log_files_in_group`).

После запуска СУБД, системные переменные для движка InnoDB можно посмотреть командой `SHOW VARIABLES LIKE 'innodb%';`. Приведем измененный файл `my.cnf`:

```
# The MySQL  Server configuration file.

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/

innodb_flush_log_at_trx_commit = 0
innodb_file_per_table = ON
innodb_compression_level = 9
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 200M
innodb_log_file_size = 10M
```