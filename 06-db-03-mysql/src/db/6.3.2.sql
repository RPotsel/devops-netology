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