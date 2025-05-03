CREATE SCHEMA cd;

CREATE TABLE cd.department (
    department_id SERIAL PRIMARY KEY, 
    department_name VARCHAR(128) NOT NULL
);

CREATE TABLE cd.customer (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(128) NOT NULL,
    customer_surname VARCHAR(128) NOT NULL
);

CREATE TABLE cd.purchase (
    purchase_id MONEY PRIMARY KEY,
    customer_id SERIAL,
    department_id SERIAL,
    purchase_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    purchase_price SERIAL,
        FOREIGN KEY (customer_id) REFERENCES cd.customer(customer_id),
        FOREIGN KEY (department_id) REFERENCES cd.department(department_id)
);

CREATE TABLE cd.manufacturer (
    manufacturer_id SERIAL PRIMARY KEY,
    manufacturer_name VARCHAR(128) NOT NULL
);

CREATE TABLE cd.product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(128) NOT NULL,
    manufacturer_id SERIAL,
    type_id SERIAL,
    price MONEY,
    color VARCHAR(128) NOT NULL,
    weight SERIAL,
        FOREIGN KEY (manufacturer_id) REFERENCES cd.manufacturer(manufacturer_id)
);

CREATE TABLE cd.delivery (
    delivery_id SERIAL PRIMARY KEY,
    product_id SERIAL,
    department_id SERIAL,
    delivery_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    count_product SERIAL,
        FOREIGN KEY (product_id) REFERENCES cd.product(product_id),
        FOREIGN KEY (department_id) REFERENCES cd.department(department_id)
);

CREATE TABLE cd.purchase_products (
    purchase_products_id SERIAL PRIMARY KEY,
    purchase_id SERIAL,
    count_position SERIAL,
        FOREIGN KEY (purchase_id) REFERENCES cd.purchase(purchase_id)
);

CREATE TABLE cd.price_change (
    price_change_id SERIAL PRIMARY KEY,
    product_id SERIAL,
    price MONEY,
    price_change_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    new_price MONEY,
        FOREIGN KEY (product_id) REFERENCES cd.product(product_id)
);

CREATE TABLE cd.department_products (
    department_products_id SERIAL PRIMARY KEY,
    department_id SERIAL,
    count_products SERIAL,
    date_update TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
        FOREIGN KEY (department_id) REFERENCES cd.department(department_id)
);
