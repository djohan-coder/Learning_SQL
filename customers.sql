CREATE TABLE customers (
  customer_id  		INT PRIMARY KEY AUTO_INCREMENT,
  nama         		VARCHAR(100) NOT NULL,
  email        		VARCHAR(150) UNIQUE NOT NULL,
  kota         		VARCHAR(80),
  tanggal_daftar	DATE DEFAULT (CURRENT_DATE)
)ENGINE = InnoDB;

INSERT INTO customers (nama, email, kota)
VALUES	('Budi Santoso',	'budi@gmail.com',	'Jakarta'),
		('Siti Rahayu',		'siti@gmail.com',	'Bandung'),
		('Andi Wijaya',		'andi@yahoo.com',	'Surabaya'),
		('Dewi Lestari',	'dewi@gmail.com',	'Yogyakarta'),
		('Reza Firmansyah',	'reza@gmail.com',	'Semarang'),
		('Maya Putri',		'maya@hotmail.com', 'Medan'),
		('Fajar Nugroho',	'fajar@gmail.com',	'Makassar'),
		('Rina Susanti',	'rina@yahoo.com',	'Palembang'),
		('Hendra Gunawan',	'hendra@gmail.com',	'Balikpapan'),
		('Putri Anjani',	'putri@gmail.com',	'Denpasar');
        
SELECT nama, email, kota from customers;

SELECT customer_id, nama FROM customers;

DESC customers;

INSERT INTO customers (nama, email, kota)
VALUES ('Budi Baru', 'budi@gmail.com', 'Bali') AS new_data
ON DUPLICATE KEY UPDATE
  nama = new_data.nama,
  kota = new_data.kota;
  
SELECT * FROM customers WHERE email = 'budi@gmail.com';

SELECT * FROM customers;

use Tokokita;


# HARI KE 4
# 1
SELECT
	c.nama,
    c.kota,
    o.order_id,
    o.tanggal_order,
    o.status,
    o.total_harga
FROM customers AS c
INNER JOIN orders AS o ON c.customer_id = o.customer_id
ORDER BY o.tanggal_order DESC;

# 2
SELECT
	c.nama,
    c.kota,
    COUNT(o.order_id) AS jumlah_order
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.nama, c.kota;
	
# 3
SELECT
	c.nama		AS nama_customer,
    o.order_id,
    p.nama_produk,
    oi.quantity,
    oi.subtotal
FROM customers AS c
INNER JOIN orders AS o ON c.customer_id = o.customer_id
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
INNER JOIN products AS p ON oi.product_id = p.product_id
WHERE o.status = 'selesai';

# 4
SELECT
	c.nama AS nama_customer,
    p.nama_produk,
    oi.quantity,
    oi.subtotal
FROM customers AS c
INNER JOIN orders AS o ON c.customer_id = o.customer_id
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
INNER JOIN products AS p ON oi.product_id = p.product_id
WHERE o.status = 'selesai'
	AND oi.subtotal > 1000000
ORDER BY oi.subtotal DESC;

# 5
SELECT
	p.nama_produk,
    p.kategori,
    p.harga
FROM products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;