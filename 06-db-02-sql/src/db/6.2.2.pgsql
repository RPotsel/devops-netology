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