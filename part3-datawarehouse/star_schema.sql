-- Dimension Tables
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL
);

CREATE TABLE dim_store (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    store_city VARCHAR(50)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- Fact Table
CREATE TABLE fact_sales (
    transaction_id VARCHAR(15) PRIMARY KEY,
    date_id INT REFERENCES dim_date(date_id),
    store_id INT REFERENCES dim_store(store_id),
    product_id INT REFERENCES dim_product(product_id),
    customer_id VARCHAR(15), -- Degenerate dimension
    units_sold INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_revenue DECIMAL(15, 2) NOT NULL
);

-- CLEANED ETL INSERTS
INSERT INTO dim_date (date_id, full_date, month, year) VALUES 
(1, '2023-08-29', 8, 2023),
(2, '2023-12-12', 12, 2023),
(3, '2023-02-05', 2, 2023),
(4, '2023-02-20', 2, 2023),
(5, '2023-01-15', 1, 2023);

INSERT INTO dim_store (store_id, store_name, store_city) VALUES 
(1, 'Chennai Anna', 'Chennai'),
(2, 'Delhi South', 'Delhi'),
(3, 'Bangalore MG', 'Bangalore'),
(4, 'Pune FC Road', 'Pune');

INSERT INTO dim_product (product_id, product_name, category) VALUES 
(1, 'Speaker', 'Electronics'),
(2, 'Tablet', 'Electronics'),
(3, 'Phone', 'Electronics'),
(4, 'Smartwatch', 'Electronics'),
(5, 'Atta 10kg', 'Groceries');

-- Fact Table Inserts (Calculating Total Revenue dynamically for the warehouse)
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_revenue) VALUES 
('TXN5000', 1, 1, 1, 'CUST045', 3, 49262.78, 147788.34),
('TXN5001', 2, 1, 2, 'CUST021', 11, 23226.12, 255487.32),
('TXN5002', 3, 1, 3, 'CUST019', 20, 48703.39, 974067.80),
('TXN5003', 4, 2, 2, 'CUST007', 14, 23226.12, 325165.68),
('TXN5004', 5, 1, 4, 'CUST004', 10, 58851.01, 588510.10);
