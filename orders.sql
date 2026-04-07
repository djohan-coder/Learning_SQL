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


	
