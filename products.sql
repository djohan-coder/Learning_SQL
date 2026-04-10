CREATE TABLE products
(
product_id	INT AUTO_INCREMENT PRIMARY KEY,
nama_produk	VARCHAR(100) NOT NULL,
kategori	VARCHAR(100),
harga		DECIMAL(10,2) NOT NULL CHECK (harga > 0),
stok		INT DEFAULT 0
)ENGINE = InnoDB;

DESC products;
SHOW CREATE TABLE products;

INSERT INTO products (nama_produk, kategori, harga, stok)
VALUES	('Laptop Asus VivoBook',	'Elektronik',	8500000,	15),
		('Mouse Wireless Logitech',	'Elektronik',	250000,		50),
		('Keyboard Mechanical',		'Elektronik',	750000,		30),
		('Monitor 24 inch',			'Elektronik',	2800000,	20),
        ('Kaos Polos Cotton',		'Fashion',		85000,		100),
		('Celana Jeans Slim',		'Fashion',		320000,		60),
		('Sepatu Sneakers',			'Fashion',		450000,		40),
        ('Blender Philips',			'Rumah Tangga',	380000,		25),
		('Rice Cooker Miyako',		'Rumah Tangga',	280000,		35),
		('Dispenser Galon',			'Rumah Tangga',	420000,		20);
        
SELECT nama_produk, kategori, harga, stok FROM products;

DESC products;

SELECT * FROM products;

# Hapus data duplicate
DELETE FROM products
WHERE product_id IN (
    SELECT product_id FROM (
        SELECT product_id,
               ROW_NUMBER() OVER (
                   PARTITION BY nama_produk, kategori, harga, stok 
                   ORDER BY product_id
               ) as row_num
        FROM products
    ) as temp
    WHERE row_num > 1
);

# 1
SELECT nama_produk, harga, stok 
FROM products
WHERE kategori = 'Elektronik'
ORDER BY harga asc;

# 2
SELECT customer_id, nama, kota
FROM customers 
WHERE kota IN ('Jakarta', 'Bandung', 'Surabaya')
ORDER BY nama ASC;

# 3
SELECT order_id, customer_id, status, total_harga
FROM orders
WHERE status != 'batal'
	AND total_harga > 500000
ORDER BY total_harga DESC;

# 4
SELECT nama_produk, harga, stok
FROM products
WHERE harga BETWEEN 200000 AND 1000000
	AND stok > 0
    AND nama_produk LIKE "%a%"
ORDER BY harga DESC
LIMIT 3;

# 5
SELECT	item_id,
		order_id,
        quantity AS 'Jumlah_stok',
        subtotal AS 'Total_bayar'
FROM order_items
WHERE	quantity	> 1
	AND	subtotal	> 500000
ORDER BY subtotal DESC;

# 6
ALTER TABLE customers
ADD COLUMN no_telepon VARCHAR(20);
# Qeury mencari customers yang belum memiliki nomor telepon
SELECT customer_id, nama
FROM customers
WHERE no_telepon IS NULL;

# Update 5 customers dengan nomor telepon baru
UPDATE customers
SET no_telepon = CASE customer_id
	WHEN 1 THEN '081234567891'
	WHEN 2 THEN '082345678912'
	WHEN 3 THEN '083456789123'
	WHEN 4 THEN '085678901234'
	WHEN 5 THEN '087890123456'
END
WHERE customer_id IN (1, 2, 3, 4, 5);

# Verifikasi hasilnya:
SELECT customer_id, nama, no_telepon
FROM customers
WHERE no_telepon IS NOT NULL;

# HARI 6
# 1
SELECT nama_produk, harga
FROM products
WHERE harga > (SELECT AVG(harga) FROM products)
ORDER BY harga DESC;

# 2
SELECT nama, kota, tanggal_daftar
FROM customers
WHERE customer_id IN (
	SELECT customer_id
    FROM orders
    WHERE status = 'selesai'
);

# 3
SELECT nama_produk, kategori, stok,
	(SELECT AVG(stok) FROM products) AS rata_rata_produk
FROM products
WHERE stok < (SELECT AVG(stok) FROM products);

# 4
SELECT dt.nama_customer, dt.total_belanja
FROM
(	SELECT c.nama AS nama_customer, SUM(o.total_harga) AS total_belanja
	FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.nama
) AS dt
WHERE dt.total_belanja > (
	SELECT AVG(total_belanja)
    FROM (
		SELECT SUM(total_harga) AS total_belanja
        FROM orders
        GROUP BY customer_id
	) AS sub_avg
);


# 5
SELECT
	p.nama_produk, p.kategori, p.harga
FROM products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;

SELECT
	p.nama_produk, p.kategori, p.harga
FROM products AS p
WHERE product_id NOT IN (
	SELECT product_id FROM order_items
);

# Hari 7
SELECT * FROM products;
# 1
# Verifikasi sebelum update
SELECT product_id, nama_produk, kategori, harga
FROM products
WHERE kategori = 'Fashion';

# Menjalankan Update menaikan harga 15%
UPDATE products
SET harga = harga * 1.15
WHERE kategori = 'Fashion';

# Jika diminta mematikan safemode
SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;

# Verifikasi sesudah Update
SELECT Product_id, nama_produk, kategori, harga
FROM products
WHERE kategori = 'Fashion';

SELECT kota from customers;
# 2
UPDATE orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
SET o.status = 'batal'
WHERE c.kota = 'Bali'
	AND o.status = 'pending';
    
# 3
UPDATE products AS p
SET p.stok = p.stok - (
	SELECT COALESCE(SUM(oi.quantity), 0)
    FROM order_items AS oi
    WHERE oi.product_id = p.product_id
)
WHERE p.product_id IN (SELECT product_id FROM order_items);

# Cek Hasilnya
SELECT product_id, nama_produk, stok FROM products WHERE stok < 0;

# 4
# Mulai blok transaksi
START TRANSACTION;

SELECT* FROM order_items;

# Verifikasi data sebelum dihapus
SELECT * FROM order_items WHERE order_id = 8;

# Hapus item order
DELETE FROM order_items WHERE order_id = 8;

# Verifikasi data sesudah dihapus ( hasil 0 )
SELECT COUNT(*) AS sisa_item FROM order_items WHERE order_id = 8;

# Pilih commit jika sesuai, pilih rollback jika ragu atau gagal
COMMIT;

# 5
# Tambah kolom penanda status aktif/nonaktif
ALTER TABLE customers
ADD COLUMN is_active TINYINT NOT NULL DEFAULT 1;

# Hapus customer_id = 10 secara soft
UPDATE customers
SET is_active = 0
WHERE customer_id = 10;

# Query hanya menampilkan customer yang masih aktif
SELECT customer_id, nama, email, kota, is_active
FROM customers
WHERE is_active = 1
ORDER BY customer_id;

SELECT * FROM products
LIMIT 3;

# HARI 8
# 1
SELECT
	nama_produk,
    kategori,
    harga,
    ROW_NUMBER()	OVER (PARTITION BY kategori	ORDER BY harga	DESC)	AS	row_number_rank,
    RANK()			OVER (PARTITION BY kategori	ORDER BY harga	DESC)	AS	rank_val,
    DENSE_RANK()	OVER (PARTITION BY kategori ORDER BY harga	DESC)	AS	dense_rank_val
FROM products
ORDER BY kategori, harga DESC;

# 2
SELECT
	o.order_id,
    c.nama,
    o.tanggal_order,
    o.total_harga,
    SUM(o.total_harga) OVER(ORDER BY o.tanggal_order)	AS running_total
FROM orders	AS o
JOIN customers	AS c ON c.customer_id = o.customer_id;

# 3
SELECT
	order_id,
    total_harga,
    ROUND(AVG(total_harga) OVER (), 2) AS rata_rata_order,
    ROUND(total_harga - AVG(total_harga) OVER (), 2) AS selisih_dari_rata_rata,
    CASE
		WHEN total_harga > AVG(total_harga) OVER () THEN 'Di atas rata rata'
        ELSE 'Di bawah rata rata'
	END AS keterangan
FROM orders
ORDER BY total_harga DESC;

# 4
WITH order_lag AS (
	SELECT
		c.nama	AS nama_customer,
		o.order_id,
		o.tanggal_order,
		o.total_harga,
		LAG(o.total_harga, 1) OVER (
			PARTITION BY o.customer_id
			ORDER BY o.tanggal_order, o.order_id
		) AS nilai_order_sebelumnya
	FROM orders AS o
	JOIN customers AS c ON o.customer_id = c.customer_id
)
SELECT
	nama_customer,
    order_id,
    tanggal_order,
    total_harga,
    nilai_order_sebelumnya,
	ROUND(total_harga - COALESCE(nilai_order_sebelumnya, 0), 2) AS selisih
FROM order_lag
ORDER BY nama_customer, tanggal_order, order_id;

# 5
WITH total_belanja AS (
	SELECT
		c.customer_id,
        c.nama,
        COALESCE(SUM(o.total_harga), 0) AS total_belanja
	FROM customers AS c
    LEFT JOIN orders AS o ON c.customer_id = o.customer_id
		AND o.status = 'selesai'
	GROUP BY c.customer_id, nama
),
segmentasi AS (
	SELECT
		customer_id,
        nama,
        total_belanja,
        NTILE(4) OVER (ORDER BY total_belanja ASC) AS kuartil
	FROM total_belanja
)
SELECT
	customer_id,
    nama,
    total_belanja,
    kuartil,
	CASE kuartil
		WHEN 1 THEN 'Bronze'
        WHEN 2 THEN 'Silver'
        WHEN 3 THEN 'Gold'
        WHEN 4 THEN 'Platinum'
	END AS segment
FROM segmentasi
ORDER BY total_belanja DESC;
