CREATE TABLE orders	(
	order_id		INT PRIMARY KEY AUTO_INCREMENT,
	customer_id		INT NOT NULL,
	tanggal_order	DATETIME DEFAULT CURRENT_TIMESTAMP,
	status			ENUM ('pending', 'proses', 'selesai', 'batal'),
	total_harga		DECIMAL(12, 2),
		CONSTRAINT	fk_order_customers
			FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
)ENGINE = InnoDB;

SHOW CREATE TABLE orders;

INSERT INTO orders (Customer_id, status, total_harga)
VALUES	(1,	'Selesai',	8500000),
		(2,	'Selesai',	250000),
		(3,	'Selesai',	750000),
        (4,	'Selesai',	2800000),
        (5,	'Proses',	85000),
        (6,	'Proses',	320000),
        (7,	'Pending',	450000),
        (8,	'Pending',	380000);

# Cara Ubah status
UPDATE orders SET status = 'selesai' WHERE order_id IN (1,2,3,4);
UPDATE orders SET status = 'proses'  WHERE order_id IN (5,6);
UPDATE orders SET status = 'pending' WHERE order_id IN (7,8);

SELECT * FROM orders;

# HARI 8
# 1
SELECT
	(SELECT COUNT(*) FROM customers WHERE is_active = 1)	AS total_customer,
    (SELECT COUNT(*) FROM products WHERE  stok > 0)	AS total_product,
    
    (SELECT COUNT(*) FROM orders)	AS total_orders,
    (SELECT COUNT(*) FROM orders WHERE status = 'selesai') AS orders_completed,
    
    COALESCE((SELECT SUM(total_harga) FROM orders WHERE status = 'selesai'), 0)	AS total_revenue,
    COALESCE((SELECT AVG(total_harga) FROM orders WHERE status = 'selesai'), 0)	AS avg_total_value,
    
    COALESCE((SELECT SUM(total_harga) FROM orders WHERE status = 'selesai'), 0) /
    NULLIF((SELECT COUNT(*) FROM orders WHERE status = 'selesai'), 0)	AS revenue_per_completed_order;
    
# 2
SELECT
	status,
    COUNT(*) 		AS jumlah_order,
    SUM(total_harga)AS total_nilai,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2)	AS presentase
FROM orders
GROUP BY status
ORDER BY jumlah_order DESC;

# 3
SELECT
	c.nama,
    c.kota,
    COUNT(o.order_id)	AS jumlah_order,
    ROUND(SUM(o.total_harga), 2)	AS total_belanja,
    ROUND(AVG(o.total_harga), 2)	AS rata_rata_per_order
FROM customers AS c
INNER JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.status = 'selesai'
GROUP BY c.customer_id, c.nama, c.kota
ORDER BY total_belanja DESC
LIMIT 5;

# 4
SELECT
	p.nama_produk,
    p.kategori,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_terjual,
    COALESCE(SUM(oi.subtotal), 0) AS total_revenue,
    p.stok AS stok_tersisa,
    CASE
		WHEN p.stok = 0 THEN 'Habis'
        WHEN p.stok < 20 THEN 'Menipis'
        ELSE 'Aman'
	END AS status_stok
FROM products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.nama_produk, p.kategori, p.stok
ORDER BY total_revenue DESC;

# 5
SELECT
	p.kategori,
    COUNT(DISTINCT p.product_id) AS total_produk,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_terjual,
    COALESCE(SUM(oi.subtotal), 0) AS total_revenue,
    ROUND(AVG(p.harga), 2) AS rata_rata_harga_produk
FROM products p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
LEFT JOIN orders AS o ON oi.order_id = o.order_id AND o.status = 'selesai'
GROUP BY p.kategori
HAVING COALESCE(SUM(oi.subtotal), 0) > (
	SELECT AVG(kategori_revenue)
    FROM(
		SELECT
			p2.kategori,
            COALESCE(SUM(oi2.subtotal), 0) AS kategori_revenue
		FROM products AS p2
        LEFT JOIN order_items AS oi2 ON p2.product_id = oi2.product_id
        LEFT JOIN orders AS o2 ON oi2.order_id = o2.order_id AND o2.status = 'selesai'
	GROUP BY p2.kategori
	) AS avg_per_kategori
)ORDER BY total_revenue DESC;

# 6 
START TRANSACTION;
# Verifikasi data
SELECT nama, email, kota, tanggal_daftar
FROM customers
WHERE customer_id NOT IN (
	SELECT customer_id FROM orders
    WHERE customer_id IS NOT NULL
);

# Update status is_active dengan subquery
UPDATE customers
SET is_active = 0
WHERE customer_id NOT IN (
	SELECT customer_id FROM orders
    WHERE customer_id IS NOT NULL
);

# Verifikasi hasil
SELECT COUNT(*) AS customer_dinonaktifkan
FROM customers WHERE is_active = 0;

# Simpan perubahan jika sesuai
COMMIT;
# Jika ragu Rollback

# 7
SELECT
	c.nama,
    c.kota,
    o.order_id,
    o.tanggal_order,
    o.status,
    p.nama_produk,
    p.kategori,
    oi.quantity,
    oi.harga_satuan,
    oi.subtotal,
    CASE
		WHEN oi.subtotal > 1000000 THEN 'Transaksi besar'
        WHEN oi.subtotal >= 500000 THEN 'Transaksi normal'
        ELSE 'Transaksi kecil'
	END AS keterangan
FROM customers AS c
INNER JOIN orders AS o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products AS p ON  oi.product_id = p.product_id
ORDER BY oi.subtotal DESC;