-- 1. Триггер для автоматического обновления количества товаров в филиале при доставке
CREATE OR REPLACE FUNCTION update_department_products_on_delivery()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE cd.department_products
    SET 
        count_products = count_products + NEW.count_product,
        date_update = NOW()
    WHERE 
        department_id = NEW.department_id;
        
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_delivery
AFTER INSERT ON cd.delivery
FOR EACH ROW EXECUTE FUNCTION update_department_products_on_delivery();

-- 2. Триггер для проверки остатков товара перед продажей
CREATE OR REPLACE FUNCTION check_product_availability()
RETURNS TRIGGER AS $$
DECLARE 
    current_count INTEGER;
BEGIN
    SELECT count_products INTO current_count
    FROM cd.department_products
    WHERE department_id = (SELECT department_id FROM cd.purchase WHERE purchase_id = NEW.purchase_id);
    
    IF current_count < NEW.count_position THEN
        RAISE EXCEPTION 'Недостаточно товара: доступно % шт., запрошено % шт.', current_count, NEW.count_position;

