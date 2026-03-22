## Anomaly Analysis

* **Insert Anomaly:** We cannot add a new Product to the database (e.g., a new "Webcam") unless a customer actually places an order for it, because the product details only exist within an order row.
* **Update Anomaly:** If Sales Rep "Anita Desai" changes her email address, we must update multiple rows (e.g., `ORD1027`, `ORD1120`, `ORD1152` and `ORD1002`). If we miss even one row, the database will have inconsistent data.
* **Delete Anomaly:** If we delete order `ORD1114`, and it happens to be the only order ever placed for the "Pen Set", we completely lose all record of the "Pen Set" product and its unit price.

## Normalization Justification

While keeping everything in one table (like `orders_flat.csv`) might seem simpler for writing a basic `SELECT *` query, it is fundamentally flawed for a transactional (OLTP) system and is not "over-engineering." 

Using the dataset as an example, every time customer "Priya Sharma" places an order (like in `ORD1027` and `ORD1002`), we duplicate her email and city. This bloats the database size and severely degrades write performance. More importantly, it destroys data integrity. If Priya moves to Mumbai and we update her city in `ORD1027` but forget to update it in `ORD1002`, the system no longer knows where she actually lives. Normalization to 3NF ensures that every piece of non-key data depends on the key, the whole key, and nothing but the key. By separating Customers, Products, and Sales Reps into their own tables, we ensure data is written exactly once, guaranteeing absolute consistency across the entire retail platform.
