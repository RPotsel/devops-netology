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