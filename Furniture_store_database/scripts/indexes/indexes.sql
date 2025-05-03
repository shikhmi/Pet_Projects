-- 1. Индекс для ускорения поиска покупок по клиенту и филиалу
CREATE INDEX idx_purchase_customer_department 
ON cd.purchase (customer_id, department_id);

-- 2. Индекс для оптимизации запросов к истории изменения цен
CREATE INDEX idx_price_change_product_date 
ON cd.price_change (product_id, price_change_date);
