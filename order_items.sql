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

# HARI 5

# Menghitung Total revenue per kategori produk
# 1
SELECT
	COUNT(order_id)		AS	total_transaksi,
    SUM(total_harga)	AS	total_revenue,
    AVG(total_harga)	AS	rata_rata,
    MAX(total_harga)	AS	terbesar,
    MIN(total_harga)	AS	terkecil
FROM orders;

# 2
SELECT
	status,
    COUNT(order_id)		AS jumlah_order
FROM orders
GROUP BY status
ORDER BY jumlah_order DESC;

# 3
SELECT
	c.nama,
    c.kota,
    COUNT(o.order_id)	AS	jumlah_order,
    SUM(o.total_harga)	AS	total_belanja
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.nama, c.kota
HAVING total_belanja > 500000
ORDER BY total_belanja DESC;

# 4
SELECT
	p.nama_produk,
    p.kategori,
	SUM(oi.quantity)AS total_quantity_terjual,
	SUM(oi.subtotal)AS	total_revenue
FROM order_items AS oi
INNER JOIN products	AS p ON oi.product_id = p.product_id
GROUP BY p.nama_produk, p.kategori
ORDER BY total_quantity_terjual DESC
LIMIT 5;

# 5
SELECT
	p.kategori,
    COUNT(oi.item_id)	AS total_transaksi,
    SUM(oi.subtotal)	AS	total_revenue,
    AVG(oi.subtotal)	AS	rata_rata_transaksi
FROM order_items AS oi
INNER JOIN products AS p ON oi.product_id = p.product_id
INNER JOIN orders AS o ON oi.order_id = o.order_id
WHERE o.status = 'selesai'
GROUP BY p.kategori
HAVING total_revenue > 1000000
ORDER BY total_revenue DESC;


