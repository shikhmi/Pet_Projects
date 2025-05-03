-- 1. Список клиентов с их покупками (имя, фамилия, дата покупки, сумма)
SELECT 
    c.customer_name, 
    c.customer_surname, 
    p.purchase_date, 
    p.purchase_price
FROM cd.customer c
INNER JOIN cd.purchase p ON c.customer_id = p.customer_id
ORDER BY p.purchase_date DESC;

-- 2. Средняя цена продуктов каждого производителя (название производителя, средняя цена)
SELECT 
    m.manufacturer_name, 
    ROUND(AVG(pr.price::numeric), 2) AS avg_price
FROM cd.manufacturer m
INNER JOIN cd.product pr ON m.manufacturer_id = pr.manufacturer_id
GROUP BY m.manufacturer_name
ORDER BY avg_price DESC;

-- 3. Топ 5 самых дорогих товаров (название товара, цена, цвет)
SELECT 
    product_name, 
    price, 
    color
FROM cd.product
ORDER BY price DESC
LIMIT 5;

-- 4. История изменений цен с названием товара и производителя (оконная функция, JOIN)
SELECT 
    pc.product_id,
    p.product_name,
    m.manufacturer_name,
    pc.price AS old_price,
    pc.new_price,
    pc.price_change_date,
    RANK() OVER (PARTITION BY pc.product_id ORDER BY pc.price_change_date DESC) AS change_rank
FROM cd.price_change pc
INNER JOIN cd.product p ON pc.product_id = p.product_id
INNER JOIN cd.manufacturer m ON p.manufacturer_id = m.manufacturer_id;

-- 5. Количество товаров в каждом филиале (название филиала, количество)
SELECT 
    d.department_name, 
    SUM(dp.count_products) AS total_products
FROM cd.department d
INNER JOIN cd.department_products dp ON d.department_id = dp.department_id
GROUP BY d.department_name;

-- 6. Покупки дороже 30000 рублей (ID покупки, дата, цена, имя клиента)
SELECT 
    p.purchase_id, 
    p.purchase_date, 
    p.purchase_price, 
    c.customer_name || ' ' || c.customer_surname AS customer_fullname
FROM cd.purchase p
INNER JOIN cd.customer c ON p.customer_id = c.customer_id
WHERE p.purchase_price > 30000;

-- 7. Производители с количеством товаров больше 3 (HAVING, GROUP BY)
SELECT 
    m.manufacturer_name, 
    COUNT(*) AS product_count
FROM cd.manufacturer m
INNER JOIN cd.product p ON m.manufacturer_id = p.manufacturer_id
GROUP BY m.manufacturer_name
HAVING COUNT(*) > 3;

-- 8. Товары, которые никогда не доставлялись в филиал 'Столичный' (NOT EXISTS)
SELECT 
    p.product_name
FROM cd.product p
WHERE NOT EXISTS (
    SELECT 1
    FROM cd.delivery d
    INNER JOIN cd.department dep ON d.department_id = dep.department_id
    WHERE d.product_id = p.product_id AND dep.department_name = 'Столичный'
);

-- 9. Изменение цены с наибольшим разрывом (MAX, подзапрос)
SELECT 
    product_id, 
    (new_price - price) AS price_diff,
    price_change_date
FROM cd.price_change
ORDER BY price_diff DESC
LIMIT 1;

-- 10. Сумма покупок по месяцам (оконная функция, агрегация)
SELECT 
    EXTRACT(YEAR FROM purchase_date) AS year,
    EXTRACT(MONTH FROM purchase_date) AS month,
    SUM(purchase_price) AS total_sales,
    LAG(SUM(purchase_price)) OVER (ORDER BY EXTRACT(MONTH FROM purchase_date)) AS prev_month_sales
FROM cd.purchase
GROUP BY year, month
ORDER BY year, month;
