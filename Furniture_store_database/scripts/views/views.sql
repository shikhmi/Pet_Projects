-- 1. Представление с расширенной информацией о товарах (продукт + производитель)
CREATE VIEW cd.product_details AS
SELECT 
    p.product_id,
    p.product_name,
    m.manufacturer_name,
    p.price AS current_price,
    p.color,
    p.weight,
    CASE 
        WHEN p.weight > 20 THEN 'Тяжелый'
        ELSE 'Легкий' 
    END AS weight_category
FROM cd.product p
INNER JOIN cd.manufacturer m ON p.manufacturer_id = m.manufacturer_id;

-- 2. Представление с историей цен и аналитикой изменений
CREATE VIEW cd.price_change_history AS
SELECT 
    pc.product_id,
    p.product_name,
    pc.price AS old_price,
    pc.new_price,
    pc.price_change_date,
    (pc.new_price - pc.price) AS price_difference,
    ROUND(((pc.new_price::numeric - pc.price::numeric)/pc.price::numeric * 100, 2) AS percent_change,
    LAG(pc.new_price) OVER (PARTITION BY pc.product_id ORDER BY pc.price_change_date) AS previous_price
FROM cd.price_change pc
INNER JOIN cd.product p ON pc.product_id = p.product_id;
