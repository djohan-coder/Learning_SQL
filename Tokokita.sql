-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: tokokita
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `tabel_name` varchar(50) NOT NULL,
  `operasi` varchar(20) NOT NULL,
  `record_id` int NOT NULL,
  `data_sebelum` json DEFAULT NULL,
  `data_sesudah` json DEFAULT NULL,
  `waktu` datetime DEFAULT CURRENT_TIMESTAMP,
  `user_db` varchar(100) DEFAULT NULL,
  `ip_info` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_audit_insert_orders` BEFORE INSERT ON `audit_log` FOR EACH ROW BEGIN
	IF NEW.user_db IS NULL THEN
        SET NEW.user_db = SUBSTRING_INDEX(USER(), '@', 1);
    END IF;
    IF NEW.ip_info IS NULL THEN
        SET NEW.ip_info = SUBSTRING_INDEX(USER(), '@', -1);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `kota` varchar(80) DEFAULT NULL,
  `tanggal_daftar` date DEFAULT (curdate()),
  `no_telepon` varchar(20) DEFAULT NULL,
  `is_active` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_customers_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Budi Baru','budi@gmail.com','Bali','2026-04-03','081234567891',1),(2,'Siti Rahayu','siti@gmail.com','Bandung','2026-04-03','082345678912',1),(3,'Andi Wijaya','andi@yahoo.com','Surabaya','2026-04-03','083456789123',1),(4,'Dewi Lestari','dewi@gmail.com','Yogyakarta','2026-04-03','085678901234',1),(5,'Reza Firmansyah','reza@gmail.com','Semarang','2026-04-03','087890123456',1),(6,'Maya Putri','maya@hotmail.com','Medan','2026-04-03',NULL,1),(7,'Fajar Nugroho','fajar@gmail.com','Makassar','2026-04-03',NULL,1),(8,'Rina Susanti','rina@yahoo.com','Palembang','2026-04-03',NULL,1),(9,'Hendra Gunawan','hendra@gmail.com','Balikpapan','2026-04-03',NULL,0),(10,'Putri Anjani','putri@gmail.com','Denpasar','2026-04-03',NULL,0);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_soft_delete_customer` BEFORE DELETE ON `customers` FOR EACH ROW BEGIN
	-- 1. Ubah status jadi tidak aktif(soft delete)
    UPDATE customers SET is_active = 0 WHERE customer_id = OLD.customer_id;
    
    -- 2. Batalkan proses DELETE asli & kirim pesan ke  client/aplikasi
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE dibatalkan. Customer telah di-soft delete (is_active = 0). Gunakan UPDATE untuk perubahan status.';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `log_aktivitas`
--

DROP TABLE IF EXISTS `log_aktivitas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_aktivitas` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `tabel_name` varchar(50) NOT NULL,
  `aksi` varchar(10) NOT NULL,
  `data_lama` text,
  `data_baru` text,
  `waktu` datetime DEFAULT CURRENT_TIMESTAMP,
  `user_db` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_aktivitas`
--

LOCK TABLES `log_aktivitas` WRITE;
/*!40000 ALTER TABLE `log_aktivitas` DISABLE KEYS */;
INSERT INTO `log_aktivitas` VALUES (1,'orders','INSERT',NULL,'order_id:13 | customer_id:2 | status:pending | total_harga:1250000.00','2026-04-20 02:54:02','root@localhost');
/*!40000 ALTER TABLE `log_aktivitas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `harga_satuan` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) GENERATED ALWAYS AS ((`quantity` * `harga_satuan`)) STORED,
  PRIMARY KEY (`item_id`),
  KEY `fk_order_items_products` (`product_id`),
  KEY `idx_oi_order_prod` (`order_id`,`product_id`),
  CONSTRAINT `fk_order_items_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_products` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` (`item_id`, `order_id`, `product_id`, `quantity`, `harga_satuan`) VALUES (9,1,1,3,8500000.00),(10,2,2,2,250000.00),(11,3,3,2,750000.00),(12,4,4,2,2800000.00),(13,5,5,2,85000.00),(14,6,6,1,320000.00),(15,7,7,2,450000.00),(17,1,2,3,250000.00),(18,1,3,2,750000.00),(19,2,5,2,85000.00),(20,3,6,2,320000.00),(21,4,7,2,450000.00),(22,5,9,1,280000.00),(23,7,10,2,420000.00);
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `tanggal_order` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','proses','selesai','batal') DEFAULT NULL,
  `total_harga` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `idx_orders_date_status_revenue` (`tanggal_order`,`status`,`total_harga`),
  KEY `idx_orders_status_date` (`status`,`tanggal_order`,`customer_id`),
  KEY `idx_orders_cust_date` (`customer_id`,`tanggal_order`,`status`),
  CONSTRAINT `fk_order_customers` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,'2026-04-04 03:04:46','selesai',8500000.00),(2,2,'2026-04-04 03:04:46','selesai',250000.00),(3,3,'2026-04-04 03:04:46','selesai',750000.00),(4,4,'2026-04-04 03:04:46','selesai',2800000.00),(5,5,'2026-04-04 03:04:46','proses',85000.00),(6,6,'2026-04-04 03:04:46','proses',320000.00),(7,7,'2026-04-04 03:04:46','pending',450000.00),(8,8,'2026-04-04 03:04:46','pending',380000.00),(13,2,'2026-04-20 02:54:02','pending',1250000.00),(15,1,'2026-04-24 03:06:31','pending',500000.00),(16,1,'2026-04-24 03:11:25','pending',500000.00),(17,1,'2026-04-24 03:17:32','pending',500000.00),(18,1,'2026-04-24 03:20:06','pending',500000.00);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_audit_update_orders` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
	-- Gunakan <=> untuk safe NULL comparison
    IF NOT (OLD.status <=> NEW.status) THEN
		INSERT INTO audit_log (table_name, operasi, record_id, data_sebelum, data_sesudah, ip_info)
		VALUES (
			'orders',
			'UPDATE STATUS',
			NEW.order_id,
			JSON_OBJECT('status_lama', OLD.status),
			JSON_OBJECT('status_baru', NEW.status, 'waktu_update', NOW()),
			SUBSTRING_INDEX(USER(), '@', -1)
		);
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `nama_produk` varchar(100) NOT NULL,
  `kategori` varchar(100) DEFAULT NULL,
  `harga` decimal(10,2) NOT NULL,
  `stok` int DEFAULT '0',
  PRIMARY KEY (`product_id`),
  CONSTRAINT `products_chk_1` CHECK ((`harga` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Laptop Asus VivoBook','Elektronik',8500000.00,12),(2,'Mouse Wireless Logitech','Elektronik',250000.00,45),(3,'Keyboard Mechanical','Elektronik',750000.00,26),(4,'Monitor 24 inch','Elektronik',2800000.00,18),(5,'Kaos Polos Cotton','Fashion',97750.00,96),(6,'Celana Jeans Slim','Fashion',368000.00,57),(7,'Sepatu Sneakers','Fashion',517500.00,36),(8,'Blender Philips','Rumah Tangga',380000.00,24),(9,'Rice Cooker Miyako','Rumah Tangga',280000.00,34),(10,'Dispenser Galon','Rumah Tangga',420000.00,18);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_validate_lag_products` BEFORE UPDATE ON `products` FOR EACH ROW BEGIN
	-- Deklarasi variabel harus di paling awal blok BEGIN ... END
    DECLARE err_msg VARCHAR(255);
    
	-- validasi 1: cegah stok negatif
    IF NEW.stok < 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Gagal Update: Stok produk tidak boleh bernilai negatif!';
	END IF;
    
	-- validasi 2: cegah penurunan harga > 50%
    IF NEW.harga < (OLD.harga * 0.5) THEN
		-- simpan pesan dinamis ke variabel
        SET err_msg = CONCAT('Gagal Update: Penurunan harga maksimal 50% dari harga lama (',
							OLD.harga, '). Minimal harga baru: ', ROUND(OLD.harga * 0.5, 2));
                            
		-- baru panggil variabel di SIGNAL
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = err_msg;
	END IF;
    
    -- logging: catat hanya jika harga benar-benar berubah
    -- Gunakan <=> untuk aman jika kolom harga boleh NULL
    IF NOT(NEW.harga <=> OLD.harga) THEN
		INSERT INTO log_aktivitas (tabel_name, aksi, data_lama, data_baru, waktu, user_db)
        VALUES (
			'products',
            'UPDATE',
            CONCAT('product_id:', OLD.product_id, ' | harga_lama:', OLD.harga),
            CONCAT('product_id:', NEW.product_id, ' | harga_baru:', NEW.harga),
            NOW(),
            USER()
		);
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_monitor_stok_rendah` AFTER UPDATE ON `products` FOR EACH ROW BEGIN
    -- Hanya trigger saat stok BERUBAH dari >=20 menjadi <20
    IF NEW.stok < 20 AND OLD.stok >= 20 THEN
        INSERT INTO stok_alert (product_id, stok_sebelum, stok_sesudah, status_alert)
        VALUES (NEW.product_id, OLD.stok, NEW.stok, 'BELUM DITINDAK');
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_audit_update_products` AFTER UPDATE ON `products` FOR EACH ROW BEGIN
    IF NOT (OLD.harga <=> NEW.harga) OR NOT (OLD.stok <=> NEW.stok) THEN
        INSERT INTO audit_log (table_name, operasi, record_id, data_sebelum, data_sesudah, ip_info)
        VALUES (
            'products',
            'UPDATE_PRICE_STOCK',
            NEW.product_id,
            JSON_OBJECT('harga_lama', OLD.harga, 'stok_lama', OLD.stok),
            JSON_OBJECT('harga_baru', NEW.harga, 'stok_baru', NEW.stok, 'waktu_update', NOW()),
            SUBSTRING_INDEX(USER(), '@', -1)
        );
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `vw_kinerja_customer`
--

DROP TABLE IF EXISTS `vw_kinerja_customer`;
/*!50001 DROP VIEW IF EXISTS `vw_kinerja_customer`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_kinerja_customer` AS SELECT 
 1 AS `customer_id`,
 1 AS `nama`,
 1 AS `kota`,
 1 AS `recency`,
 1 AS `frequency`,
 1 AS `monetary`,
 1 AS `segmen_rfm`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_kinerja_produk`
--

DROP TABLE IF EXISTS `vw_kinerja_produk`;
/*!50001 DROP VIEW IF EXISTS `vw_kinerja_produk`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_kinerja_produk` AS SELECT 
 1 AS `product_id`,
 1 AS `nama_produk`,
 1 AS `kategori`,
 1 AS `total_qty_terjual`,
 1 AS `total_revenue`,
 1 AS `ranking_per_kategori`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_order_lengkap`
--

DROP TABLE IF EXISTS `vw_order_lengkap`;
/*!50001 DROP VIEW IF EXISTS `vw_order_lengkap`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_order_lengkap` AS SELECT 
 1 AS `order_id`,
 1 AS `tanggal_order`,
 1 AS `status`,
 1 AS `total_order`,
 1 AS `nama_customer`,
 1 AS `kota`,
 1 AS `nama_produk`,
 1 AS `kategori`,
 1 AS `quantity`,
 1 AS `harga_satuan`,
 1 AS `subtotal_item`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_produk_performa`
--

DROP TABLE IF EXISTS `vw_produk_performa`;
/*!50001 DROP VIEW IF EXISTS `vw_produk_performa`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_produk_performa` AS SELECT 
 1 AS `nama_produk`,
 1 AS `kategori`,
 1 AS `total_quantity_terjual`,
 1 AS `total_revenue`,
 1 AS `stok_tersisa`,
 1 AS `status_stok`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_summary_customer`
--

DROP TABLE IF EXISTS `vw_summary_customer`;
/*!50001 DROP VIEW IF EXISTS `vw_summary_customer`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_summary_customer` AS SELECT 
 1 AS `nama`,
 1 AS `kota`,
 1 AS `jumlah_order`,
 1 AS `total_belanja`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_transaksi_lengkap`
--

DROP TABLE IF EXISTS `vw_transaksi_lengkap`;
/*!50001 DROP VIEW IF EXISTS `vw_transaksi_lengkap`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_transaksi_lengkap` AS SELECT 
 1 AS `kode_order`,
 1 AS `nama_customer_kota`,
 1 AS `nama_produk_kategori`,
 1 AS `harga_rupiah`,
 1 AS `quantity`,
 1 AS `subtotal_item`,
 1 AS `tanggal_order`,
 1 AS `status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tren_bulanan`
--

DROP TABLE IF EXISTS `vw_tren_bulanan`;
/*!50001 DROP VIEW IF EXISTS `vw_tren_bulanan`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tren_bulanan` AS SELECT 
 1 AS `periode`,
 1 AS `jumlah_order`,
 1 AS `total_revenue`,
 1 AS `average_order_value`,
 1 AS `revenue_bulan_lalu`,
 1 AS `pertumbuhan_persen`,
 1 AS `running_total`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_kinerja_customer`
--

/*!50001 DROP VIEW IF EXISTS `vw_kinerja_customer`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_kinerja_customer` AS select `c`.`customer_id` AS `customer_id`,`c`.`nama` AS `nama`,`c`.`kota` AS `kota`,coalesce((to_days(curdate()) - to_days(max(`o`.`tanggal_order`))),999) AS `recency`,count(`o`.`order_id`) AS `frequency`,coalesce(round(sum(`o`.`total_harga`),2),0) AS `monetary`,(case when ((coalesce((to_days(curdate()) - to_days(max(`o`.`tanggal_order`))),999) <= 30) and (count(`o`.`order_id`) >= 2)) then 'Champion' when (count(`o`.`order_id`) >= 2) then 'Loyal' when (coalesce((to_days(curdate()) - to_days(max(`o`.`tanggal_order`))),999) > 60) then 'At Risk' else 'Regular' end) AS `segmen_rfm` from (`customers` `c` left join `orders` `o` on(((`c`.`customer_id` = `o`.`customer_id`) and (`o`.`status` = 'selesai')))) group by `c`.`customer_id`,`c`.`nama`,`c`.`kota` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_kinerja_produk`
--

/*!50001 DROP VIEW IF EXISTS `vw_kinerja_produk`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_kinerja_produk` AS select `product_agg`.`product_id` AS `product_id`,`product_agg`.`nama_produk` AS `nama_produk`,`product_agg`.`kategori` AS `kategori`,`product_agg`.`total_qty_terjual` AS `total_qty_terjual`,`product_agg`.`total_revenue` AS `total_revenue`,rank() OVER (PARTITION BY `product_agg`.`kategori` ORDER BY `product_agg`.`total_revenue` desc )  AS `ranking_per_kategori` from (select `p`.`product_id` AS `product_id`,`p`.`nama_produk` AS `nama_produk`,`p`.`kategori` AS `kategori`,coalesce(sum(`oi`.`quantity`),0) AS `total_qty_terjual`,coalesce(round(sum((`oi`.`quantity` * `oi`.`harga_satuan`)),2),0) AS `total_revenue` from ((`products` `p` left join `order_items` `oi` on((`p`.`product_id` = `oi`.`product_id`))) left join `orders` `o` on(((`oi`.`order_id` = `o`.`order_id`) and (`o`.`status` = 'selesai')))) group by `p`.`product_id`,`p`.`nama_produk`,`p`.`kategori`) `product_agg` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_order_lengkap`
--

/*!50001 DROP VIEW IF EXISTS `vw_order_lengkap`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_order_lengkap` AS select `o`.`order_id` AS `order_id`,`o`.`tanggal_order` AS `tanggal_order`,`o`.`status` AS `status`,`o`.`total_harga` AS `total_order`,`c`.`nama` AS `nama_customer`,`c`.`kota` AS `kota`,`p`.`nama_produk` AS `nama_produk`,`p`.`kategori` AS `kategori`,`oi`.`quantity` AS `quantity`,`oi`.`harga_satuan` AS `harga_satuan`,round((`oi`.`quantity` * `oi`.`harga_satuan`),2) AS `subtotal_item` from (((`orders` `o` join `customers` `c` on((`o`.`customer_id` = `c`.`customer_id`))) join `order_items` `oi` on((`o`.`order_id` = `oi`.`order_id`))) join `products` `p` on((`oi`.`product_id` = `p`.`product_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_produk_performa`
--

/*!50001 DROP VIEW IF EXISTS `vw_produk_performa`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_produk_performa` AS select `p`.`nama_produk` AS `nama_produk`,`p`.`kategori` AS `kategori`,coalesce(sum(`oi`.`quantity`),0) AS `total_quantity_terjual`,coalesce(round(sum((`oi`.`quantity` * `oi`.`harga_satuan`)),2),0) AS `total_revenue`,`p`.`stok` AS `stok_tersisa`,(case when (`p`.`stok` = 0) then 'Habis' when (`p`.`stok` < 20) then 'Menipis' else 'Aman' end) AS `status_stok` from ((`products` `p` left join `order_items` `oi` on((`p`.`product_id` = `oi`.`product_id`))) left join `orders` `o` on(((`oi`.`order_id` = `o`.`order_id`) and (`o`.`status` = 'selesai')))) group by `p`.`product_id`,`p`.`nama_produk`,`p`.`kategori`,`p`.`stok` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_summary_customer`
--

/*!50001 DROP VIEW IF EXISTS `vw_summary_customer`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_summary_customer` AS select `c`.`nama` AS `nama`,`c`.`kota` AS `kota`,count(`o`.`order_id`) AS `jumlah_order`,coalesce(round(sum(`o`.`total_harga`),2),0) AS `total_belanja` from (`customers` `c` left join `orders` `o` on(((`c`.`customer_id` = `o`.`customer_id`) and (`o`.`status` = 'selesai')))) group by `c`.`customer_id`,`c`.`nama`,`c`.`kota` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_transaksi_lengkap`
--

/*!50001 DROP VIEW IF EXISTS `vw_transaksi_lengkap`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_transaksi_lengkap` AS select concat('ORD-',lpad(`o`.`order_id`,4,'0')) AS `kode_order`,concat(`c`.`nama`,' (',`c`.`kota`,')') AS `nama_customer_kota`,concat(`p`.`nama_produk`,' [',`p`.`kategori`,']') AS `nama_produk_kategori`,concat('Rp ',format(`oi`.`harga_satuan`,0)) AS `harga_rupiah`,`oi`.`quantity` AS `quantity`,round((`oi`.`quantity` * `oi`.`harga_satuan`),2) AS `subtotal_item`,`o`.`tanggal_order` AS `tanggal_order`,`o`.`status` AS `status` from (((`orders` `o` join `customers` `c` on((`o`.`customer_id` = `c`.`customer_id`))) join `order_items` `oi` on((`o`.`order_id` = `oi`.`order_id`))) join `products` `p` on((`oi`.`product_id` = `p`.`product_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tren_bulanan`
--

/*!50001 DROP VIEW IF EXISTS `vw_tren_bulanan`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tren_bulanan` AS select concat(`monthly_agg`.`tahun`,'-',lpad(`monthly_agg`.`bulan`,2,'0')) AS `periode`,`monthly_agg`.`jumlah_order` AS `jumlah_order`,`monthly_agg`.`total_revenue` AS `total_revenue`,round(`monthly_agg`.`aov`,2) AS `average_order_value`,`monthly_agg`.`revenue_bulan_lalu` AS `revenue_bulan_lalu`,(case when ((`monthly_agg`.`revenue_bulan_lalu` is null) or (`monthly_agg`.`revenue_bulan_lalu` = 0)) then NULL else round((((`monthly_agg`.`total_revenue` - `monthly_agg`.`revenue_bulan_lalu`) / `monthly_agg`.`revenue_bulan_lalu`) * 100),2) end) AS `pertumbuhan_persen`,round(`monthly_agg`.`running_total`,2) AS `running_total` from (select year(`orders`.`tanggal_order`) AS `tahun`,month(`orders`.`tanggal_order`) AS `bulan`,count(`orders`.`order_id`) AS `jumlah_order`,coalesce(sum(`orders`.`total_harga`),0) AS `total_revenue`,coalesce(avg(`orders`.`total_harga`),0) AS `aov`,lag(sum(`orders`.`total_harga`)) OVER (ORDER BY year(`orders`.`tanggal_order`),month(`orders`.`tanggal_order`) )  AS `revenue_bulan_lalu`,sum(sum(`orders`.`total_harga`)) OVER (ORDER BY year(`orders`.`tanggal_order`),month(`orders`.`tanggal_order`) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)  AS `running_total` from `orders` where (`orders`.`status` = 'selesai') group by year(`orders`.`tanggal_order`),month(`orders`.`tanggal_order`)) `monthly_agg` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-29  2:33:57
