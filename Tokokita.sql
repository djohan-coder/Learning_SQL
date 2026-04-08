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
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Budi Baru','budi@gmail.com','Bali','2026-04-03','081234567891',1),(2,'Siti Rahayu','siti@gmail.com','Bandung','2026-04-03','082345678912',1),(3,'Andi Wijaya','andi@yahoo.com','Surabaya','2026-04-03','083456789123',1),(4,'Dewi Lestari','dewi@gmail.com','Yogyakarta','2026-04-03','085678901234',1),(5,'Reza Firmansyah','reza@gmail.com','Semarang','2026-04-03','087890123456',1),(6,'Maya Putri','maya@hotmail.com','Medan','2026-04-03',NULL,1),(7,'Fajar Nugroho','fajar@gmail.com','Makassar','2026-04-03',NULL,1),(8,'Rina Susanti','rina@yahoo.com','Palembang','2026-04-03',NULL,1),(9,'Hendra Gunawan','hendra@gmail.com','Balikpapan','2026-04-03',NULL,1),(10,'Putri Anjani','putri@gmail.com','Denpasar','2026-04-03',NULL,0);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
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
  KEY `fk_order_items_orders` (`order_id`),
  KEY `fk_order_items_products` (`product_id`),
  CONSTRAINT `fk_order_items_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_products` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
  KEY `fk_order_customers` (`customer_id`),
  CONSTRAINT `fk_order_customers` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,'2026-04-04 03:04:46','selesai',8500000.00),(2,2,'2026-04-04 03:04:46','selesai',250000.00),(3,3,'2026-04-04 03:04:46','selesai',750000.00),(4,4,'2026-04-04 03:04:46','selesai',2800000.00),(5,5,'2026-04-04 03:04:46','proses',85000.00),(6,6,'2026-04-04 03:04:46','proses',320000.00),(7,7,'2026-04-04 03:04:46','pending',450000.00),(8,8,'2026-04-04 03:04:46','pending',380000.00);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-09  5:26:33
