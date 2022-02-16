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
