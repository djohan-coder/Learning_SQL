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
