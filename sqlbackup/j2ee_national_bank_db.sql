CREATE DATABASE  IF NOT EXISTS `j2ee_national_bank_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `j2ee_national_bank_db`;
-- MySQL dump 10.13  Distrib 8.0.28, for Win64 (x86_64)
--
-- Host: localhost    Database: j2ee_national_bank_db
-- ------------------------------------------------------
-- Server version	8.0.28

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `accountNo` varchar(255) NOT NULL,
  `balance` double NOT NULL,
  `createdDate` date DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  `activeStatus` enum('ACTIVE','BLOCKED') DEFAULT NULL,
  `thisMonthInterestSoFar` double NOT NULL,
  `yesterdayEndOfDayBalance` double NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKixadg8q1mwsfnu1syvcm2q86v` (`accountNo`),
  KEY `FKra7xoi9wtlcq07tmoxxe5jrh4` (`user_id`),
  CONSTRAINT `FKra7xoi9wtlcq07tmoxxe5jrh4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` VALUES (1,'1000000001',19880,'2025-07-06',1,'ACTIVE',0,0),(2,'1000000002',34120,'2025-07-06',1,'ACTIVE',0,0),(3,'1000000003',560,'2025-07-06',1,'BLOCKED',0,0),(7,'1000000004',500,'2025-07-09',1,'ACTIVE',0,500),(8,'1000000005',500,'2025-07-09',3,'ACTIVE',0,500),(9,'1000000006',500,'2025-07-17',5,'ACTIVE',0,0),(10,'1000000007',540,'2025-07-17',5,'ACTIVE',0,0);
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_number_sequence`
--

DROP TABLE IF EXISTS `account_number_sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_number_sequence` (
  `name` varchar(255) NOT NULL,
  `nextValue` bigint DEFAULT NULL,
  `version` bigint DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_number_sequence`
--

LOCK TABLES `account_number_sequence` WRITE;
/*!40000 ALTER TABLE `account_number_sequence` DISABLE KEYS */;
INSERT INTO `account_number_sequence` VALUES ('ACCOUNT_SEQ',1000000008,7);
/*!40000 ALTER TABLE `account_number_sequence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointment_type`
--

DROP TABLE IF EXISTS `appointment_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_type` (
  `appoinment_type_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `cost` double DEFAULT NULL,
  PRIMARY KEY (`appoinment_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_type`
--

LOCK TABLES `appointment_type` WRITE;
/*!40000 ALTER TABLE `appointment_type` DISABLE KEYS */;
INSERT INTO `appointment_type` VALUES (1,'Consultation',2000),(2,'Diagnosis',5000),(3,'Heart Surgery',10000),(4,'Limb Surgery',6000);
/*!40000 ALTER TABLE `appointment_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_schedule`
--

DROP TABLE IF EXISTS `doctor_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_schedule` (
  `schedule_id` int NOT NULL AUTO_INCREMENT,
  `doctor_id` int NOT NULL,
  `day_of_week` enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  PRIMARY KEY (`schedule_id`),
  KEY `fk_doctor_schedule_staff1_idx` (`doctor_id`),
  CONSTRAINT `fk_doctor_schedule_staff1` FOREIGN KEY (`doctor_id`) REFERENCES `staff` (`staff_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_schedule`
--

LOCK TABLES `doctor_schedule` WRITE;
/*!40000 ALTER TABLE `doctor_schedule` DISABLE KEYS */;
INSERT INTO `doctor_schedule` VALUES (1,2,'Monday','14:00:00','19:00:00'),(2,2,'Tuesday','15:00:00','20:00:00'),(3,3,'Monday','08:00:00','13:00:00'),(4,3,'Wednesday','09:00:00','14:00:00'),(5,4,'Tuesday','08:00:00','13:00:00'),(6,4,'Thursday','12:00:00','17:00:00');
/*!40000 ALTER TABLE `doctor_schedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `facilities`
--

DROP TABLE IF EXISTS `facilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facilities` (
  `facility_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `address` text NOT NULL,
  `facility_type` enum('HOSPITAL','CLINIC','PHARMACY') NOT NULL,
  PRIMARY KEY (`facility_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `facilities`
--

LOCK TABLES `facilities` WRITE;
/*!40000 ALTER TABLE `facilities` DISABLE KEYS */;
INSERT INTO `facilities` VALUES (1,'Colombo Hospital 01','No 41, Stafford Place, Colombo 01','HOSPITAL'),(2,'Colombo Pharmacy','No 32, Roots Avenue, Kollupitiya','PHARMACY'),(3,'Kaluthara Hospital','No 16, Gamagewatta, Horana','HOSPITAL'),(4,'Galle Clinic','No. 4, Sahana Lane, Karapitiya','CLINIC'),(5,'Colombo Hospital 02','No. 67, Hanuman Lane, Bamabalapitiya ','HOSPITAL');
/*!40000 ALTER TABLE `facilities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medications`
--

DROP TABLE IF EXISTS `medications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medications` (
  `medication_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `price` double DEFAULT NULL,
  PRIMARY KEY (`medication_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medications`
--

LOCK TABLES `medications` WRITE;
/*!40000 ALTER TABLE `medications` DISABLE KEYS */;
INSERT INTO `medications` VALUES (1,'Amoxalin 250',50),(2,'Amoxalin 500',10),(3,'Panadol 500',2),(4,'Paracitamol 200',100),(5,'Omeprazaloe 150',10);
/*!40000 ALTER TABLE `medications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `monthly_balance_report`
--

DROP TABLE IF EXISTS `monthly_balance_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `monthly_balance_report` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `endOfMonthBalance` double NOT NULL,
  `interestCredited` double NOT NULL,
  `recordedDate` date DEFAULT NULL,
  `whichAccount_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK6tkj3htjy6u1wpnhfc8hy41lo` (`whichAccount_id`),
  CONSTRAINT `FK6tkj3htjy6u1wpnhfc8hy41lo` FOREIGN KEY (`whichAccount_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `monthly_balance_report`
--

LOCK TABLES `monthly_balance_report` WRITE;
/*!40000 ALTER TABLE `monthly_balance_report` DISABLE KEYS */;
INSERT INTO `monthly_balance_report` VALUES (1,400,45,'2025-05-29',3),(2,10000,35,'2025-06-29',2),(3,5000,264,'2025-05-29',2),(4,4999,34,'2024-11-29',1);
/*!40000 ALTER TABLE `monthly_balance_report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `price` double DEFAULT NULL,
  `quantity` double DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scheduled_transactions`
--

DROP TABLE IF EXISTS `scheduled_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scheduled_transactions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `amount` double NOT NULL,
  `executionTime` datetime(6) NOT NULL,
  `reference` varchar(255) DEFAULT NULL,
  `destinationAccount_id` bigint DEFAULT NULL,
  `sourceAccount_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKl3pe4vjwtbco0vqvptaogl5hs` (`destinationAccount_id`),
  KEY `FKarhpjva39v4qxwjim4ic8anol` (`sourceAccount_id`),
  CONSTRAINT `FKarhpjva39v4qxwjim4ic8anol` FOREIGN KEY (`sourceAccount_id`) REFERENCES `account` (`id`),
  CONSTRAINT `FKl3pe4vjwtbco0vqvptaogl5hs` FOREIGN KEY (`destinationAccount_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scheduled_transactions`
--

LOCK TABLES `scheduled_transactions` WRITE;
/*!40000 ALTER TABLE `scheduled_transactions` DISABLE KEYS */;
INSERT INTO `scheduled_transactions` VALUES (25,10,'2025-07-17 16:01:00.000000','',2,7);
/*!40000 ALTER TABLE `scheduled_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff`
--

DROP TABLE IF EXISTS `staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff` (
  `staff_id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(250) NOT NULL,
  `nic` varchar(12) NOT NULL,
  `contact` varchar(10) NOT NULL,
  `password` varchar(20) NOT NULL,
  `role` enum('ADMIN','DOCTOR','NURSE','PHARMACIST') NOT NULL,
  `specialization` varchar(100) DEFAULT NULL,
  `facility_id` int NOT NULL,
  PRIMARY KEY (`staff_id`),
  KEY `facility_id` (`facility_id`),
  CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`facility_id`) REFERENCES `facilities` (`facility_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff`
--

LOCK TABLES `staff` WRITE;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
INSERT INTO `staff` VALUES (1,'Minindu Dias','200303003178','0770280835','pass1','ADMIN','Front Desk Administration Work of Colombo Hospital 01',1),(2,'Oshada Gamage','200403003178','0710240862','pass2','DOCTOR','ENT Surgeon',1),(3,'Susil Shantha','200503003178','0760260452','pass3','DOCTOR','Gynecologist',1),(4,'Anura Kumara','198503003178','0711234567','pass4','DOCTOR','Cardiologist',5),(5,'Kamala Perera','199003003178','0777654321','pass5','NURSE','Head Nurse',1),(6,'Nimali Silva','199203003178','0761122334','pass6','PHARMACIST','Lead Pharmacist',2);
/*!40000 ALTER TABLE `staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction`
--

DROP TABLE IF EXISTS `transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `amount` double NOT NULL,
  `reference` varchar(255) DEFAULT NULL,
  `transactionDate` datetime DEFAULT NULL,
  `type` enum('FAILED','IMMEDIATE','INTEREST','SCHEDULED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `destinationAccount_id` bigint DEFAULT NULL,
  `sourceAccount_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKtffjlhqt5wxi9hwwc9v2vs9ub` (`destinationAccount_id`),
  KEY `FK82vv0sinl3y5wsd2x84sry41h` (`sourceAccount_id`),
  CONSTRAINT `FK82vv0sinl3y5wsd2x84sry41h` FOREIGN KEY (`sourceAccount_id`) REFERENCES `account` (`id`),
  CONSTRAINT `FKtffjlhqt5wxi9hwwc9v2vs9ub` FOREIGN KEY (`destinationAccount_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction`
--

LOCK TABLES `transaction` WRITE;
/*!40000 ALTER TABLE `transaction` DISABLE KEYS */;
INSERT INTO `transaction` VALUES (17,10,'ere','2025-07-08 01:18:00','SCHEDULED',2,1),(18,10,'we','2025-07-08 09:03:34','SCHEDULED',1,2),(19,10,'','2025-07-08 09:34:59','IMMEDIATE',2,1),(20,16,'Interest','2025-07-09 00:58:19','INTEREST',1,NULL),(21,10,'CANCELLED: LOLs','2025-07-09 06:07:15','CANCELLED',2,1),(22,10,'CANCELLED: 10','2025-07-09 06:09:55','CANCELLED',3,1),(23,10,'CANCELLED: ','2025-07-16 10:13:28','CANCELLED',2,7);
/*!40000 ALTER TABLE `transaction` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contact` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `userType` enum('BANK_OFFICER','CUSTOMER','HR_DEPARTMENT') DEFAULT NULL,
  `verificationCode` varchar(255) DEFAULT NULL,
  `verifiedStatus` enum('UNVERIFIED','VERIFIED') DEFAULT NULL,
  `joinedDate` date DEFAULT NULL,
  `nic` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK6dotkott2kjsp8vw4d0m25fb7` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'0770280835','minidudias@gmail.com','Minidu','1','CUSTOMER','1','VERIFIED','2025-07-01','200303003178'),(2,'0912259692','hr@nb.com','HR Department','1','HR_DEPARTMENT',NULL,'VERIFIED','2025-07-02',NULL),(3,'0770280835','indujayawardene@gmail.com','Indu','11111q','BANK_OFFICER','579961A3','VERIFIED','2025-07-04','830273917V'),(4,'0770280835','m@m.com','Minindu 2','1','BANK_OFFICER','411836W3','VERIFIED','2025-07-09','424649517V'),(5,'0779167795','sd@outlook.com','Sandeni Dias',NULL,'CUSTOMER','FJ699NWE','UNVERIFIED','2025-07-10','200303003178'),(6,'0770280835','minidudias@outlook.com','Minindu Dias','11111q','BANK_OFFICER','JKX0YS4R','VERIFIED','2025-07-17','200303003178');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-11 12:49:31
