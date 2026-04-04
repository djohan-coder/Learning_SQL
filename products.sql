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