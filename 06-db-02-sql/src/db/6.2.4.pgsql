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