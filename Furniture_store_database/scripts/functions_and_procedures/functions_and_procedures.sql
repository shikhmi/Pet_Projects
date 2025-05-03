-- 1. Процедура: Добавление нового товара в каталог
CREATE OR REPLACE PROCEDURE cd.add_new_product(
    IN p_product_name VARCHAR(128),
    IN p_manufacturer_id INTEGER,
    IN p_type_id INTEGER,
    IN p_price INTEGER,
    IN p_color VARCHAR(128),
    IN p_weight INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO cd.product (
        product_name, 
        manufacturer_id, 
        type_id, 
        price, 
        color, 
        weight
    ) VALUES (
        p_product_name,
        p_manufacturer_id,
        p_type_id,
        p_price,
        p_color,
        p_weight
    );
END;
$$;

-- 2. Функция: Расчет общей суммы продаж по филиалу за период
CREATE OR REPLACE FUNCTION cd.get_total_sales(
    p_department_id INTEGER,
    p_start_date TIMESTAMP,
    p_end_date TIMESTAMP
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    total_sales INTEGER;
BEGIN
    SELECT SUM(purchase_price) INTO total_sales
    FROM cd.purchase
    WHERE department_id = p_department_id
      AND purchase_date BETWEEN p_start_date AND p_end_date;
    
    RETURN COALESCE(total_sales, 0);
END;
$$;

-- 3. Процедура: Обновление цены товара с записью истории изменений
CREATE OR REPLACE PROCEDURE cd.update_product_price(
    IN p_product_id INTEGER,
    IN p_new_price INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    old_price INTEGER;
BEGIN
    -- Получаем текущую цену
    SELECT price INTO old_price 
    FROM cd.product 
    WHERE product_id = p_product_id;

    -- Обновляем цену
    UPDATE cd.product 
    SET price = p_new_price
    WHERE product_id = p_product_id;

    -- Записываем изменение
    INSERT INTO cd.price_change (
        product_id, 
        price, 
        new_price, 
        price_change_date
    ) VALUES (
        p_product_id,
        old_price,
        p_new_price,
        NOW()
    );
END;
$$;
