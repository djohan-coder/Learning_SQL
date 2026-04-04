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