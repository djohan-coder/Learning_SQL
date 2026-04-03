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
