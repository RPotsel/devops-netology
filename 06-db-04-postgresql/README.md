# 6.4. PostgreSQL

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

__Ответ:__

```
  $ docker exec -it postgres_container psql postgresql://postgres:postgres@localhost
psql (13.6 (Debian 13.6-1.pgdg110+1))
Type "help" for help.
...
postgres=# /?
General
  \q                     quit psql

Informational
  (options: S = show system objects, + = additional detail)
  \d[S+]  NAME           describe table, view, sequence, or index
  \dt[S+] [PATTERN]      list tables
  \l[+]   [PATTERN]      list databases

Connection
  \c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                         connect to new database (currently "postgres")
...
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

__Ответ:__

```
  $ docker exec -it postgres_container psql postgresql://postgres:postgres@localhost

postgres=# CREATE DATABASE test_database;
CREATE DATABASE
postgres=# \q

  $ docker exec -it postgres_container psql postgresql://postgres:postgres@localhost/test_database -f /src/test_dump.sql
...
  $ docker exec -it postgres_container psql postgresql://postgres:postgres@localhost/test_database

test_database=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner   
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)

test_database=# \ds
              List of relations
 Schema |     Name      |   Type   |  Owner   
--------+---------------+----------+----------
 public | orders_id_seq | sequence | postgres
(1 row)

test_database=# ANALYZE VERBOSE public.orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
test_database=# SELECT attname, avg_width FROM pg_stats WHERE tablename = 'orders' ORDER BY avg_width DESC LIMIT 1;
 attname | avg_width 
---------+-----------
 title   |        16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

__Ответ:__

Разбивку можно выполнить с помощью приведенных ниже команд.

```SQL
-- Переименование таблицы orders
ALTER TABLE public.orders RENAME TO orders_old;

-- Создание новой таблицы orders с партиционированием
CREATE TABLE public.orders (
    LIKE public.orders_old
) PARTITION BY RANGE(price);

-- Создание партиций
CREATE TABLE public.orders_1 
PARTITION OF public.orders 
FOR VALUES FROM (0) TO (499);

CREATE TABLE public.orders_2 
PARTITION OF public.orders 
FOR VALUES FROM (499) TO (999999999);

-- Перенос данных
INSERT INTO public.orders (id, title, price) 
SELECT * FROM public.orders_old;

-- Привязка SEQUENCE
ALTER TABLE public.orders_old ALTER id DROP DEFAULT;
ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;

-- Удаление таблицы orders_old
DROP TABLE public.orders_old;
```

Вывод информации о таблице после выполнения скрипта по разбиению таблицы.

```
test_database=# \d orders
                Partitioned table "public.orders"
 Column |         Type          | Collation | Nullable | Default 
--------+-----------------------+-----------+----------+---------
 id     | integer               |           | not null | 
 title  | character varying(80) |           | not null | 
 price  | integer               |           |          | 
Partition key: RANGE (price)
Number of partitions: 2 (Use \d+ to list them.)
```

При проектировании таблиц нужно учитывать рост их объема в процессе эксплуатации программного продукта, и при создании больших таблиц разбивать их на на партиции с ключом, при использовании которого записи попадали в партиции в равных долях.

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

__Ответ:__

```
$ docker exec postgres_container pg_dump postgresql://postgres:postgres@localhost/test_database -f /src/test_dump_6.4.4.sql
```

Для уникальности столбца `title` для таблиц `test_database` лучше добавить свойство `UNIQUE`, чем использовать `PRIMARY KEY`.

```SQL
title character varying(80) NOT NULL UNIQUE,
```