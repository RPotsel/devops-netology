# 6.2. SQL - Роман Поцелуев

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

__Ответ:__

```YAML
version: '3.9'

volumes:
  data: {}
  backup: {}

services:
  postgres:
    container_name: postgres_container
    image: postgres:12
    restart: always
    environment:
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "postgres"
    ports:
      - '5432:5432'
    volumes:
      - data:/var/lib/postgresql/data
      - backup:/var/lib/postgresql/backup
      - ./db/init.pgsql:/docker-entrypoint-initdb.d/init.sql
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спецификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

__Ответ:__

Можно использовать мета-команды интерактивного терминала psql или достать информацию из служебных таблиц используя SQL запросы, попробуем второй вариант.

```SQL
--Список БД
SELECT datname FROM pg_database;

--Информация о таблицах
SELECT 
    table_name, column_name, data_type, character_maximum_length, column_default, is_nullable
FROM 
    INFORMATION_SCHEMA.COLUMNS 
WHERE 
    table_name IN ('orders', 'clients')
ORDER BY 
    1,2,3,4;

--Привилегии для пользователей
SELECT
    grantee, table_catalog, table_name, privilege_type 
FROM
    INFORMATION_SCHEMA.TABLE_PRIVILEGES 
WHERE
    table_name IN ('orders', 'clients')
ORDER BY 
    1,2,3,4;
```

```
test_db-# \i ./db/6.2.2.pgsql 
  datname  
-----------
 postgres
 template1
 template0
 test_db
(4 rows)

 table_name | column_name |     data_type     | character_maximum_length |           column_default            | is_nullable 
------------+-------------+-------------------+--------------------------+-------------------------------------+-------------
 clients    | country     | character varying |                      100 |                                     | YES
 clients    | full_name   | character varying |                      100 |                                     | YES
 clients    | id          | integer           |                          | nextval('clients_id_seq'::regclass) | NO
 clients    | order_id    | integer           |                          |                                     | YES
 orders     | id          | integer           |                          | nextval('orders_id_seq'::regclass)  | NO
 orders     | name        | character varying |                      100 |                                     | YES
 orders     | price       | integer           |                          |                                     | YES
(7 rows)

      grantee      | table_catalog | table_name | privilege_type 
-------------------+---------------+------------+----------------
 test-admin-user   | test_db       | clients    | DELETE
 test-admin-user   | test_db       | clients    | INSERT
 test-admin-user   | test_db       | clients    | REFERENCES
 test-admin-user   | test_db       | clients    | SELECT
 test-admin-user   | test_db       | clients    | TRIGGER
 test-admin-user   | test_db       | clients    | TRUNCATE
 test-admin-user   | test_db       | clients    | UPDATE
 test-admin-user   | test_db       | orders     | DELETE
 test-admin-user   | test_db       | orders     | INSERT
 test-admin-user   | test_db       | orders     | REFERENCES
 test-admin-user   | test_db       | orders     | SELECT
 test-admin-user   | test_db       | orders     | TRIGGER
 test-admin-user   | test_db       | orders     | TRUNCATE
 test-admin-user   | test_db       | orders     | UPDATE
 test-simple-usesr | test_db       | clients    | DELETE
 test-simple-usesr | test_db       | clients    | INSERT
 test-simple-usesr | test_db       | clients    | SELECT
 test-simple-usesr | test_db       | clients    | UPDATE
 test-simple-usesr | test_db       | orders     | DELETE
 test-simple-usesr | test_db       | orders     | INSERT
 test-simple-usesr | test_db       | orders     | SELECT
 test-simple-usesr | test_db       | orders     | UPDATE
(22 rows)
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

__Ответ:__

Создание и заполнение таблиц было выполнено при инициализации контейнера скриптом `/docker-entrypoint-initdb.d/init.sql`, содержание которого приведено ниже.

```SQL
--Создание пользователей
CREATE USER "test-admin-user" WITH PASSWORD 'test';
CREATE USER "test-simple-usesr" WITH PASSWORD 'test';

--Создание БД
CREATE DATABASE test_db;

--Предоставление всех привилегий для БД test_db пользователю test-admin-user 
GRANT ALL PRIVILEGES ON DATABASE test_db TO "test-admin-user";

--Подключение к test_db пользователем test-admin-user
\connect test_db "test-admin-user"

--Создание таблиц
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price INTEGER
);

CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    country VARCHAR(100),
    order_id INTEGER,
    FOREIGN KEY (order_id) REFERENCES orders (id)
);

--Заполнение таблиц с учетом требований задания 4
INSERT INTO orders (id, name, price) VALUES 
(1, 'Шоколад', 10),
(2, 'Принтер', 3000),
(3, 'Книга', 500),
(4, 'Монитор', 7000),
(5, 'Гитара', 4000);
INSERT INTO clients (id, full_name, country, order_id) VALUES
(1, 'Иванов Иван Иванович', 'USA', 3),
(2, 'Петров Петр Петрович', 'Canada', 4),
(3, 'Иоганн Себастьян Бах', 'Japan', 5),
(4, 'Ронни Джеймс Дио', 'Russia', 1),
(5, 'Ritchie Blackmore', 'Russia', 2);

--Предоставление привилегий пользователю test-simple-usesr
GRANT SELECT, INSERT, UPDATE, DELETE ON orders, clients TO "test-simple-usesr";
```

Проверим количество записей для каждой таблицы:

```SQL
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM clients;
```
```
test_db-# \i ./db/6.2.3.pgsql 
 count 
-------
     5
(1 row)

 count 
-------
     5
(1 row)
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказка - используйте директиву `UPDATE`.

__Ответ:__

Данные о заказах были заполнены при инициализации контейнера, поэтому приведем пример заполнения и вывод объединения таблиц.

```SQL
--Добавление заказа
UPDATE clients c
SET order_id = o.id 
FROM orders o 
WHERE c.full_name = 'Иванов Иван Иванович' AND o.name = 'Книга';

--Вывод пользователей и их заказов
SELECT * 
FROM clients c 
JOIN orders o ON c.order_id = o.id
ORDER BY 1;
```

```
test_db-# \i ./db/6.2.4.pgsql 
UPDATE 1
 id |      full_name       | country | order_id | id |  name   | price 
----+----------------------+---------+----------+----+---------+-------
  1 | Иванов Иван Иванович | USA     |        3 |  3 | Книга   |   500
  2 | Петров Петр Петрович | Canada  |        4 |  4 | Монитор |  7000
  3 | Иоганн Себастьян Бах | Japan   |        5 |  5 | Гитара  |  4000
  4 | Ронни Джеймс Дио     | Russia  |        1 |  1 | Шоколад |    10
  5 | Ritchie Blackmore    | Russia  |        2 |  2 | Принтер |  3000
(5 rows)
```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

__Ответ:__

```
test_db-# \i ./db/6.2.5.pgsql 
                                  QUERY PLAN                                   
-------------------------------------------------------------------------------
 Sort  (cost=35.66..36.08 rows=170 width=670)
   Sort Key: c.id
   ->  Hash Join  (cost=17.20..29.36 rows=170 width=670)
         Hash Cond: (c.order_id = o.id)
         ->  Seq Scan on clients c  (cost=0.00..11.70 rows=170 width=444)
         ->  Hash  (cost=13.20..13.20 rows=320 width=226)
               ->  Seq Scan on orders o  (cost=0.00..13.20 rows=320 width=226)
(7 rows)
```

EXPLAIN отображает план запроса и предполагаемую стоимость запроса, но не выполняет сам запрос. Postgres делает предположения на основе статистики, которую собирает периодическии выполняя analyze запросы на выборку данных из служебных таблиц.

В нашем случае план имеет 5 узлов, попробуем их объяснить:

- `Seq Scan on orders o` - субоперация `Hash`, последовательное, блок за блоком, чтение данных из таблицы `orders`. При этом `cost` 0.00 - затраты на получение первой строки, 13.20 затраты на получение всех строк. `rows` - приблизительное количество возвращаемых строк при выполнении операции `Seq Scan`. `width` - средний размер одной строки в байтах.
- `Hash` - субоперация `Hash Join`, создает в памяти (или на диске – в зависимости от размера) хэш/ассоциативный массив/словарь со строками из источника, хэшированными с помощью того, что используется для объединения данных (в нашем случае это столбец `id` в `orders`).
- `Seq Scan on clients c` - субоперация `Hash Join`, чтение данных из таблицы `clients`.
- `Hash Join` - используется для объединения двух наборов записей.
  - Проверяет, есть ли ключ `join` (c.order_id в данном случае) в хэше, возвращенном операцией `Hash`.
  - Если нет, данная строка из субоперации игнорируется (не будет возвращена).
  - Если ключ существует, `Hash Join` берет строки из хэша и, основываясь на этой строке, с одной стороны, и всех строках хэша, с другой стороны, генерирует вывод строк.
- `Sort` - самая дорогая операция, сортировка выбранных строк.


## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

__Ответ:__

Для сохранения и восстановления отдельной БД воспользуемся утилитами `pg_dump` и `pg_restore`.

```bash
$ docker exec postgres_container bash -c 'pg_dump postgresql://postgres:postgres@localhost/test_db -Ft -f /var/lib/postgresql/backup/test_db.tar'
$ docker-compose stop
[+] Running 1/1
 ⠿ Container postgres_container  Stopped

$ docker run --name pg-docker --rm -d -v src_backup:/var/lib/postgresql/backup -p 5400:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -d postgres:12
f04b12f2cb812a768eef20f1719abb4af3debd00d129cbbe6650dba60e4d1e98

$ docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                     PORTS                                       NAMES
f04b12f2cb81   postgres:12   "docker-entrypoint.s…"   32 seconds ago   Up 30 seconds              0.0.0.0:5400->5432/tcp, :::5400->5432/tcp   pg-docker
f79a6a26908a   postgres:12   "docker-entrypoint.s…"   24 hours ago     Exited (0) 6 minutes ago                                               postgres_container

$ psql postgresql://postgres:postgres@localhost:5400
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgres=# CREATE DATABASE test_db;
CREATE DATABASE
postgres=# CREATE USER "test-admin-user";
CREATE ROLE
postgres=# CREATE USER "test-simple-usesr";
CREATE ROLE
postgres=# \q

$ docker exec pg-docker bash -c 'PGPASSWORD=postgres pg_restore -U postgres -Ft -c -d test_db /var/lib/postgresql/backup/test_db.tar'

$ psql postgresql://postgres:postgres@localhost:5400
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgres=# \c test_db 
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 12.10 (Debian 12.10-1.pgdg110+1))
You are now connected to database "test_db" as user "postgres".
test_db=# \i ./db/6.2.4.pgsql 
UPDATE 1
 id |      full_name       | country | order_id | id |  name   | price 
----+----------------------+---------+----------+----+---------+-------
  1 | Иванов Иван Иванович | USA     |        3 |  3 | Книга   |   500
  2 | Петров Петр Петрович | Canada  |        4 |  4 | Монитор |  7000
  3 | Иоганн Себастьян Бах | Japan   |        5 |  5 | Гитара  |  4000
  4 | Ронни Джеймс Дио     | Russia  |        1 |  1 | Шоколад |    10
  5 | Ritchie Blackmore    | Russia  |        2 |  2 | Принтер |  3000
(5 rows)
```