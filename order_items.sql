CREATE TABLE order_items (
	item_id			INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	order_id		INT NOT NULL,
	product_id		INT NOT NULL,
	quantity		INT NOT NULL DEFAULT 1,
	harga_satuan	DECIMAL(12,2) NOT NULL,
	subtotal        DECIMAL(12,2) GENERATED ALWAYS AS (quantity * harga_satuan) STORED,

		CONSTRAINT fk_order_items_orders
			FOREIGN KEY (order_id) REFERENCES orders(order_id)
			ON DELETE CASCADE
			ON UPDATE CASCADE,
    
		CONSTRAINT fk_order_items_products
			FOREIGN KEY (product_id) REFERENCES products(product_id)
			ON DELETE CASCADE
			ON UPDATE CASCADE
)ENGINE = InnoDB;

alter table order_items
MODIFY COLUMN item_id INT NOT NULL AUTO_INCREMENT;

SELECT order_id FROM orders;
SELECT product_id, nama_produk, harga FROM products;

DESCRIBE order_items;

# Menghapus seluruh data
DELETE FROM order_items;

INSERT INTO order_items (order_id, product_id, quantity, harga_satuan)
VALUES	(1,	1,	3,	8500000),
		(2, 2,	2,	250000),
        (3,	3,	2,	750000),
        (4,	4,	2,	2800000),
        (5,	5,	2,	85000),
        (6,	6,	1,	320000),
        (7,	7,	2,	450000),
        (8,	8,	1,	380000);
        
SELECT * FROM order_items;

# Ini jika kita lupa memberi quantity
UPDATE order_items SET quantity = 3 WHERE item_id = 1;

# Cek per order memiliki berapa item
SELECT order_id, COUNT(*) AS jumlah_item, SUM(subtotal) AS total
FROM order_items
GROUP BY order_id;

INSERT INTO order_items (order_id, product_id, quantity, harga_satuan)
VALUES	(1,	2,	3,	250000),
		(1, 3,	2,	750000),
        (2,	5,	2,	85000),
        (3,	6,	2,	320000),
        (4,	7,	2,	450000),
        (5,	9,	1,	280000),
        (7,	10,	2,	420000);

SELECT * FROM order_items;

# Menghitung total pembeli
SELECT COUNT(*) AS total_items FROM order_items;

