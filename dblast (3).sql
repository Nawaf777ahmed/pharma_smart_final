-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 27 أبريل 2026 الساعة 02:48
-- إصدار الخادم: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dblast`
--

-- --------------------------------------------------------

--
-- بنية الجدول `accountingtemplatelines`
--

CREATE TABLE `accountingtemplatelines` (
  `LineId` int(11) NOT NULL,
  `TemplateId` int(11) NOT NULL,
  `IsDebit` tinyint(1) NOT NULL,
  `Role` int(11) NOT NULL,
  `Source` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `accountingtemplatelines`
--

INSERT INTO `accountingtemplatelines` (`LineId`, `TemplateId`, `IsDebit`, `Role`, `Source`) VALUES
(1, 1, 1, 0, 1),
(2, 1, 1, 1, 2),
(3, 1, 1, 2, 3),
(4, 1, 1, 6, 4),
(5, 1, 0, 4, 0),
(6, 1, 0, 7, 4),
(7, 2, 1, 4, 0),
(8, 2, 1, 7, 4),
(9, 2, 0, 0, 1),
(10, 2, 0, 1, 2),
(11, 2, 0, 2, 3),
(12, 2, 0, 6, 4),
(17, 3, 1, 7, 0),
(18, 3, 0, 0, 1),
(19, 3, 0, 1, 2),
(20, 3, 0, 3, 3),
(21, 3, 0, 8, 4),
(22, 4, 1, 0, 1),
(23, 4, 1, 1, 2),
(24, 4, 1, 3, 3),
(25, 4, 0, 7, 0);

-- --------------------------------------------------------

--
-- بنية الجدول `accountingtemplates`
--

CREATE TABLE `accountingtemplates` (
  `TemplateId` int(11) NOT NULL,
  `TemplateName` longtext DEFAULT NULL,
  `TransactionType` int(11) NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `accountingtemplates`
--

INSERT INTO `accountingtemplates` (`TemplateId`, `TemplateName`, `TransactionType`, `IsActive`) VALUES
(1, 'قالب فاتورة المبيعات القياسي', 0, 1),
(2, 'قالب مرتجع المبيعات القياسي', 1, 1),
(3, 'قيد فاتورة المشتريات القياسي', 2, 1),
(4, 'قالب مرتجع المشتريات القياسي', 3, 1);

-- --------------------------------------------------------

--
-- بنية الجدول `accountmappings`
--

CREATE TABLE `accountmappings` (
  `MappingId` int(11) NOT NULL,
  `Role` int(11) NOT NULL,
  `BranchId` int(11) DEFAULT NULL,
  `PaymentMethodId` int(11) DEFAULT NULL,
  `AccountId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `accounts`
--

CREATE TABLE `accounts` (
  `AccountID` int(11) NOT NULL,
  `AccountCode` varchar(50) NOT NULL,
  `AccountName` varchar(150) NOT NULL,
  `AccountType` varchar(50) NOT NULL,
  `BranchId` int(11) DEFAULT NULL,
  `AccountNature` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = Debit (مدين), 0 = Credit (دائن)',
  `ParentAccountID` int(11) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  `IsDeleted` tinyint(1) DEFAULT 0,
  `CreatedAt` datetime DEFAULT current_timestamp(),
  `CreatedBy` int(11) DEFAULT NULL,
  `UpdatedAt` datetime DEFAULT NULL,
  `UpdatedBy` int(11) DEFAULT NULL,
  `IsParent` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `accounts`
--

INSERT INTO `accounts` (`AccountID`, `AccountCode`, `AccountName`, `AccountType`, `BranchId`, `AccountNature`, `ParentAccountID`, `IsActive`, `IsDeleted`, `CreatedAt`, `CreatedBy`, `UpdatedAt`, `UpdatedBy`, `IsParent`) VALUES
(1, '1', 'الأصول', 'Assets', NULL, 1, NULL, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 1),
(2, '11', 'الأصول المتداولة', 'Assets', NULL, 1, 1, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 1),
(3, '12', 'الأصول غير المتداولة', 'Assets', NULL, 1, 1, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(4, '2', 'الخصوم', 'Liabilities', NULL, 0, NULL, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 1),
(5, '21', 'الخصوم المتداولة', 'Liabilities', NULL, 0, 4, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 1),
(6, '22', 'الخصوم طويلة الأجل', 'Liabilities', NULL, 0, 4, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(7, '3', 'حقوق الملكية', 'Equity', NULL, 0, NULL, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 1),
(8, '31', 'رأس المال', 'Equity', NULL, 0, 7, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(9, '32', 'المسحوبات', 'Equity', NULL, 1, 7, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(10, '33', 'الأرباح المحتجزة', 'Equity', NULL, 0, 7, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(11, '4', 'الإيرادات', 'Revenue', NULL, 0, NULL, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 1),
(12, '41', 'المبيعات', 'Revenue', NULL, 0, 11, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(13, '42', 'إيرادات أخرى', 'Revenue', NULL, 0, 11, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(14, '5', 'تكلفة المبيعات', 'Expenses', NULL, 1, NULL, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 1),
(15, '51', 'المشتريات', 'Expenses', NULL, 1, 14, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(16, '6', 'المصروفات', 'Expenses', NULL, 1, NULL, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 1),
(17, '61', 'مصروفات تشغيلية', 'Expenses', NULL, 1, 16, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(18, '62', 'مصروفات إدارية', 'Expenses', NULL, 1, 16, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(19, '63', 'مصروفات تسويقية', 'Expenses', NULL, 1, 16, 1, 0, '2026-03-14 22:35:24', NULL, NULL, NULL, 0),
(20, '111', 'مخزون الادوية ', 'Assets', NULL, 1, 2, 1, NULL, NULL, NULL, NULL, NULL, 0),
(21, '112', 'حساب البنك 1', 'Assets', NULL, 1, 2, 1, NULL, NULL, NULL, NULL, NULL, 0),
(22, '211', 'الموردين', 'Liabilities', NULL, 0, 5, 1, NULL, NULL, NULL, NULL, NULL, 1),
(23, '21101', 'القطريفي', 'Liabilities', NULL, 0, 22, 0, NULL, NULL, NULL, NULL, NULL, 0),
(24, '212', 'العملاء', 'Liabilities', NULL, 0, 5, 1, NULL, NULL, NULL, NULL, NULL, 1),
(25, '21201', 'احمد ', 'Liabilities', NULL, 0, 24, 1, NULL, NULL, NULL, NULL, NULL, 0),
(26, '21102', 'الشرق الاوسط', 'Liabilities', NULL, 0, 22, 1, NULL, NULL, NULL, NULL, NULL, 0),
(27, '113', 'الفرع  الرئسي صندوق رقم 1', 'Assets', 1, 1, 2, 1, NULL, NULL, NULL, NULL, NULL, 0),
(28, '43', 'ايراد مشتريات ', 'Revenue', 1, 0, 11, 1, NULL, NULL, NULL, NULL, NULL, 0),
(29, '44', 'ايرد مبيعات ', 'Revenue', 1, 0, 11, 1, NULL, NULL, NULL, NULL, NULL, 0),
(30, '21103', 'حساب مورد: شركة ابن سينا', 'Liabilities', NULL, 0, 22, 1, 0, '2026-03-30 01:19:57', NULL, NULL, NULL, 0),
(31, '21104', 'حساب مورد: شركة الرازي', 'Liabilities', NULL, 0, 22, 1, 0, '2026-03-30 01:19:57', NULL, NULL, NULL, 0),
(32, '21105', 'حساب مورد: مؤسسة الأدوية', 'Liabilities', NULL, 0, 22, 1, 0, '2026-03-30 01:19:57', NULL, NULL, NULL, 0),
(33, '21106', 'حساب مورد: فارماكير', 'Liabilities', NULL, 0, 22, 1, 0, '2026-03-30 01:19:57', NULL, NULL, NULL, 0),
(34, '21107', 'حساب مورد: جلوبال ميد', 'Liabilities', NULL, 0, 22, 1, 0, '2026-03-30 01:19:57', NULL, NULL, NULL, 0),
(100, '211100', 'شركة باير الطبية', 'Liabilities', NULL, 0, 22, 1, 0, '2026-03-30 01:28:18', NULL, NULL, NULL, 0),
(101, '212100', 'صيدلية النور', 'Assets', NULL, 1, 24, 1, 0, '2026-03-30 01:28:18', NULL, NULL, NULL, 0),
(102, '212101', 'ابو يمان ', 'Liabilities', NULL, 0, 24, 1, NULL, NULL, NULL, NULL, NULL, 0),
(103, '13', 'عميل: احمد', 'Assets', 1, 1, 1, 1, NULL, '2026-04-11 01:10:21', 1, NULL, NULL, 0),
(104, '211101', 'المقرمي', 'Liabilities', NULL, 0, 22, 1, NULL, NULL, NULL, NULL, NULL, 0),
(105, '211102', 'المقدشي', 'Liabilities', NULL, 0, 22, 1, NULL, NULL, NULL, NULL, NULL, 0),
(106, '11201', 'الكريمي', 'Assets', NULL, 1, 21, 1, NULL, NULL, NULL, NULL, NULL, 0),
(107, '114', 'الصناديق', 'Assets', NULL, 1, 2, 1, NULL, NULL, NULL, NULL, NULL, 0),
(108, '11401', 'صندوق الصيدليه', 'Assets', NULL, 1, 107, 1, NULL, NULL, NULL, NULL, NULL, 0),
(109, '11101', 'مخزون الصيدلية تالين فارما', 'Assets', NULL, 1, 20, 1, NULL, NULL, NULL, NULL, NULL, 0),
(110, 'SIM-S-1-9f3c', 'المورد الرئيسي للمحاكاة', 'Liabilities', 1, 0, 22, 1, NULL, '2026-04-27 01:04:33', NULL, NULL, NULL, 0),
(111, 'SIM-C-1-1', 'عميل نقدي (محاكاة)', 'Liabilities', 1, 1, 24, 1, NULL, '2026-04-27 01:04:33', NULL, NULL, NULL, 0),
(112, 'SIM-C-1-2', 'عميل تأمين طبي (محاكاة)', 'Liabilities', 1, 1, 24, 1, NULL, '2026-04-27 01:04:33', NULL, NULL, NULL, 0);

-- --------------------------------------------------------

--
-- بنية الجدول `barcodegenerator`
--

CREATE TABLE `barcodegenerator` (
  `Id` int(11) NOT NULL,
  `BranchId` int(11) NOT NULL DEFAULT 1,
  `DrugId` int(11) NOT NULL,
  `BatchNumber` varchar(50) NOT NULL,
  `ExpiryDate` date NOT NULL,
  `CurrentPrice` decimal(18,4) NOT NULL,
  `QuantityToPrint` int(11) NOT NULL DEFAULT 1,
  `GeneratedCode` varchar(255) NOT NULL COMMENT 'الكود الديناميكي المركب',
  `IsPrinted` tinyint(1) NOT NULL DEFAULT 0,
  `CreatedAt` datetime NOT NULL,
  `UserId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `branches`
--

CREATE TABLE `branches` (
  `BranchID` int(11) NOT NULL,
  `BranchCode` varchar(20) NOT NULL,
  `BranchName` varchar(150) NOT NULL,
  `Location` varchar(200) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  `DefaultCashAccountId` int(11) DEFAULT NULL COMMENT 'حساب الصندوق الافتراضي',
  `DefaultSalesAccountId` int(11) DEFAULT NULL COMMENT 'حساب إيرادات المبيعات',
  `DefaultCOGSAccountId` int(11) DEFAULT NULL COMMENT 'حساب تكلفة البضاعة المباعة',
  `DefaultInventoryAccountId` int(11) DEFAULT NULL COMMENT 'حساب مخزون الأدوية',
  `DefaultCurrencyId` int(11) DEFAULT NULL COMMENT 'العملة الافتراضية للفرع'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `branches`
--

INSERT INTO `branches` (`BranchID`, `BranchCode`, `BranchName`, `Location`, `IsActive`, `DefaultCashAccountId`, `DefaultSalesAccountId`, `DefaultCOGSAccountId`, `DefaultInventoryAccountId`, `DefaultCurrencyId`) VALUES
(1, 'BR-01', 'صيدلية تالين فارما', 'المركز الرئيسي', 1, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- بنية الجدول `branchinventory`
--

CREATE TABLE `branchinventory` (
  `BranchID` int(11) NOT NULL,
  `DrugID` int(11) NOT NULL,
  `ShelfId` int(11) DEFAULT NULL,
  `StockQuantity` int(11) NOT NULL DEFAULT 0,
  `MinimumStockLevel` int(11) NOT NULL DEFAULT 0,
  `ABCCategory` char(1) DEFAULT 'C',
  `AverageCost` decimal(18,4) DEFAULT 0.0000,
  `CurrentSellingPrice` decimal(18,4) DEFAULT 0.0000
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `companysettings`
--

CREATE TABLE `companysettings` (
  `Id` int(11) NOT NULL,
  `CompanyName` varchar(200) NOT NULL,
  `CompanyLogoPath` varchar(500) DEFAULT NULL,
  `Address` varchar(500) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Phone` varchar(50) DEFAULT NULL,
  `TaxNumber` varchar(100) DEFAULT NULL,
  `OwnerWhatsApp` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `companysettings`
--

INSERT INTO `companysettings` (`Id`, `CompanyName`, `CompanyLogoPath`, `Address`, `Email`, `Phone`, `TaxNumber`, `OwnerWhatsApp`) VALUES
(1, 'تالين فارما', 'logo_20260427001108.png', 'ذمار المنزل', 'abo0071008@gmail.com', '0773240500', NULL, '+967773240500');

-- --------------------------------------------------------

--
-- بنية الجدول `currencies`
--

CREATE TABLE `currencies` (
  `CurrencyId` int(11) NOT NULL,
  `CurrencyCode` varchar(10) NOT NULL COMMENT 'مثل: YER, USD, SAR',
  `CurrencyName` varchar(50) NOT NULL COMMENT 'الاسم بالعربي',
  `ExchangeRate` decimal(18,4) NOT NULL DEFAULT 1.0000 COMMENT 'سعر الصرف مقابل العملة المحلية',
  `IsBaseCurrency` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 = هذه هي العملة المحلية الأساسية للنظام',
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `currencies`
--

INSERT INTO `currencies` (`CurrencyId`, `CurrencyCode`, `CurrencyName`, `ExchangeRate`, `IsBaseCurrency`, `IsActive`) VALUES
(1, 'YER', 'YER', 1.0000, 1, 1);

-- --------------------------------------------------------

--
-- بنية الجدول `customers`
--

CREATE TABLE `customers` (
  `CustomerID` int(11) NOT NULL,
  `BranchId` int(11) NOT NULL DEFAULT 1,
  `FullName` varchar(150) NOT NULL,
  `Phone` varchar(50) DEFAULT NULL,
  `Address` text DEFAULT NULL,
  `CreditLimit` decimal(18,2) DEFAULT 0.00,
  `AccountID` int(11) NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  `CreatedAt` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `customers`
--

INSERT INTO `customers` (`CustomerID`, `BranchId`, `FullName`, `Phone`, `Address`, `CreditLimit`, `AccountID`, `IsActive`, `CreatedAt`) VALUES
(1, 1, 'عميل نقدي (محاكاة)', NULL, NULL, NULL, 111, 1, '2026-04-27 01:04:33'),
(2, 1, 'عميل تأمين طبي (محاكاة)', NULL, NULL, NULL, 112, 1, '2026-04-27 01:04:33');

-- --------------------------------------------------------

--
-- بنية الجدول `drugcategories`
--

CREATE TABLE `drugcategories` (
  `CategoryId` int(11) NOT NULL,
  `CategoryName` varchar(100) NOT NULL,
  `Description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `drugcategories`
--

INSERT INTO `drugcategories` (`CategoryId`, `CategoryName`, `Description`) VALUES
(1, 'مضادات حيوية', 'أدوية لعلاج الالتهابات البكتيرية'),
(2, 'فيتامينات ومكملات', 'فيتامينات متعددة ومعادن لرفع المناعة'),
(3, 'أدوية ضغط الدم', 'علاجات لارتفاع وانخفاض ضغط الدم'),
(4, 'أدوية السكري', 'علاجات لتنظيم مستوى السكر في الدم'),
(5, 'أدوية الجهاز الهضمي', 'علاجات للمعدة والقولون والحموضة'),
(100, 'أدوية القلب والشرايين', 'أدوية متعلقة بضغط الدم والقلب');

-- --------------------------------------------------------

--
-- بنية الجدول `drugs`
--

CREATE TABLE `drugs` (
  `DrugID` int(11) NOT NULL,
  `DrugName` varchar(150) NOT NULL,
  `Manufacturer` varchar(150) DEFAULT NULL,
  `GroupId` int(11) DEFAULT NULL,
  `Barcode` varchar(50) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  `SaremaCategory` varchar(10) DEFAULT 'S',
  `CategoryName` varchar(100) DEFAULT NULL,
  `CategoryId` int(11) DEFAULT NULL,
  `ImagePath` varchar(255) DEFAULT NULL,
  `MainUnit` varchar(50) NOT NULL DEFAULT 'علبة' COMMENT 'وحدة الشراء الكبرى',
  `UnitId` int(11) DEFAULT NULL,
  `SubUnit` varchar(50) NOT NULL DEFAULT 'حبة' COMMENT 'وحدة البيع الصغرى',
  `ConversionFactor` int(11) NOT NULL DEFAULT 1 COMMENT 'العبوة / معامل التحويل',
  `IsDeleted` tinyint(1) DEFAULT 0,
  `CreatedAt` datetime DEFAULT current_timestamp(),
  `CreatedBy` int(11) DEFAULT NULL,
  `UpdatedAt` datetime DEFAULT NULL,
  `UpdatedBy` int(11) DEFAULT NULL,
  `IsLifeSaving` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `drugs`
--

INSERT INTO `drugs` (`DrugID`, `DrugName`, `Manufacturer`, `GroupId`, `Barcode`, `IsActive`, `SaremaCategory`, `CategoryName`, `CategoryId`, `ImagePath`, `MainUnit`, `UnitId`, `SubUnit`, `ConversionFactor`, `IsDeleted`, `CreatedAt`, `CreatedBy`, `UpdatedAt`, `UpdatedBy`, `IsLifeSaving`) VALUES
(1, 'بانادول اكسترا', NULL, 101, 'SIM-36F43460', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:33', NULL, NULL, NULL, 0),
(2, 'أوجمنتين 1 جرام', NULL, 101, 'SIM-EDEE6313', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:33', NULL, NULL, NULL, 0),
(3, 'فولتارين 50 مجم', NULL, 101, 'SIM-A2B81B45', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:33', NULL, NULL, NULL, 0),
(4, 'أوميبرازول 20 مجم', NULL, 101, 'SIM-C816846F', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(5, 'جلوكوفاج 500 مجم', NULL, 101, 'SIM-50418DEE', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(6, 'أملوديبين 5 مجم', NULL, 101, 'SIM-54205C88', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(7, 'أتورفاستاتين 20 مجم', NULL, 101, 'SIM-9D0D171C', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(8, 'نيكسيوم 40 مجم', NULL, 101, 'SIM-3F7143E1', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(9, 'بروفين 400 مجم', NULL, 101, 'SIM-51440C86', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(10, 'فيتامين سي 1000 مجم', NULL, 101, 'SIM-96854649', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(11, 'بانادول كولد اند فلو', NULL, 101, 'SIM-152DF9CC', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(12, 'أدول 500 مجم', NULL, 101, 'SIM-903653A9', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(13, 'كونكور 5 مجم', NULL, 101, 'SIM-1F169F80', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(14, 'ليبيتور 20 مجم', NULL, 101, 'SIM-1D9B2155', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(15, 'فنتولين بخاخ', NULL, 101, 'SIM-91B8F1A0', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(16, 'فيكس فابوراب', NULL, 101, 'SIM-FEE825D9', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(17, 'ستريبسلز ليمون', NULL, 101, 'SIM-AB281892', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(18, 'سولبادين فوار', NULL, 101, 'SIM-4209F678', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(19, 'سيتامول 500 مجم', NULL, 101, 'SIM-08C4F9C9', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(20, 'أوجمنتين 625 مجم', NULL, 101, 'SIM-C75C6A51', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(21, 'كلارينيز أقراص', NULL, 101, 'SIM-F735A2B8', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(22, 'تلفاست 180 مجم', NULL, 101, 'SIM-C767FB41', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(23, 'بانتوزول 40 مجم', NULL, 101, 'SIM-0F843670', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(24, 'زيرتك 10 مجم', NULL, 101, 'SIM-F7DB4B90', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(25, 'بنادول نايت', NULL, 101, 'SIM-DA8D050B', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(26, 'زانتينول 150 مجم', NULL, 101, 'SIM-E92CF480', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(27, 'كتافلام 50 مجم', NULL, 101, 'SIM-D4C10DBF', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(28, 'أولفن 100 مجم', NULL, 101, 'SIM-E747D11C', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(29, 'موكسال أقراص', NULL, 101, 'SIM-4F6B3D1E', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(30, 'ميبو كريم', NULL, 101, 'SIM-7D2E6100', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(31, 'فيوسيدين مرهم', NULL, 101, 'SIM-0ABED5F2', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(32, 'فيوسيكورت كريم', NULL, 101, 'SIM-16CA9F2E', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(33, 'كيناكومب كريم', NULL, 101, 'SIM-D490F4F1', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(34, 'بانثينول مرهم', NULL, 101, 'SIM-8972E4D6', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(35, 'بيفانتين كريم', NULL, 101, 'SIM-C2FF4AD7', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(36, 'ريفو 75 مجم', NULL, 101, 'SIM-78627A71', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(37, 'أسبيرين 81 مجم', NULL, 101, 'SIM-0A401CEA', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(38, 'بلافيكس 75 مجم', NULL, 101, 'SIM-0E41725A', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(39, 'جانوميت 50/1000', NULL, 101, 'SIM-84B34968', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(40, 'دياميكرون 60 مجم', NULL, 101, 'SIM-CFE06C8D', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(41, 'إنسولين لانتوس', NULL, 101, 'SIM-0AF026BA', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(42, 'إنسولين نوفورابيد', NULL, 101, 'SIM-1EA97803', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(43, 'فيكتوزا حقن', NULL, 101, 'SIM-6CC40819', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(44, 'أوزمبيك حقن', NULL, 101, 'SIM-ED3EBE07', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(45, 'فوركسيجا 10 مجم', NULL, 101, 'SIM-6DD5256D', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(46, 'جارديانس 25 مجم', NULL, 101, 'SIM-32D1845D', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(47, 'إكسفورج 5/160', NULL, 101, 'SIM-C5E321A5', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(48, 'أتاكاند 16 مجم', NULL, 101, 'SIM-C7CF0869', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(49, 'ديوفان 80 مجم', NULL, 101, 'SIM-92D999B5', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(50, 'إكسيلون لزقات', NULL, 101, 'SIM-DE20A50F', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(51, 'اريسيبت 5 مجم', NULL, 101, 'SIM-01931720', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(52, 'سيروكويل 100 مجم', NULL, 101, 'SIM-3F196D7E', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(53, 'زيبراكسا 5 مجم', NULL, 101, 'SIM-043451E2', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(54, 'بروزاك 20 مجم', NULL, 101, 'SIM-B7745EDF', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(55, 'سيبرالكس 10 مجم', NULL, 101, 'SIM-B500F958', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(56, 'زانكس 0.25 مجم', NULL, 101, 'SIM-143946C2', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(57, 'ليكسوتانيل 3 مجم', NULL, 101, 'SIM-DEA3A4B5', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(58, 'نيورونتين 300 مجم', NULL, 101, 'SIM-713B54A9', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(59, 'ليريكا 75 مجم', NULL, 101, 'SIM-6D02A23C', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(60, 'كيتيل 50 مجم', NULL, 101, 'SIM-084CA983', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(61, 'دافلون 500 مجم', NULL, 101, 'SIM-6AF11863', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:34', NULL, NULL, NULL, 0),
(62, 'أركوكسيا 90 مجم', NULL, 101, 'SIM-2E48C79F', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(63, 'سيلبريكس 200 مجم', NULL, 101, 'SIM-6DBAFE0F', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(64, 'بريدنيزولون 5 مجم', NULL, 101, 'SIM-E5D16E06', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(65, 'ديكساميثازون أمبول', NULL, 101, 'SIM-11EABD7D', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(66, 'فيتامين د3 50000 وحدة', NULL, 101, 'SIM-B224282F', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(67, 'أوميجا 3 كبسولات', NULL, 101, 'SIM-7CC479D6', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(68, 'سنترم فيتامينات', NULL, 101, 'SIM-97D87F48', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(69, 'هيموجلوبين فوار', NULL, 101, 'SIM-DC7062BB', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(70, 'فيروغلوبين كبسول', NULL, 101, 'SIM-9D103468', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(71, 'فوليك أسيد 5 مجم', NULL, 101, 'SIM-74154F31', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(72, 'بي كربون 12 حقن', NULL, 101, 'SIM-49DE4B36', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(73, 'نيروبيون أمبول', NULL, 101, 'SIM-AA6017E0', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(74, 'فيتامين ب12 أقراص', NULL, 101, 'SIM-53C474AB', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(75, 'سبازموفري أقراص', NULL, 101, 'SIM-26521348', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(76, 'بسكوبان أقراص', NULL, 101, 'SIM-9F8A1CC9', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(77, 'دومبي شراب', NULL, 101, 'SIM-0860DAF4', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(78, 'موتيليوم أقراص', NULL, 101, 'SIM-F205EEBF', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(79, 'بريمبران أقراص', NULL, 101, 'SIM-01FCD199', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(80, 'فلاجيل 500 مجم', NULL, 101, 'SIM-03C9B761', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(81, 'مترونيدازول شراب', NULL, 101, 'SIM-0DEAB99E', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(82, 'أموكسيسيلين كبسول', NULL, 101, 'SIM-8E9A9691', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(83, 'سيبروفلوكساسين 500 مجم', NULL, 101, 'SIM-BBD1E807', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(84, 'زيثروماكس 500 مجم', NULL, 101, 'SIM-07B1811A', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(85, 'روكسيثروماكس 150 مجم', NULL, 101, 'SIM-223AAF70', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(86, 'كلافوكس شراب', NULL, 101, 'SIM-1073DB9E', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(87, 'سوبراكس كبسول', NULL, 101, 'SIM-88657D7D', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(88, 'سيفورال أقراص', NULL, 101, 'SIM-5961A62D', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(89, 'تارجت أقراص', NULL, 101, 'SIM-258F9CF9', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(90, 'فلوكا 150 مجم', NULL, 101, 'SIM-EDC5F843', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(91, 'كانستين كريم', NULL, 101, 'SIM-B821643B', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(92, 'دكتارين مرهم', NULL, 101, 'SIM-B21EEAEC', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(93, 'ترافوكورت كريم', NULL, 101, 'SIM-F89C0427', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(94, 'إليكا مرهم', NULL, 101, 'SIM-22AF2341', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(95, 'ديرموفيت مرهم', NULL, 101, 'SIM-F368F6CE', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(96, 'كلوفات مرهم', NULL, 101, 'SIM-4F4BC4D5', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(97, 'بيتاميثازون كريم', NULL, 101, 'SIM-80113BA9', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(98, 'هيدروكورتيزون كريم', NULL, 101, 'SIM-897222F8', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(99, 'أفالون كريم تشققات', NULL, 101, 'SIM-5F71B2E2', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(100, 'بالمرز زبدة كاكاو', NULL, 101, 'SIM-220091F8', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(101, 'فازلين جلي', NULL, 101, 'SIM-5CF33C97', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(102, 'جليسوليد كريم', NULL, 101, 'SIM-76B4E060', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(103, 'نيفيا سوفت', NULL, 101, 'SIM-23314549', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(104, 'كيو في كريم مرطب', NULL, 101, 'SIM-66923315', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(105, 'سيتافيل غسول', NULL, 101, 'SIM-75C5BC5B', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:35', NULL, NULL, NULL, 0),
(106, 'لاروش بوزيه واقي شمس', NULL, 101, 'SIM-25BABBD0', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(107, 'بيوديرما واقي شمس', NULL, 101, 'SIM-7FB2A3F7', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(108, 'افين مياه حرارية', NULL, 101, 'SIM-A44FEC8F', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(109, 'فيتشي كريم نهار', NULL, 101, 'SIM-477BD7C4', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(110, 'ريكسونا مزيل عرق', NULL, 101, 'SIM-76CF5F49', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(111, 'بيزلين كريم تفتيح', NULL, 101, 'SIM-21629A45', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(112, 'هيمالايا غسول وجه', NULL, 101, 'SIM-0083D8CE', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(113, 'نيتروجينا مقشر', NULL, 101, 'SIM-DD3BCF05', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(114, 'كلين اند كلير غسول', NULL, 101, 'SIM-1D5FD128', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(115, 'جونسون بودرة أطفال', NULL, 101, 'SIM-745CFC22', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(116, 'سودوكريم', NULL, 101, 'SIM-097B5AAF', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(117, 'سيباميد شامبو أطفال', NULL, 101, 'SIM-FA735C35', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(118, 'بامبرز مقاس 4', NULL, 101, 'SIM-AD21736E', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(119, 'هجيز حفاضات', NULL, 101, 'SIM-C3F5F991', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(120, 'حليب نيدو 1800 جرام', NULL, 101, 'SIM-69A62FB8', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(121, 'حليب نان 1', NULL, 101, 'SIM-7B337508', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(122, 'حليب سيميلاك 2', NULL, 101, 'SIM-D155D34F', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(123, 'أبتاميل حليب', NULL, 101, 'SIM-F881B969', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(124, 'بليميل بلس حليب', NULL, 101, 'SIM-200E91A2', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(125, 'رونالاك حليب', NULL, 101, 'SIM-4BA4AA0E', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(126, 'بروجرس حليب', NULL, 101, 'SIM-AF4D4B62', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(127, 'بدياشور مكمل غذائي', NULL, 101, 'SIM-77DF67E6', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(128, 'إنسور مكمل غذائي', NULL, 101, 'SIM-FB28AA62', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(129, 'جلوكيرنا مكمل', NULL, 101, 'SIM-6242C2DB', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(130, 'سيفترياكسون 1 جرام حقن', NULL, 101, 'SIM-B414E913', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(131, 'كليكزان 40 حقن', NULL, 101, 'SIM-024C2DEB', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(132, 'هيبارين أمبول', NULL, 101, 'SIM-59697484', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(133, 'أدرينالين أمبول', NULL, 101, 'SIM-A2F8DB7C', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(134, 'أتروبين أمبول', NULL, 101, 'SIM-8FCE5579', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(135, 'لازكس 40 مجم', NULL, 101, 'SIM-DB8A6EE7', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(136, 'ألداكتون 25 مجم', NULL, 101, 'SIM-2171D4A3', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(137, 'مدر بول هيدروكلوروثيازيد', NULL, 101, 'SIM-04BF03D0', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(138, 'فارولين بخاخ', NULL, 101, 'SIM-657FC832', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(139, 'سيمبيكورت بخاخ', NULL, 101, 'SIM-BF00EAFD', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(140, 'سيريتايد بخاخ', NULL, 101, 'SIM-CCE9B7BB', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(141, 'بولميكورت محلول استنشاق', NULL, 101, 'SIM-128159AB', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(142, 'موسيدين شراب', NULL, 101, 'SIM-DEC54006', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:36', NULL, NULL, NULL, 0),
(143, 'فنستيل نقط', NULL, 101, 'SIM-4DC48BC4', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(144, 'أدول شراب', NULL, 101, 'SIM-94EEB294', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(145, 'بروفين شراب', NULL, 101, 'SIM-F61FDFC0', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(146, 'ميكوسولفان شراب', NULL, 101, 'SIM-C6B1D1DD', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(147, 'توسكان شراب', NULL, 101, 'SIM-5E6830E4', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(148, 'كافوسيد شراب', NULL, 101, 'SIM-C2E66725', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(149, 'إيزيلين شراب', NULL, 101, 'SIM-74160E87', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(150, 'كوديلار شراب', NULL, 101, 'SIM-48FE1808', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(151, 'أوتريفين بخاخ أنف', NULL, 101, 'SIM-4C7EFA13', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(152, 'قطرة رينوستوب', NULL, 101, 'SIM-D37BAB1E', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(153, 'نازونكس بخاخ', NULL, 101, 'SIM-DC90B269', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(154, 'فليكسونيز بخاخ', NULL, 101, 'SIM-F22EDDBD', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(155, 'قطرة هاي فريش', NULL, 101, 'SIM-BF3D26E5', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(156, 'قطرة سيستان', NULL, 101, 'SIM-5558204A', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(157, 'قطرة توبرادكس', NULL, 101, 'SIM-48848D28', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(158, 'قطرة أوفلوكس', NULL, 101, 'SIM-D313FAB3', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(159, 'قطرة اوبتي فريش', NULL, 101, 'SIM-A9209E50', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(160, 'فيسين قطرة عيون', NULL, 101, 'SIM-3831127D', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(161, 'ريفرش تيرز', NULL, 101, 'SIM-2C782812', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(162, 'بيتادين مطهر', NULL, 101, 'SIM-F76A578C', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(163, 'ديتول سائل', NULL, 101, 'SIM-5ED62EAE', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(164, 'مسحة طبية كحولية', NULL, 101, 'SIM-CB85759F', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(165, 'شاش معقم', NULL, 101, 'SIM-C7EA21D5', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(166, 'قطن طبي', NULL, 101, 'SIM-83186D34', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(167, 'بالستر جروح', NULL, 101, 'SIM-765441F4', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(168, 'جهاز قياس ضغط الدم', NULL, 101, 'SIM-5E57DB71', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(169, 'جهاز قياس السكر', NULL, 101, 'SIM-57212CC2', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(170, 'شرائط قياس السكر اكوتشيك', NULL, 101, 'SIM-A2B6C8BA', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(171, 'إبر وخز السكر', NULL, 101, 'SIM-B4401F6E', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(172, 'ترمومتر رقمي', NULL, 101, 'SIM-9384FB01', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:37', NULL, NULL, NULL, 0),
(173, 'كمامات طبية', NULL, 101, 'SIM-4972EC38', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(174, 'جوانتي معقم', NULL, 101, 'SIM-1043F62B', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(175, 'صيدلية إسعافات أولية', NULL, 101, 'SIM-3F458A45', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(176, 'فازلين مرطب شفاه', NULL, 101, 'SIM-1B52BF47', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(177, 'لابيلو مرطب', NULL, 101, 'SIM-E501957D', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(178, 'كريم شد البشرة', NULL, 101, 'SIM-317308B2', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(179, 'كريم علاج الهالات', NULL, 101, 'SIM-BEEA858D', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(180, 'سيروم فيتامين سي', NULL, 101, 'SIM-7F8A1BAD', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(181, 'سيروم ريتينول', NULL, 101, 'SIM-E93E64DA', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(182, 'سيروم هيالورونيك اسيد', NULL, 101, 'SIM-62E37714', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(183, 'زيت جدايل للشعر', NULL, 101, 'SIM-B90F41DF', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(184, 'شامبو هيد اند شولدرز', NULL, 101, 'SIM-24CC91F2', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(185, 'بلسم بانتين', NULL, 101, 'SIM-BFF35EC5', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(186, 'صبغة لوريال', NULL, 101, 'SIM-F2ED62DC', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(187, 'صابون دوف', NULL, 101, 'SIM-D654D2EB', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(188, 'شاور جيل لوكس', NULL, 101, 'SIM-7E8F3956', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(189, 'فرشاة أسنان سنسوداين', NULL, 101, 'SIM-2E5507AD', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(190, 'معجون أسنان كولجيت', NULL, 101, 'SIM-F68426CE', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(191, 'ليسترين غسول فم', NULL, 101, 'SIM-4A0E37F7', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(192, 'خيط أسنان', NULL, 101, 'SIM-011F85A8', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(193, 'حبوب مص للحلق', NULL, 101, 'SIM-13CECEB2', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(194, 'شراب منشط للذاكرة', NULL, 101, 'SIM-162F4101', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(195, 'كبسولات غذاء ملكات النحل', NULL, 101, 'SIM-E3FB2D6D', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(196, 'حبوب الثوم', NULL, 101, 'SIM-E47065C2', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(197, 'حبوب الخميرة', NULL, 101, 'SIM-5233A1E8', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(198, 'مالتي فيتامين للرجال', NULL, 101, 'SIM-410AA599', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(199, 'مالتي فيتامين للنساء', NULL, 101, 'SIM-7CB5EDBB', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0),
(200, 'شراب كالسيوم للأطفال', NULL, 101, 'SIM-1E4C7E2B', 1, NULL, NULL, NULL, NULL, 'باكت', NULL, 'حبة', 24, NULL, '2026-04-27 01:04:38', NULL, NULL, NULL, 0);

-- --------------------------------------------------------

--
-- بنية الجدول `drugtransferdetails`
--

CREATE TABLE `drugtransferdetails` (
  `DetailID` int(11) NOT NULL,
  `TransferID` int(11) NOT NULL,
  `DrugID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL,
  `UnitCost` decimal(18,4) NOT NULL DEFAULT 0.0000
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `drugtransfers`
--

CREATE TABLE `drugtransfers` (
  `TransferID` int(11) NOT NULL,
  `FromBranchID` int(11) NOT NULL,
  `ToBranchID` int(11) NOT NULL,
  `TransferDate` datetime NOT NULL DEFAULT current_timestamp(),
  `ReceiveDate` datetime DEFAULT NULL,
  `Status` varchar(20) NOT NULL DEFAULT 'Pending',
  `CreatedBy` int(11) NOT NULL,
  `ReceivedBy` int(11) DEFAULT NULL,
  `Notes` varchar(250) DEFAULT NULL,
  `JournalId` int(11) DEFAULT NULL,
  `ReceiptJournalId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `drug_batches`
--

CREATE TABLE `drug_batches` (
  `BatchId` int(11) NOT NULL,
  `DrugId` int(11) NOT NULL,
  `BatchNumber` varchar(100) NOT NULL,
  `ProductionDate` date DEFAULT NULL,
  `ExpiryDate` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `employees`
--

CREATE TABLE `employees` (
  `EmployeeID` int(11) NOT NULL,
  `BranchID` int(11) NOT NULL,
  `FullName` varchar(150) NOT NULL,
  `Position` varchar(100) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  `Salary` decimal(18,2) DEFAULT 0.00,
  `Phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `employees`
--

INSERT INTO `employees` (`EmployeeID`, `BranchID`, `FullName`, `Position`, `IsActive`, `Salary`, `Phone`) VALUES
(1, 1, 'أحمد محمد (مدير)', 'مدير فرع', 1, 150000.00, '770000001'),
(2, 1, 'صالح علي (صيدلاني)', 'صيدلاني', 1, 100000.00, '770000002');

-- --------------------------------------------------------

--
-- بنية الجدول `forecasts`
--

CREATE TABLE `forecasts` (
  `ForecastID` int(11) NOT NULL,
  `BranchID` int(11) NOT NULL,
  `DrugID` int(11) NOT NULL,
  `ForecastDate` date NOT NULL,
  `PredictedDemand` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `fundtransfers`
--

CREATE TABLE `fundtransfers` (
  `TransferID` int(11) NOT NULL,
  `BranchId` int(11) NOT NULL DEFAULT 1,
  `FromAccountID` int(11) NOT NULL,
  `ToAccountID` int(11) NOT NULL,
  `Amount` decimal(18,2) NOT NULL,
  `TransferDate` datetime NOT NULL DEFAULT current_timestamp(),
  `ReferenceNo` varchar(50) DEFAULT NULL,
  `Notes` varchar(250) DEFAULT NULL,
  `CreatedBy` int(11) NOT NULL,
  `JournalId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `itemgroups`
--

CREATE TABLE `itemgroups` (
  `GroupId` int(11) NOT NULL,
  `GroupCode` varchar(50) DEFAULT NULL COMMENT 'رمز المجموعة (مثال: A, B, C)',
  `GroupName` varchar(150) NOT NULL COMMENT 'اسم المجموعة أو المادة الفعالة (مثال: باراسيتامول 500)',
  `Description` varchar(255) DEFAULT NULL COMMENT 'ملاحظات ووصف',
  `Notes` varchar(255) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'حالة التفعيل 1=نشط، 0=موقوف'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `itemgroups`
--

INSERT INTO `itemgroups` (`GroupId`, `GroupCode`, `GroupName`, `Description`, `Notes`, `IsActive`) VALUES
(1, 'A-000', 'مسكنات الالم ', NULL, NULL, 1),
(2, 'G-002', 'مجموعة البنسلين', 'مضادات حيوية بنسلينية', NULL, 1),
(3, 'G-003', 'فيتامين سي', 'مكملات فيتامين سي لرفع المناعة', NULL, 1),
(4, 'G-004', 'مثبطات بيتا', 'تستخدم لعلاج ارتفاع ضغط الدم', NULL, 1),
(5, 'G-005', 'ميتفورمين', 'منظمات سكر الدم', NULL, 1),
(6, 'G-006', 'مضادات الحموضة', 'أدوية حموضة المعدة (PPI)', NULL, 1),
(100, 'G-100', 'مثبطات بيتا (Beta Blockers)', NULL, NULL, 1),
(101, NULL, 'عام', NULL, NULL, 1);

-- --------------------------------------------------------

--
-- بنية الجدول `journaldetails`
--

CREATE TABLE `journaldetails` (
  `DetailID` int(11) NOT NULL,
  `JournalID` int(11) NOT NULL,
  `AccountID` int(11) NOT NULL,
  `Debit` decimal(18,2) NOT NULL DEFAULT 0.00,
  `Credit` decimal(18,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `journalentries`
--

CREATE TABLE `journalentries` (
  `JournalID` int(11) NOT NULL,
  `BranchID` int(11) NOT NULL,
  `JournalDate` datetime NOT NULL DEFAULT current_timestamp(),
  `Description` varchar(500) DEFAULT NULL,
  `ReferenceType` varchar(50) DEFAULT NULL COMMENT 'Receipt, Payment, Sale, Purchase',
  `IsPosted` tinyint(1) NOT NULL DEFAULT 0,
  `CreatedBy` int(11) NOT NULL,
  `ReferenceNo` varchar(100) DEFAULT NULL,
  `PayeePayerName` varchar(200) DEFAULT NULL,
  `IsDeleted` tinyint(1) DEFAULT 0,
  `UpdatedAt` datetime DEFAULT NULL,
  `UpdatedBy` int(11) DEFAULT NULL,
  `DeletedAt` datetime DEFAULT NULL,
  `DeletedBy` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `legacy_shelves_backup`
--

CREATE TABLE `legacy_shelves_backup` (
  `ShelfId` int(11) NOT NULL,
  `WarehouseId` int(11) NOT NULL,
  `GroupId` int(11) DEFAULT NULL COMMENT 'المجموعة الدوائية المخصصة لهذا الرف',
  `ShelfCode` varchar(50) NOT NULL COMMENT 'كود الرف مثل A1, B2',
  `Description` varchar(200) DEFAULT NULL,
  `IsActive` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `legacy_warehouses_backup`
--

CREATE TABLE `legacy_warehouses_backup` (
  `WarehouseId` int(11) NOT NULL,
  `BranchId` int(11) NOT NULL,
  `WarehouseName` varchar(100) NOT NULL,
  `IsActive` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `purchasedetails`
--

CREATE TABLE `purchasedetails` (
  `DetailID` int(11) NOT NULL,
  `PurchaseID` int(11) NOT NULL,
  `DrugID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL,
  `RemainingQuantity` int(11) NOT NULL DEFAULT 0,
  `BonusQuantity` int(11) NOT NULL DEFAULT 0,
  `CostPrice` decimal(18,2) NOT NULL,
  `SellingPrice` decimal(18,2) NOT NULL DEFAULT 0.00,
  `BatchNumber` varchar(50) DEFAULT NULL,
  `ExpiryDate` date NOT NULL DEFAULT '2026-01-01',
  `SubTotal` decimal(18,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `purchaseplandetails`
--

CREATE TABLE `purchaseplandetails` (
  `DetailId` int(11) NOT NULL,
  `PlanId` int(11) NOT NULL,
  `DrugId` int(11) NOT NULL,
  `CurrentStock` int(11) NOT NULL,
  `ABCCategory` varchar(10) DEFAULT NULL,
  `ForecastedDemand` decimal(18,4) NOT NULL,
  `ForecastAccuracy` decimal(18,4) NOT NULL,
  `ProposedQuantity` int(11) NOT NULL,
  `ApprovedQuantity` int(11) NOT NULL,
  `UnitCostEstimate` decimal(18,4) NOT NULL,
  `TotalCost` decimal(18,4) NOT NULL,
  `IsLifeSaving` tinyint(1) NOT NULL,
  `Status` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `purchaseplans`
--

CREATE TABLE `purchaseplans` (
  `PlanId` int(11) NOT NULL,
  `BranchId` int(11) NOT NULL,
  `CreatedBy` int(11) NOT NULL,
  `PlanDate` datetime NOT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `Notes` varchar(500) DEFAULT NULL,
  `EstimatedTotalCost` decimal(18,4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `purchases`
--

CREATE TABLE `purchases` (
  `PurchaseID` int(11) NOT NULL,
  `InvoiceNumber` varchar(50) NOT NULL COMMENT 'رقم فاتورة المورد الخارجية',
  `SupplierId` int(11) NOT NULL,
  `BranchID` int(11) NOT NULL,
  `PurchaseDate` datetime NOT NULL DEFAULT current_timestamp(),
  `UserID` int(11) NOT NULL,
  `TotalAmount` decimal(18,2) NOT NULL DEFAULT 0.00,
  `Discount` decimal(18,2) NOT NULL DEFAULT 0.00,
  `TaxAmount` decimal(18,2) NOT NULL DEFAULT 0.00,
  `NetAmount` decimal(18,2) NOT NULL DEFAULT 0.00,
  `PaymentStatus` varchar(20) NOT NULL DEFAULT 'Unpaid',
  `Notes` text DEFAULT NULL,
  `CreatedAt` datetime DEFAULT current_timestamp(),
  `IsDeleted` tinyint(1) DEFAULT 0,
  `UpdatedAt` datetime DEFAULT NULL,
  `UpdatedBy` int(11) DEFAULT NULL,
  `DeletedAt` datetime DEFAULT NULL,
  `DeletedBy` int(11) DEFAULT NULL,
  `AmountPaid` decimal(18,2) NOT NULL DEFAULT 0.00 COMMENT 'المبلغ المدفوع فوراً',
  `RemainingAmount` decimal(18,2) NOT NULL DEFAULT 0.00 COMMENT 'المبلغ المتبقي كدين على المورد',
  `IsReturn` tinyint(1) NOT NULL DEFAULT 0,
  `ParentPurchaseId` int(11) DEFAULT NULL,
  `InvoiceImagePath` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `saledetails`
--

CREATE TABLE `saledetails` (
  `SaleDetailID` int(11) NOT NULL,
  `SaleID` int(11) NOT NULL,
  `DrugID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL,
  `UnitPrice` decimal(18,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `sales`
--

CREATE TABLE `sales` (
  `SaleID` int(11) NOT NULL,
  `BranchID` int(11) NOT NULL,
  `SaleDate` datetime NOT NULL DEFAULT current_timestamp(),
  `UserID` int(11) NOT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `TotalAmount` decimal(18,2) NOT NULL DEFAULT 0.00,
  `Discount` decimal(18,2) DEFAULT 0.00,
  `TaxAmount` decimal(18,2) DEFAULT 0.00,
  `NetAmount` decimal(18,2) DEFAULT 0.00,
  `IsReturn` tinyint(1) DEFAULT 0 COMMENT '0=Sale, 1=Return',
  `ParentSaleId` int(11) DEFAULT NULL COMMENT 'ID of original invoice if this is a return',
  `IsDeleted` tinyint(1) DEFAULT 0,
  `UpdatedAt` datetime DEFAULT NULL,
  `UpdatedBy` int(11) DEFAULT NULL,
  `DeletedAt` datetime DEFAULT NULL,
  `DeletedBy` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `sale_payments`
--

CREATE TABLE `sale_payments` (
  `PaymentId` int(11) NOT NULL,
  `SaleId` int(11) NOT NULL,
  `PaymentMethod` varchar(50) NOT NULL COMMENT 'Cash, Bank, Credit',
  `AccountId` int(11) DEFAULT NULL COMMENT 'حساب الصندوق أو البنك الذي استلم المبلغ',
  `Amount` decimal(18,4) NOT NULL DEFAULT 0.0000
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `screenpermissions`
--

CREATE TABLE `screenpermissions` (
  `PermissionID` int(11) NOT NULL,
  `RoleID` int(11) NOT NULL,
  `ScreenID` int(11) NOT NULL,
  `CanView` tinyint(1) NOT NULL DEFAULT 0,
  `CanAdd` tinyint(1) NOT NULL DEFAULT 0,
  `CanEdit` tinyint(1) NOT NULL DEFAULT 0,
  `CanDelete` tinyint(1) NOT NULL DEFAULT 0,
  `CanPrint` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `seasonaldata`
--

CREATE TABLE `seasonaldata` (
  `SeasonalID` int(11) NOT NULL,
  `BranchID` int(11) NOT NULL,
  `DrugID` int(11) NOT NULL,
  `SeasonName` varchar(50) NOT NULL,
  `Year` int(11) NOT NULL,
  `SeasonalFactor` decimal(5,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `shelves`
--

CREATE TABLE `shelves` (
  `ShelfId` int(11) NOT NULL,
  `WarehouseId` int(11) NOT NULL,
  `GroupId` int(11) DEFAULT NULL COMMENT 'المجموعة العلاجية المخصصة',
  `ShelfName` varchar(100) NOT NULL COMMENT 'اسم الرف',
  `Notes` varchar(255) DEFAULT NULL COMMENT 'ملاحظات',
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `stockauditdetails`
--

CREATE TABLE `stockauditdetails` (
  `DetailID` int(11) NOT NULL,
  `AuditID` int(11) NOT NULL,
  `DrugID` int(11) NOT NULL,
  `SystemQty` int(11) NOT NULL,
  `PhysicalQty` int(11) NOT NULL,
  `Difference` int(11) NOT NULL,
  `UnitCost` decimal(18,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `stockaudits`
--

CREATE TABLE `stockaudits` (
  `AuditID` int(11) NOT NULL,
  `BranchID` int(11) NOT NULL,
  `AuditDate` datetime NOT NULL DEFAULT current_timestamp(),
  `UserID` int(11) NOT NULL,
  `Notes` varchar(500) DEFAULT NULL,
  `Status` varchar(20) DEFAULT 'Completed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `stockmovements`
--

CREATE TABLE `stockmovements` (
  `MovementID` int(11) NOT NULL,
  `BranchID` int(11) NOT NULL,
  `DrugID` int(11) NOT NULL,
  `MovementDate` datetime NOT NULL DEFAULT current_timestamp(),
  `MovementType` varchar(50) NOT NULL,
  `Quantity` int(11) NOT NULL,
  `ReferenceID` int(11) DEFAULT NULL,
  `UserID` int(11) NOT NULL,
  `Notes` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `suppliers`
--

CREATE TABLE `suppliers` (
  `SupplierID` int(11) NOT NULL,
  `BranchId` int(11) NOT NULL DEFAULT 1,
  `SupplierName` varchar(150) NOT NULL,
  `ContactPerson` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Address` text DEFAULT NULL,
  `AccountID` int(11) NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  `CreatedAt` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `suppliers`
--

INSERT INTO `suppliers` (`SupplierID`, `BranchId`, `SupplierName`, `ContactPerson`, `Phone`, `Address`, `AccountID`, `IsActive`, `CreatedAt`) VALUES
(1, 1, 'المورد الرئيسي للمحاكاة', NULL, NULL, NULL, 110, 1, '2026-04-27 01:04:33');

-- --------------------------------------------------------

--
-- بنية الجدول `systemlogs`
--

CREATE TABLE `systemlogs` (
  `LogId` int(11) NOT NULL,
  `UserId` int(11) NOT NULL,
  `Action` varchar(50) NOT NULL,
  `ScreenName` varchar(100) DEFAULT NULL,
  `Details` text DEFAULT NULL,
  `CreatedAt` datetime DEFAULT current_timestamp(),
  `IPAddress` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `systemlogs`
--

INSERT INTO `systemlogs` (`LogId`, `UserId`, `Action`, `ScreenName`, `Details`, `CreatedAt`, `IPAddress`) VALUES
(1, 1, 'Logout', 'Account', '[فرع 1] - قام المستخدم بتسجيل الخروج بنجاح.', '2026-04-27 03:40:34', '::1');

-- --------------------------------------------------------

--
-- بنية الجدول `systemnotifications`
--

CREATE TABLE `systemnotifications` (
  `Id` int(11) NOT NULL,
  `Category` varchar(50) NOT NULL DEFAULT 'inventory' COMMENT 'inventory | shortage | expiry | admin',
  `Severity` varchar(20) NOT NULL DEFAULT 'info' COMMENT 'critical | warning | info',
  `Title` varchar(300) NOT NULL DEFAULT '',
  `Body` varchar(1000) NOT NULL DEFAULT '',
  `Icon` varchar(100) NOT NULL DEFAULT 'notifications',
  `IconColor` varchar(100) NOT NULL DEFAULT 'text-blue-600',
  `BgColor` varchar(200) NOT NULL DEFAULT 'bg-blue-50 border-blue-200',
  `BadgeColor` varchar(100) NOT NULL DEFAULT 'bg-blue-500',
  `ActionUrl` varchar(300) NOT NULL DEFAULT '#',
  `ActionText` varchar(100) NOT NULL DEFAULT '—',
  `IsRead` tinyint(1) DEFAULT 0,
  `WhatsAppSent` tinyint(1) NOT NULL DEFAULT 0,
  `CreatedAt` datetime NOT NULL DEFAULT current_timestamp(),
  `BranchId` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `systemscreens`
--

CREATE TABLE `systemscreens` (
  `ScreenID` int(11) NOT NULL,
  `ScreenName` varchar(100) NOT NULL,
  `ScreenArabicName` varchar(100) NOT NULL,
  `ScreenCategory` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `units`
--

CREATE TABLE `units` (
  `UnitId` int(11) NOT NULL,
  `UnitName` varchar(50) NOT NULL,
  `ConversionFactor` decimal(10,2) DEFAULT 1.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `units`
--

INSERT INTO `units` (`UnitId`, `UnitName`, `ConversionFactor`) VALUES
(100, 'كرتون', 50.00),
(101, 'شريط', 10.00);

-- --------------------------------------------------------

--
-- بنية الجدول `userroles`
--

CREATE TABLE `userroles` (
  `RoleID` int(11) NOT NULL,
  `RoleName` varchar(50) NOT NULL,
  `RoleArabicName` varchar(100) DEFAULT NULL,
  `RoleDescription` varchar(200) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `userroles`
--

INSERT INTO `userroles` (`RoleID`, `RoleName`, `RoleArabicName`, `RoleDescription`, `IsActive`) VALUES
(1, 'SuperAdmin', 'المدير العام', 'يمتلك كافة صلاحيات النظام', 1),
(2, 'BranchManager', 'مدير الفرع', 'صلاحيات إدارة الفرع والمبيعات', 1),
(3, 'Pharmacist', 'طاقم طبي ومبيعات', 'صلاحيات البيع والمخزون', 1);

-- --------------------------------------------------------

--
-- بنية الجدول `users`
--

CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `Username` varchar(100) NOT NULL,
  `PasswordHash` varchar(200) NOT NULL,
  `RoleID` int(11) NOT NULL,
  `EmployeeID` int(11) DEFAULT NULL,
  `DefaultBranchID` int(11) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `users`
--

INSERT INTO `users` (`UserID`, `Username`, `PasswordHash`, `RoleID`, `EmployeeID`, `DefaultBranchID`, `IsActive`) VALUES
(1, 'admin', 'AQAAAAIAAYagAAAAEORRkz8Luc8wxYD+0Twjt1oYcEfyiQiiBCX5pL0tPKLF0xOHH1icCEKmy01wGSATmA==', 1, NULL, 1, 1),
(2, 'manager', 'AQAAAAIAAYagAAAAEPpJDUp2i3dn3Jzdu7gXCnW0X9zhrFdHJRPWsPZr0MwaUGvg+TDlQLUGPwJa7JjARg==', 2, 1, 1, 1),
(3, 'pharmacist', 'AQAAAAIAAYagAAAAEGSe93WPQKFKJhdYaj0Mb92nyd6EbRnj+0MBMjsZLFIH6lraq1GgwSAKS9jv7F/iwQ==', 3, 2, 1, 1);

-- --------------------------------------------------------

--
-- بنية الجدول `vouchers`
--

CREATE TABLE `vouchers` (
  `VoucherID` int(11) NOT NULL,
  `BranchID` int(11) NOT NULL,
  `VoucherType` varchar(20) NOT NULL COMMENT 'Receipt (قبض), Payment (صرف)',
  `VoucherDate` datetime NOT NULL DEFAULT current_timestamp(),
  `Amount` decimal(18,2) NOT NULL,
  `FromAccountID` int(11) NOT NULL,
  `ToAccountID` int(11) NOT NULL,
  `Description` text DEFAULT NULL,
  `CreatedBy` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `warehouses`
--

CREATE TABLE `warehouses` (
  `WarehouseId` int(11) NOT NULL,
  `BranchId` int(11) NOT NULL,
  `WarehouseName` varchar(150) NOT NULL COMMENT 'اسم المستودع',
  `Location` varchar(255) DEFAULT NULL COMMENT 'موقع المستودع',
  `IsActive` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `__efmigrationshistory`
--

CREATE TABLE `__efmigrationshistory` (
  `MigrationId` varchar(95) NOT NULL,
  `ProductVersion` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `__efmigrationshistory`
--

INSERT INTO `__efmigrationshistory` (`MigrationId`, `ProductVersion`) VALUES
('20260405011914_AddCompanySettings', '3.1.32'),
('20260406090521_SyncModelsWithDatabase', '3.1.32');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accountingtemplatelines`
--
ALTER TABLE `accountingtemplatelines`
  ADD PRIMARY KEY (`LineId`),
  ADD KEY `IX_AccountingTemplateLines_TemplateId` (`TemplateId`);

--
-- Indexes for table `accountingtemplates`
--
ALTER TABLE `accountingtemplates`
  ADD PRIMARY KEY (`TemplateId`);

--
-- Indexes for table `accountmappings`
--
ALTER TABLE `accountmappings`
  ADD PRIMARY KEY (`MappingId`),
  ADD KEY `IX_AccountMappings_AccountId` (`AccountId`);

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`AccountID`),
  ADD UNIQUE KEY `AccountCode` (`AccountCode`),
  ADD KEY `FK_Accounts_Branches` (`BranchId`);

--
-- Indexes for table `barcodegenerator`
--
ALTER TABLE `barcodegenerator`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `fk_barcode_drug` (`DrugId`),
  ADD KEY `fk_barcode_branch` (`BranchId`);

--
-- Indexes for table `branches`
--
ALTER TABLE `branches`
  ADD PRIMARY KEY (`BranchID`),
  ADD UNIQUE KEY `BranchCode` (`BranchCode`),
  ADD KEY `fk_branch_cash` (`DefaultCashAccountId`),
  ADD KEY `fk_branch_sales` (`DefaultSalesAccountId`),
  ADD KEY `fk_branch_cogs` (`DefaultCOGSAccountId`),
  ADD KEY `fk_branch_inv` (`DefaultInventoryAccountId`),
  ADD KEY `fk_branch_currency` (`DefaultCurrencyId`);

--
-- Indexes for table `branchinventory`
--
ALTER TABLE `branchinventory`
  ADD PRIMARY KEY (`BranchID`,`DrugID`),
  ADD KEY `fk_branchinventory_drug` (`DrugID`),
  ADD KEY `fk_inventory_shelf` (`ShelfId`);

--
-- Indexes for table `companysettings`
--
ALTER TABLE `companysettings`
  ADD PRIMARY KEY (`Id`);

--
-- Indexes for table `currencies`
--
ALTER TABLE `currencies`
  ADD PRIMARY KEY (`CurrencyId`),
  ADD UNIQUE KEY `CurrencyCode_UNIQUE` (`CurrencyCode`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`CustomerID`),
  ADD UNIQUE KEY `idx_unique_customer_name` (`FullName`),
  ADD KEY `AccountID` (`AccountID`),
  ADD KEY `fk_customers_branch` (`BranchId`);

--
-- Indexes for table `drugcategories`
--
ALTER TABLE `drugcategories`
  ADD PRIMARY KEY (`CategoryId`),
  ADD UNIQUE KEY `CategoryName_UNIQUE` (`CategoryName`);

--
-- Indexes for table `drugs`
--
ALTER TABLE `drugs`
  ADD PRIMARY KEY (`DrugID`),
  ADD UNIQUE KEY `idx_unique_barcode` (`Barcode`),
  ADD KEY `fk_drugs_category` (`CategoryId`),
  ADD KEY `fk_drugs_unit` (`UnitId`),
  ADD KEY `fk_drugs_itemgroup` (`GroupId`);

--
-- Indexes for table `drugtransferdetails`
--
ALTER TABLE `drugtransferdetails`
  ADD PRIMARY KEY (`DetailID`),
  ADD KEY `TransferID` (`TransferID`),
  ADD KEY `DrugID` (`DrugID`);

--
-- Indexes for table `drugtransfers`
--
ALTER TABLE `drugtransfers`
  ADD PRIMARY KEY (`TransferID`),
  ADD KEY `FromBranchID` (`FromBranchID`),
  ADD KEY `ToBranchID` (`ToBranchID`),
  ADD KEY `CreatedBy` (`CreatedBy`),
  ADD KEY `fk_dt_receivedby` (`ReceivedBy`),
  ADD KEY `fk_dt_journal` (`JournalId`),
  ADD KEY `fk_dt_receiptjournal` (`ReceiptJournalId`);

--
-- Indexes for table `drug_batches`
--
ALTER TABLE `drug_batches`
  ADD PRIMARY KEY (`BatchId`),
  ADD UNIQUE KEY `uq_drug_batch` (`DrugId`,`BatchNumber`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`EmployeeID`),
  ADD KEY `BranchID` (`BranchID`);

--
-- Indexes for table `forecasts`
--
ALTER TABLE `forecasts`
  ADD PRIMARY KEY (`ForecastID`),
  ADD KEY `BranchID` (`BranchID`),
  ADD KEY `DrugID` (`DrugID`);

--
-- Indexes for table `fundtransfers`
--
ALTER TABLE `fundtransfers`
  ADD PRIMARY KEY (`TransferID`),
  ADD KEY `FromAccountID` (`FromAccountID`),
  ADD KEY `ToAccountID` (`ToAccountID`),
  ADD KEY `CreatedBy` (`CreatedBy`),
  ADD KEY `fk_fund_branch` (`BranchId`),
  ADD KEY `fk_fund_journal` (`JournalId`);

--
-- Indexes for table `itemgroups`
--
ALTER TABLE `itemgroups`
  ADD PRIMARY KEY (`GroupId`);

--
-- Indexes for table `journaldetails`
--
ALTER TABLE `journaldetails`
  ADD PRIMARY KEY (`DetailID`),
  ADD KEY `fk_journaldetails_journal` (`JournalID`),
  ADD KEY `idx_account_balancing` (`AccountID`,`Debit`,`Credit`);

--
-- Indexes for table `journalentries`
--
ALTER TABLE `journalentries`
  ADD PRIMARY KEY (`JournalID`),
  ADD KEY `CreatedBy` (`CreatedBy`),
  ADD KEY `idx_journal_date` (`JournalDate`),
  ADD KEY `fk_journalentries_branch` (`BranchID`);

--
-- Indexes for table `legacy_shelves_backup`
--
ALTER TABLE `legacy_shelves_backup`
  ADD PRIMARY KEY (`ShelfId`),
  ADD KEY `fk_shelf_warehouse` (`WarehouseId`),
  ADD KEY `fk_shelf_itemgroup` (`GroupId`);

--
-- Indexes for table `legacy_warehouses_backup`
--
ALTER TABLE `legacy_warehouses_backup`
  ADD PRIMARY KEY (`WarehouseId`),
  ADD KEY `fk_warehouse_branch` (`BranchId`);

--
-- Indexes for table `purchasedetails`
--
ALTER TABLE `purchasedetails`
  ADD PRIMARY KEY (`DetailID`),
  ADD KEY `idx_expiry_date` (`ExpiryDate`),
  ADD KEY `fk_purchasedetails_purchase` (`PurchaseID`),
  ADD KEY `fk_purchasedetails_drug` (`DrugID`);

--
-- Indexes for table `purchaseplandetails`
--
ALTER TABLE `purchaseplandetails`
  ADD PRIMARY KEY (`DetailId`),
  ADD KEY `IX_purchaseplandetails_DrugId` (`DrugId`),
  ADD KEY `IX_purchaseplandetails_PlanId` (`PlanId`);

--
-- Indexes for table `purchaseplans`
--
ALTER TABLE `purchaseplans`
  ADD PRIMARY KEY (`PlanId`),
  ADD KEY `IX_purchaseplans_BranchId` (`BranchId`),
  ADD KEY `IX_purchaseplans_CreatedBy` (`CreatedBy`);

--
-- Indexes for table `purchases`
--
ALTER TABLE `purchases`
  ADD PRIMARY KEY (`PurchaseID`),
  ADD KEY `UserID` (`UserID`),
  ADD KEY `fk_purchases_branch` (`BranchID`),
  ADD KEY `fk_purchases_supplier` (`SupplierId`),
  ADD KEY `fk_purchases_parent` (`ParentPurchaseId`);

--
-- Indexes for table `saledetails`
--
ALTER TABLE `saledetails`
  ADD PRIMARY KEY (`SaleDetailID`),
  ADD KEY `fk_saledetails_sale` (`SaleID`),
  ADD KEY `fk_saledetails_drug` (`DrugID`);

--
-- Indexes for table `sales`
--
ALTER TABLE `sales`
  ADD PRIMARY KEY (`SaleID`),
  ADD KEY `CustomerID` (`CustomerID`),
  ADD KEY `idx_sale_date` (`SaleDate`),
  ADD KEY `fk_sales_branch` (`BranchID`),
  ADD KEY `fk_sales_user` (`UserID`);

--
-- Indexes for table `sale_payments`
--
ALTER TABLE `sale_payments`
  ADD PRIMARY KEY (`PaymentId`),
  ADD KEY `fk_sale_payments_sale` (`SaleId`),
  ADD KEY `fk_sale_payments_account` (`AccountId`);

--
-- Indexes for table `screenpermissions`
--
ALTER TABLE `screenpermissions`
  ADD PRIMARY KEY (`PermissionID`),
  ADD KEY `RoleID` (`RoleID`),
  ADD KEY `ScreenID` (`ScreenID`);

--
-- Indexes for table `seasonaldata`
--
ALTER TABLE `seasonaldata`
  ADD PRIMARY KEY (`SeasonalID`),
  ADD KEY `BranchID` (`BranchID`),
  ADD KEY `DrugID` (`DrugID`);

--
-- Indexes for table `shelves`
--
ALTER TABLE `shelves`
  ADD PRIMARY KEY (`ShelfId`),
  ADD KEY `fk_shelf_warehouse_new` (`WarehouseId`),
  ADD KEY `fk_shelf_itemgroup_new` (`GroupId`);

--
-- Indexes for table `stockauditdetails`
--
ALTER TABLE `stockauditdetails`
  ADD PRIMARY KEY (`DetailID`),
  ADD KEY `fk_audit_details_main` (`AuditID`),
  ADD KEY `fk_audit_details_drug` (`DrugID`);

--
-- Indexes for table `stockaudits`
--
ALTER TABLE `stockaudits`
  ADD PRIMARY KEY (`AuditID`),
  ADD KEY `fk_audits_branch` (`BranchID`),
  ADD KEY `fk_audits_user` (`UserID`);

--
-- Indexes for table `stockmovements`
--
ALTER TABLE `stockmovements`
  ADD PRIMARY KEY (`MovementID`),
  ADD KEY `BranchID` (`BranchID`),
  ADD KEY `DrugID` (`DrugID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`SupplierID`),
  ADD UNIQUE KEY `idx_unique_supplier_name` (`SupplierName`),
  ADD KEY `AccountID` (`AccountID`),
  ADD KEY `fk_suppliers_branch` (`BranchId`);

--
-- Indexes for table `systemlogs`
--
ALTER TABLE `systemlogs`
  ADD PRIMARY KEY (`LogId`),
  ADD KEY `UserId` (`UserId`);

--
-- Indexes for table `systemnotifications`
--
ALTER TABLE `systemnotifications`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `idx_severity` (`Severity`),
  ADD KEY `idx_branch` (`BranchId`),
  ADD KEY `idx_created` (`CreatedAt`);

--
-- Indexes for table `systemscreens`
--
ALTER TABLE `systemscreens`
  ADD PRIMARY KEY (`ScreenID`),
  ADD UNIQUE KEY `ScreenName` (`ScreenName`);

--
-- Indexes for table `units`
--
ALTER TABLE `units`
  ADD PRIMARY KEY (`UnitId`),
  ADD UNIQUE KEY `UnitName_UNIQUE` (`UnitName`);

--
-- Indexes for table `userroles`
--
ALTER TABLE `userroles`
  ADD PRIMARY KEY (`RoleID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `Username` (`Username`),
  ADD KEY `RoleID` (`RoleID`),
  ADD KEY `EmployeeID` (`EmployeeID`),
  ADD KEY `DefaultBranchID` (`DefaultBranchID`);

--
-- Indexes for table `vouchers`
--
ALTER TABLE `vouchers`
  ADD PRIMARY KEY (`VoucherID`),
  ADD KEY `BranchID` (`BranchID`),
  ADD KEY `CreatedBy` (`CreatedBy`);

--
-- Indexes for table `warehouses`
--
ALTER TABLE `warehouses`
  ADD PRIMARY KEY (`WarehouseId`),
  ADD KEY `fk_warehouse_branch_new` (`BranchId`);

--
-- Indexes for table `__efmigrationshistory`
--
ALTER TABLE `__efmigrationshistory`
  ADD PRIMARY KEY (`MigrationId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accountingtemplatelines`
--
ALTER TABLE `accountingtemplatelines`
  MODIFY `LineId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `accountingtemplates`
--
ALTER TABLE `accountingtemplates`
  MODIFY `TemplateId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `accountmappings`
--
ALTER TABLE `accountmappings`
  MODIFY `MappingId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `AccountID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=113;

--
-- AUTO_INCREMENT for table `barcodegenerator`
--
ALTER TABLE `barcodegenerator`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `branches`
--
ALTER TABLE `branches`
  MODIFY `BranchID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `companysettings`
--
ALTER TABLE `companysettings`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `currencies`
--
ALTER TABLE `currencies`
  MODIFY `CurrencyId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `CustomerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `drugcategories`
--
ALTER TABLE `drugcategories`
  MODIFY `CategoryId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `drugs`
--
ALTER TABLE `drugs`
  MODIFY `DrugID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=201;

--
-- AUTO_INCREMENT for table `drugtransferdetails`
--
ALTER TABLE `drugtransferdetails`
  MODIFY `DetailID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `drugtransfers`
--
ALTER TABLE `drugtransfers`
  MODIFY `TransferID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `drug_batches`
--
ALTER TABLE `drug_batches`
  MODIFY `BatchId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `EmployeeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `forecasts`
--
ALTER TABLE `forecasts`
  MODIFY `ForecastID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fundtransfers`
--
ALTER TABLE `fundtransfers`
  MODIFY `TransferID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `itemgroups`
--
ALTER TABLE `itemgroups`
  MODIFY `GroupId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- AUTO_INCREMENT for table `journaldetails`
--
ALTER TABLE `journaldetails`
  MODIFY `DetailID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=206;

--
-- AUTO_INCREMENT for table `journalentries`
--
ALTER TABLE `journalentries`
  MODIFY `JournalID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `legacy_shelves_backup`
--
ALTER TABLE `legacy_shelves_backup`
  MODIFY `ShelfId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `legacy_warehouses_backup`
--
ALTER TABLE `legacy_warehouses_backup`
  MODIFY `WarehouseId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchasedetails`
--
ALTER TABLE `purchasedetails`
  MODIFY `DetailID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=573;

--
-- AUTO_INCREMENT for table `purchaseplandetails`
--
ALTER TABLE `purchaseplandetails`
  MODIFY `DetailId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchaseplans`
--
ALTER TABLE `purchaseplans`
  MODIFY `PlanId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchases`
--
ALTER TABLE `purchases`
  MODIFY `PurchaseID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `saledetails`
--
ALTER TABLE `saledetails`
  MODIFY `SaleDetailID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=225770;

--
-- AUTO_INCREMENT for table `sales`
--
ALTER TABLE `sales`
  MODIFY `SaleID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sale_payments`
--
ALTER TABLE `sale_payments`
  MODIFY `PaymentId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44565;

--
-- AUTO_INCREMENT for table `screenpermissions`
--
ALTER TABLE `screenpermissions`
  MODIFY `PermissionID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seasonaldata`
--
ALTER TABLE `seasonaldata`
  MODIFY `SeasonalID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shelves`
--
ALTER TABLE `shelves`
  MODIFY `ShelfId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `stockauditdetails`
--
ALTER TABLE `stockauditdetails`
  MODIFY `DetailID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stockaudits`
--
ALTER TABLE `stockaudits`
  MODIFY `AuditID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stockmovements`
--
ALTER TABLE `stockmovements`
  MODIFY `MovementID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `SupplierID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `systemlogs`
--
ALTER TABLE `systemlogs`
  MODIFY `LogId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `systemnotifications`
--
ALTER TABLE `systemnotifications`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `systemscreens`
--
ALTER TABLE `systemscreens`
  MODIFY `ScreenID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT for table `units`
--
ALTER TABLE `units`
  MODIFY `UnitId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- AUTO_INCREMENT for table `userroles`
--
ALTER TABLE `userroles`
  MODIFY `RoleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `vouchers`
--
ALTER TABLE `vouchers`
  MODIFY `VoucherID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `warehouses`
--
ALTER TABLE `warehouses`
  MODIFY `WarehouseId` int(11) NOT NULL AUTO_INCREMENT;

--
-- قيود الجداول المُلقاة.
--

--
-- قيود الجداول `accountingtemplatelines`
--
ALTER TABLE `accountingtemplatelines`
  ADD CONSTRAINT `FK_AccountingTemplateLines_AccountingTemplates_TemplateId` FOREIGN KEY (`TemplateId`) REFERENCES `accountingtemplates` (`TemplateId`) ON DELETE CASCADE;

--
-- قيود الجداول `accountmappings`
--
ALTER TABLE `accountmappings`
  ADD CONSTRAINT `FK_AccountMappings_Accounts_AccountId` FOREIGN KEY (`AccountId`) REFERENCES `accounts` (`AccountID`) ON DELETE CASCADE;

--
-- قيود الجداول `accounts`
--
ALTER TABLE `accounts`
  ADD CONSTRAINT `FK_Accounts_Branches` FOREIGN KEY (`BranchId`) REFERENCES `branches` (`BranchID`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- قيود الجداول `barcodegenerator`
--
ALTER TABLE `barcodegenerator`
  ADD CONSTRAINT `fk_barcode_branch` FOREIGN KEY (`BranchId`) REFERENCES `branches` (`BranchID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_barcode_drug` FOREIGN KEY (`DrugId`) REFERENCES `drugs` (`DrugID`) ON DELETE CASCADE;

--
-- قيود الجداول `branches`
--
ALTER TABLE `branches`
  ADD CONSTRAINT `fk_branch_cash` FOREIGN KEY (`DefaultCashAccountId`) REFERENCES `accounts` (`AccountID`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_branch_cogs` FOREIGN KEY (`DefaultCOGSAccountId`) REFERENCES `accounts` (`AccountID`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_branch_currency` FOREIGN KEY (`DefaultCurrencyId`) REFERENCES `currencies` (`CurrencyId`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_branch_inv` FOREIGN KEY (`DefaultInventoryAccountId`) REFERENCES `accounts` (`AccountID`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_branch_sales` FOREIGN KEY (`DefaultSalesAccountId`) REFERENCES `accounts` (`AccountID`) ON DELETE SET NULL;

--
-- قيود الجداول `branchinventory`
--
ALTER TABLE `branchinventory`
  ADD CONSTRAINT `fk_branchinventory_branch` FOREIGN KEY (`BranchID`) REFERENCES `branches` (`BranchID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_branchinventory_drug` FOREIGN KEY (`DrugID`) REFERENCES `drugs` (`DrugID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_inventory_shelf` FOREIGN KEY (`ShelfId`) REFERENCES `legacy_shelves_backup` (`ShelfId`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- قيود الجداول `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`AccountID`) REFERENCES `accounts` (`AccountID`),
  ADD CONSTRAINT `fk_customers_branch` FOREIGN KEY (`BranchId`) REFERENCES `branches` (`BranchID`);

--
-- قيود الجداول `drugs`
--
ALTER TABLE `drugs`
  ADD CONSTRAINT `fk_drugs_category` FOREIGN KEY (`CategoryId`) REFERENCES `drugcategories` (`CategoryId`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_drugs_itemgroup` FOREIGN KEY (`GroupId`) REFERENCES `itemgroups` (`GroupId`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_drugs_unit` FOREIGN KEY (`UnitId`) REFERENCES `units` (`UnitId`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- قيود الجداول `drugtransferdetails`
--
ALTER TABLE `drugtransferdetails`
  ADD CONSTRAINT `drugtransferdetails_ibfk_1` FOREIGN KEY (`TransferID`) REFERENCES `drugtransfers` (`TransferID`) ON DELETE CASCADE,
  ADD CONSTRAINT `drugtransferdetails_ibfk_2` FOREIGN KEY (`DrugID`) REFERENCES `drugs` (`DrugID`);

--
-- قيود الجداول `drugtransfers`
--
ALTER TABLE `drugtransfers`
  ADD CONSTRAINT `drugtransfers_ibfk_1` FOREIGN KEY (`FromBranchID`) REFERENCES `branches` (`BranchID`),
  ADD CONSTRAINT `drugtransfers_ibfk_2` FOREIGN KEY (`ToBranchID`) REFERENCES `branches` (`BranchID`),
  ADD CONSTRAINT `drugtransfers_ibfk_3` FOREIGN KEY (`CreatedBy`) REFERENCES `users` (`UserID`),
  ADD CONSTRAINT `fk_dt_journal` FOREIGN KEY (`JournalId`) REFERENCES `journalentries` (`JournalID`),
  ADD CONSTRAINT `fk_dt_receiptjournal` FOREIGN KEY (`ReceiptJournalId`) REFERENCES `journalentries` (`JournalID`),
  ADD CONSTRAINT `fk_dt_receivedby` FOREIGN KEY (`ReceivedBy`) REFERENCES `users` (`UserID`);

--
-- قيود الجداول `drug_batches`
--
ALTER TABLE `drug_batches`
  ADD CONSTRAINT `fk_batch_drug` FOREIGN KEY (`DrugId`) REFERENCES `drugs` (`DrugID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- قيود الجداول `employees`
--
ALTER TABLE `employees`
  ADD CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`BranchID`) REFERENCES `branches` (`BranchID`);

--
-- قيود الجداول `forecasts`
--
ALTER TABLE `forecasts`
  ADD CONSTRAINT `forecasts_ibfk_1` FOREIGN KEY (`BranchID`) REFERENCES `branches` (`BranchID`) ON DELETE CASCADE,
  ADD CONSTRAINT `forecasts_ibfk_2` FOREIGN KEY (`DrugID`) REFERENCES `drugs` (`DrugID`) ON DELETE CASCADE;

--
-- قيود الجداول `fundtransfers`
--
ALTER TABLE `fundtransfers`
  ADD CONSTRAINT `fk_fund_branch` FOREIGN KEY (`BranchId`) REFERENCES `branches` (`BranchID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_fund_journal` FOREIGN KEY (`JournalId`) REFERENCES `journalentries` (`JournalID`) ON DELETE SET NULL,
  ADD CONSTRAINT `fundtransfers_ibfk_1` FOREIGN KEY (`FromAccountID`) REFERENCES `accounts` (`AccountID`),
  ADD CONSTRAINT `fundtransfers_ibfk_2` FOREIGN KEY (`ToAccountID`) REFERENCES `accounts` (`AccountID`),
  ADD CONSTRAINT `fundtransfers_ibfk_3` FOREIGN KEY (`CreatedBy`) REFERENCES `users` (`UserID`);

--
-- قيود الجداول `journaldetails`
--
ALTER TABLE `journaldetails`
  ADD CONSTRAINT `fk_journaldetails_account` FOREIGN KEY (`AccountID`) REFERENCES `accounts` (`AccountID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_journaldetails_journal` FOREIGN KEY (`JournalID`) REFERENCES `journalentries` (`JournalID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- قيود الجداول `journalentries`
--
ALTER TABLE `journalentries`
  ADD CONSTRAINT `fk_journalentries_branch` FOREIGN KEY (`BranchID`) REFERENCES `branches` (`BranchID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `journalentries_ibfk_1` FOREIGN KEY (`BranchID`) REFERENCES `branches` (`BranchID`),
  ADD CONSTRAINT `journalentries_ibfk_2` FOREIGN KEY (`CreatedBy`) REFERENCES `users` (`UserID`);

--
-- قيود الجداول `legacy_shelves_backup`
--
ALTER TABLE `legacy_shelves_backup`
  ADD CONSTRAINT `fk_shelf_itemgroup` FOREIGN KEY (`GroupId`) REFERENCES `itemgroups` (`GroupId`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_shelf_warehouse` FOREIGN KEY (`WarehouseId`) REFERENCES `legacy_warehouses_backup` (`WarehouseId`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- قيود الجداول `legacy_warehouses_backup`
--
ALTER TABLE `legacy_warehouses_backup`
  ADD CONSTRAINT `fk_warehouse_branch` FOREIGN KEY (`BranchId`) REFERENCES `branches` (`BranchID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- قيود الجداول `purchasedetails`
--
ALTER TABLE `purchasedetails`
  ADD CONSTRAINT `fk_purchasedetails_drug` FOREIGN KEY (`DrugID`) REFERENCES `drugs` (`DrugID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_purchasedetails_purchase` FOREIGN KEY (`PurchaseID`) REFERENCES `purchases` (`PurchaseID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- قيود الجداول `purchaseplandetails`
--
ALTER TABLE `purchaseplandetails`
  ADD CONSTRAINT `FK_purchaseplandetails_drugs_DrugId` FOREIGN KEY (`DrugId`) REFERENCES `drugs` (`DrugID`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_purchaseplandetails_purchaseplans_PlanId` FOREIGN KEY (`PlanId`) REFERENCES `purchaseplans` (`PlanId`) ON DELETE CASCADE;

--
-- قيود الجداول `purchaseplans`
--
ALTER TABLE `purchaseplans`
  ADD CONSTRAINT `FK_purchaseplans_branches_BranchId` FOREIGN KEY (`BranchId`) REFERENCES `branches` (`BranchID`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_purchaseplans_users_CreatedBy` FOREIGN KEY (`CreatedBy`) REFERENCES `users` (`UserID`) ON DELETE CASCADE;

--
-- قيود الجداول `purchases`
--
ALTER TABLE `purchases`
  ADD CONSTRAINT `fk_purchases_branch` FOREIGN KEY (`BranchID`) REFERENCES `branches` (`BranchID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_purchases_parent` FOREIGN KEY (`ParentPurchaseId`) REFERENCES `purchases` (`PurchaseID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_purchases_supplier` FOREIGN KEY (`SupplierId`) REFERENCES `suppliers` (`SupplierID`) ON UPDATE CASCADE;

--
-- قيود الجداول `saledetails`
--
ALTER TABLE `saledetails`
  ADD CONSTRAINT `fk_saledetails_drug` FOREIGN KEY (`DrugID`) REFERENCES `drugs` (`DrugID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_saledetails_sale` FOREIGN KEY (`SaleID`) REFERENCES `sales` (`SaleID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- قيود الجداول `sales`
--
ALTER TABLE `sales`
  ADD CONSTRAINT `fk_sales_branch` FOREIGN KEY (`BranchID`) REFERENCES `branches` (`BranchID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_sales_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `sales_ibfk_3` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`);

--
-- قيود الجداول `sale_payments`
--
ALTER TABLE `sale_payments`
  ADD CONSTRAINT `fk_sale_payments_account` FOREIGN KEY (`AccountId`) REFERENCES `accounts` (`AccountID`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_sale_payments_sale` FOREIGN KEY (`SaleId`) REFERENCES `sales` (`SaleID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- قيود الجداول `screenpermissions`
--
ALTER TABLE `screenpermissions`
  ADD CONSTRAINT `screenpermissions_ibfk_1` FOREIGN KEY (`RoleID`) REFERENCES `userroles` (`RoleID`) ON DELETE CASCADE,
  ADD CONSTRAINT `screenpermissions_ibfk_2` FOREIGN KEY (`ScreenID`) REFERENCES `systemscreens` (`ScreenID`) ON DELETE CASCADE;

--
-- قيود الجداول `seasonaldata`
--
ALTER TABLE `seasonaldata`
  ADD CONSTRAINT `seasonaldata_ibfk_1` FOREIGN KEY (`BranchID`) REFERENCES `branches` (`BranchID`) ON DELETE CASCADE,
  ADD CONSTRAINT `seasonaldata_ibfk_2` FOREIGN KEY (`DrugID`) REFERENCES `drugs` (`DrugID`) ON DELETE CASCADE;

--
-- قيود الجداول `shelves`
--
ALTER TABLE `shelves`
  ADD CONSTRAINT `fk_shelf_itemgroup_new` FOREIGN KEY (`GroupId`) REFERENCES `itemgroups` (`GroupId`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_shelf_warehouse_new` FOREIGN KEY (`WarehouseId`) REFERENCES `warehouses` (`WarehouseId`) ON DELETE CASCADE;

--
-- قيود الجداول `stockauditdetails`
--
ALTER TABLE `stockauditdetails`
  ADD CONSTRAINT `fk_audit_details_drug` FOREIGN KEY (`DrugID`) REFERENCES `drugs` (`DrugID`),
  ADD CONSTRAINT `fk_audit_details_main` FOREIGN KEY (`AuditID`) REFERENCES `stockaudits` (`AuditID`) ON DELETE CASCADE;

--
-- قيود الجداول `stockaudits`
--
ALTER TABLE `stockaudits`
  ADD CONSTRAINT `fk_audits_branch` FOREIGN KEY (`BranchID`) REFERENCES `branches` (`BranchID`),
  ADD CONSTRAINT `fk_audits_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`);

--
-- قيود الجداول `stockmovements`
--
ALTER TABLE `stockmovements`
  ADD CONSTRAINT `stockmovements_ibfk_1` FOREIGN KEY (`BranchID`) REFERENCES `branches` (`BranchID`) ON DELETE CASCADE,
  ADD CONSTRAINT `stockmovements_ibfk_2` FOREIGN KEY (`DrugID`) REFERENCES `drugs` (`DrugID`) ON DELETE CASCADE,
  ADD CONSTRAINT `stockmovements_ibfk_3` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`);

--
-- قيود الجداول `suppliers`
--
ALTER TABLE `suppliers`
  ADD CONSTRAINT `fk_suppliers_branch` FOREIGN KEY (`BranchId`) REFERENCES `branches` (`BranchID`),
  ADD CONSTRAINT `suppliers_ibfk_1` FOREIGN KEY (`AccountID`) REFERENCES `accounts` (`AccountID`);

--
-- قيود الجداول `systemlogs`
--
ALTER TABLE `systemlogs`
  ADD CONSTRAINT `systemlogs_ibfk_1` FOREIGN KEY (`UserId`) REFERENCES `users` (`UserID`);

--
-- قيود الجداول `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`RoleID`) REFERENCES `userroles` (`RoleID`),
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`EmployeeID`) REFERENCES `employees` (`EmployeeID`),
  ADD CONSTRAINT `users_ibfk_3` FOREIGN KEY (`DefaultBranchID`) REFERENCES `branches` (`BranchID`);

--
-- قيود الجداول `warehouses`
--
ALTER TABLE `warehouses`
  ADD CONSTRAINT `fk_warehouse_branch_new` FOREIGN KEY (`BranchId`) REFERENCES `branches` (`BranchID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
