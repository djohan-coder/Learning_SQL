CREATE TABLE customers (
  customer_id  		INT PRIMARY KEY AUTO_INCREMENT,
  nama         		VARCHAR(100) NOT NULL,
  email        		VARCHAR(150) UNIQUE NOT NULL,
  kota         		VARCHAR(80),
  tanggal_daftar	DATE DEFAULT (CURRENT_DATE)
)ENGINE = InnoDB;
