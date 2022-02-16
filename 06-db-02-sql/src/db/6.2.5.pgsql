EXPLAIN
SELECT * 
FROM clients c 
JOIN orders o ON c.order_id = o.id
ORDER BY 1;