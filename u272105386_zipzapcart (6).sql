-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 30, 2026 at 01:51 PM
-- Server version: 11.8.8-MariaDB-log
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u272105386_zipzapcart`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id`, `username`, `password`, `created_at`) VALUES
(1, 'admin', '$2y$10$Q8Yr7Eh.rOI694.ZQAiBBewU8grySNhUkO9vQ0uMa0q4sssSEXz0e', '2026-05-12 06:24:51');

-- --------------------------------------------------------

--
-- Table structure for table `appsetting`
--

CREATE TABLE `appsetting` (
  `id` int(11) NOT NULL,
  `cashbackper` int(100) NOT NULL,
  `supportnumber` varchar(20) DEFAULT NULL,
  `supportemail` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `appsetting`
--

INSERT INTO `appsetting` (`id`, `cashbackper`, `supportnumber`, `supportemail`, `created_at`) VALUES
(1, 0, '+918237556643', 'support@zipzapcart.com', '2026-06-12 15:01:24');

-- --------------------------------------------------------

--
-- Table structure for table `banners`
--

CREATE TABLE `banners` (
  `id` int(11) NOT NULL,
  `image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `banners`
--

INSERT INTO `banners` (`id`, `image`) VALUES
(2, 'uploads/banner3.webp'),
(3, 'uploads/banner4.webp'),
(5, 'uploads/banner5.webp');

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `variant_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`id`, `user_id`, `product_id`, `variant_id`, `quantity`, `created_at`) VALUES
(14, 13, 1, 1, 1, '2026-05-20 15:25:35'),
(16, 12, 1, 1, 1, '2026-05-22 02:24:37'),
(56, 15, 20, 0, 4, '2026-06-22 06:24:28');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `homecategory` enum('yes','no') DEFAULT 'no'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `image`, `homecategory`) VALUES
(1, 'Fashion', 'uploads/category/1.png', 'no'),
(2, 'Mobiles', 'uploads/category/2.png', 'yes'),
(3, 'Electronics', 'uploads/category/3.png', 'no'),
(4, 'Groceries', 'uploads/category/4.png', 'no'),
(5, 'Beauty', 'uploads/category/5.png', 'no'),
(6, 'Furniture', 'uploads/category/6.png', 'no'),
(7, 'Kitchen', 'uploads/category/7.png', 'no'),
(8, 'Shoes', 'uploads/category/8.png', 'no'),
(9, 'Watches', 'uploads/category/9.png', 'no'),
(10, 'Books', 'uploads/category/10.png', 'no');

-- --------------------------------------------------------

--
-- Table structure for table `coupons`
--

CREATE TABLE `coupons` (
  `id` int(11) NOT NULL,
  `code` varchar(50) DEFAULT NULL,
  `discount_type` enum('flat','percent') DEFAULT NULL,
  `discount_amount` decimal(10,2) DEFAULT NULL,
  `min_amount` decimal(10,2) DEFAULT 0.00,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delivery_boys`
--

CREATE TABLE `delivery_boys` (
  `id` int(11) NOT NULL,
  `seller_id` int(11) DEFAULT NULL,
  `name` varchar(150) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `aadhaar_number` varchar(50) DEFAULT NULL,
  `aadhaar_photo` text DEFAULT NULL,
  `pan_number` varchar(50) DEFAULT NULL,
  `pan_photo` text DEFAULT NULL,
  `profile_photo` text DEFAULT NULL,
  `vehicle_type` varchar(100) DEFAULT NULL,
  `vehicle_name` varchar(150) DEFAULT NULL,
  `vehicle_number` varchar(100) DEFAULT NULL,
  `vehicle_photo` text DEFAULT NULL,
  `driving_license_number` varchar(100) DEFAULT NULL,
  `driving_license_photo` text DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `wallet_balance` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `status` varchar(50) DEFAULT 'offline',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `delivery_boys`
--

INSERT INTO `delivery_boys` (`id`, `seller_id`, `name`, `phone`, `email`, `password`, `address`, `aadhaar_number`, `aadhaar_photo`, `pan_number`, `pan_photo`, `profile_photo`, `vehicle_type`, `vehicle_name`, `vehicle_number`, `vehicle_photo`, `driving_license_number`, `driving_license_photo`, `latitude`, `longitude`, `wallet_balance`, `is_active`, `status`, `created_at`, `updated_at`) VALUES
(1, 3, 'Rahul Kumar', '9876543210', 'rahul@gmail.com', 'boy123', 'Varanasi Uttar Pradesh', '123412341234', 'uploads/delivery/aadhaar.jpg', 'ABCDE1234F', 'uploads/delivery/pan.jpg', 'uploads/delivery/1.png', 'Bike', 'Honda Shine', 'UP65AB1234', 'uploads/delivery/bike.jpg', 'DL123456789', 'uploads/delivery/license.jpg', 25.3176, 82.9739, 0, 1, 'online', '2026-05-18 14:04:07', '2026-06-12 22:29:54');

-- --------------------------------------------------------

--
-- Table structure for table `delivery_boy_payouts`
--

CREATE TABLE `delivery_boy_payouts` (
  `id` int(11) NOT NULL,
  `delivery_boy_id` int(11) NOT NULL,
  `seller_id` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT 0,
  `payment_method` varchar(100) DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `note` text DEFAULT NULL,
  `status` varchar(50) DEFAULT 'paid',
  `payout_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `delivery_boy_payouts`
--

INSERT INTO `delivery_boy_payouts` (`id`, `delivery_boy_id`, `seller_id`, `amount`, `payment_method`, `transaction_id`, `note`, `status`, `payout_date`, `created_at`) VALUES
(1, 1, 1, 1, 'Cash', '', '', 'paid', '2026-05-30', '2026-05-30 07:47:56'),
(2, 1, 1, 0, 'Bank Transfer', '', '', 'paid', '2026-05-30', '2026-05-30 07:48:25');

-- --------------------------------------------------------

--
-- Table structure for table `onboarding_banners`
--

CREATE TABLE `onboarding_banners` (
  `id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `onboarding_banners`
--

INSERT INTO `onboarding_banners` (`id`, `title`, `image`, `created_at`) VALUES
(4, '1', 'uploads/onboarding/1779974241_Gemini_Generated_Image_2dhh6o2dhh6o2dhh.png', '2026-05-28 13:17:21'),
(5, '2', 'uploads/onboarding/1779974265_Gemini_Generated_Image_o7wc45o7wc45o7wc.png', '2026-05-28 13:17:45'),
(6, '3', 'uploads/onboarding/1779974410_Gemini_Generated_Image_feiea3feiea3feie.png', '2026-05-28 13:20:10');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `order_no` varchar(50) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `address_id` int(11) DEFAULT NULL,
  `coupon_code` varchar(50) DEFAULT NULL,
  `discount_amount` decimal(10,2) DEFAULT 0.00,
  `subtotal` decimal(10,2) DEFAULT 0.00,
  `total_amount` decimal(10,2) DEFAULT 0.00,
  `payment_method` enum('cod','online','wallet') DEFAULT NULL,
  `payment_status` enum('pending','paid') DEFAULT 'pending',
  `order_status` varchar(50) DEFAULT 'Placed',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `deliveryboy_id` int(11) DEFAULT 0,
  `delivery_otp` int(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `order_no`, `user_id`, `address_id`, `coupon_code`, `discount_amount`, `subtotal`, `total_amount`, `payment_method`, `payment_status`, `order_status`, `created_at`, `deliveryboy_id`, `delivery_otp`) VALUES
(14, 'ORD1781258166703', 10, 8, '', 0.00, 19998.99, 19999.99, 'cod', 'pending', 'Delivered', '2026-06-12 09:56:06', 1, 9999),
(15, 'ORD1781280537461', 10, 8, '', 0.00, 12499.00, 12500.00, 'cod', 'pending', 'Cancelled', '2026-06-12 16:08:57', 0, 7852),
(16, 'ORD1781289129757', 10, 8, '', 0.00, 24998.00, 25048.00, '', 'pending', 'Placed', '2026-06-12 18:32:09', 0, 5369),
(17, 'ORD1781289349736', 10, 8, '', 0.00, 12499.00, 12549.00, 'wallet', 'paid', 'Placed', '2026-06-12 18:35:49', 0, 7492),
(18, 'ORD1781292711768', 10, 8, '', 0.00, 12499.00, 12549.00, 'wallet', 'paid', 'Placed', '2026-06-12 19:31:51', 0, 2275),
(19, 'ORD1781292965894', 10, 8, '', 0.00, 12499.00, 12549.00, 'wallet', 'paid', 'Placed', '2026-06-12 19:36:05', 0, 8967),
(20, 'ORD1781293829976', 10, 8, '', 0.00, 12499.00, 12549.00, 'wallet', 'paid', 'Placed', '2026-06-12 19:50:29', 0, 8075),
(21, 'ORD1781294108866', 10, 8, '', 0.00, 12499.00, 12549.00, 'wallet', 'paid', 'Placed', '2026-06-12 19:55:08', 0, 5476),
(22, 'ORD1781294352219', 10, 8, '', 0.00, 12499.00, 12549.00, 'wallet', 'paid', 'Placed', '2026-06-12 19:59:12', 0, 7781),
(23, 'ORD1781294472299', 10, 8, '', 0.00, 12499.00, 12549.00, 'cod', 'pending', 'Cancelled', '2026-06-12 20:01:12', 0, 9367),
(24, 'ORD1781294732803', 10, 8, '', 0.00, 12499.00, 12549.00, 'cod', 'pending', 'Placed', '2026-06-12 20:05:32', 0, 2173),
(25, 'ORD1781294755353', 10, 8, '', 0.00, 12499.00, 12549.00, 'cod', 'pending', 'Cancelled', '2026-06-12 20:05:55', 0, 2773),
(26, 'ORD1781295161828', 10, 8, '', 0.00, 12499.00, 12549.00, 'cod', 'pending', 'Placed', '2026-06-12 20:12:41', 0, 2316),
(27, 'ORD1781295281517', 10, 8, '', 0.00, 12499.00, 12549.00, 'cod', 'pending', 'Placed', '2026-06-12 20:14:41', 0, 9025),
(28, 'ORD1781295392775', 10, 8, '', 0.00, 12499.00, 12549.00, 'cod', 'pending', 'Placed', '2026-06-12 20:16:32', 0, 9007),
(29, 'ORD1781296070537', 10, 8, '', 0.00, 12499.00, 12549.00, 'cod', 'pending', 'delivered', '2026-06-12 20:27:50', 0, 6477),
(30, 'ORD1781307310107', 10, 8, '', 0.00, 12499.00, 12549.00, 'cod', 'pending', 'Cancelled', '2026-06-12 23:35:10', 0, 5882),
(31, 'ORD1781370392151', 18, 9, '', 0.00, 12499.00, 12539.00, 'cod', 'pending', 'Cancelled', '2026-06-13 17:06:32', 0, 9667),
(32, 'ORD1781422059186', 10, 8, '', 0.00, 12499.00, 12549.00, 'wallet', 'paid', 'Placed', '2026-06-14 07:27:39', 0, 6771);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `variant_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `total` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `variant_id`, `quantity`, `price`, `total`) VALUES
(15, 14, 18, 0, 1, 19998.99, 19998.99),
(16, 15, 20, 0, 1, 12499.00, 12499.00),
(17, 16, 20, 0, 2, 12499.00, 24998.00),
(18, 17, 20, 0, 1, 12499.00, 12499.00),
(19, 18, 20, 0, 1, 12499.00, 12499.00),
(20, 19, 20, 0, 1, 12499.00, 12499.00),
(21, 20, 20, 0, 1, 12499.00, 12499.00),
(22, 21, 20, 0, 1, 12499.00, 12499.00),
(23, 22, 20, 0, 1, 12499.00, 12499.00),
(24, 23, 20, 0, 1, 12499.00, 12499.00),
(25, 24, 20, 0, 1, 12499.00, 12499.00),
(26, 25, 20, 0, 1, 12499.00, 12499.00),
(27, 26, 20, 0, 1, 12499.00, 12499.00),
(28, 27, 20, 0, 1, 12499.00, 12499.00),
(29, 28, 20, 0, 1, 12499.00, 12499.00),
(30, 29, 20, 0, 1, 12499.00, 12499.00),
(31, 30, 20, 0, 1, 12499.00, 12499.00),
(32, 31, 20, 0, 1, 12499.00, 12499.00),
(33, 32, 20, 0, 1, 12499.00, 12499.00);

-- --------------------------------------------------------

--
-- Table structure for table `posts`
--

CREATE TABLE `posts` (
  `id` int(11) NOT NULL,
  `seller_id` int(11) NOT NULL,
  `type` enum('text','image','video') NOT NULL,
  `text_content` longtext DEFAULT NULL,
  `media` varchar(500) DEFAULT NULL,
  `likes_count` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `posts`
--

INSERT INTO `posts` (`id`, `seller_id`, `type`, `text_content`, `media`, `likes_count`, `created_at`) VALUES
(1, 3, 'text', 'Welcome to our official store. New arrivals available now 🔥', NULL, 1, '2026-06-12 06:58:00'),
(2, 3, 'image', 'New collection launched today ✨', 'uploads/posts/banner3.webp', 1, '2026-06-12 06:58:00'),
(3, 3, 'image', 'Special discount for this week only ❤️', 'uploads/posts/banner4.webp', 64, '2026-06-12 06:58:00'),
(4, 3, 'video', 'Watch our latest product demo', 'uploads/posts/1.mp4', 1, '2026-06-12 06:58:00'),
(5, 3, 'text', 'Thank you for supporting our business 🙏', NULL, 1, '2026-06-12 06:58:00'),
(6, 3, 'text', 'TEST', '', 0, '2026-06-12 22:45:20'),
(12, 3, 'video', 'TEST', 'uploads/posts/17813047904205.mp4', 1, '2026-06-12 22:53:10'),
(13, 3, 'image', 'TEST', 'uploads/posts/17813048313243.jpg', 1, '2026-06-12 22:53:51'),
(14, 6, 'image', 'Top Dealer', 'uploads/posts/17820239029610.jpg', 1, '2026-06-21 06:38:22');

-- --------------------------------------------------------

--
-- Table structure for table `post_comments`
--

CREATE TABLE `post_comments` (
  `id` int(11) NOT NULL,
  `post_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `post_comments`
--

INSERT INTO `post_comments` (`id`, `post_id`, `user_id`, `comment`, `created_at`) VALUES
(10, 5, 1, 'wonderful', '2026-06-12 08:48:24'),
(11, 5, 10, 'thh', '2026-06-12 16:50:43'),
(12, 4, 10, 'hh', '2026-06-12 16:57:30');

-- --------------------------------------------------------

--
-- Table structure for table `post_likes`
--

CREATE TABLE `post_likes` (
  `id` int(11) NOT NULL,
  `post_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `post_likes`
--

INSERT INTO `post_likes` (`id`, `post_id`, `user_id`, `created_at`) VALUES
(17, 1, 10, '2026-06-12 08:51:17'),
(30, 5, 10, '2026-06-12 16:54:18'),
(31, 4, 10, '2026-06-12 16:57:23'),
(33, 12, 10, '2026-06-12 23:36:14'),
(35, 2, 10, '2026-06-12 23:36:32'),
(36, 13, 10, '2026-06-12 23:36:39'),
(37, 14, 18, '2026-06-21 06:39:27');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `seller_id` int(11) NOT NULL,
  `cat_id` int(11) NOT NULL,
  `subcat_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `rate` decimal(10,2) DEFAULT 0.00,
  `saleprice` decimal(10,2) DEFAULT 0.00,
  `image` varchar(255) DEFAULT NULL,
  `other_images` longtext DEFAULT NULL,
  `topdeals` enum('yes','no') DEFAULT 'no',
  `bestseller` enum('yes','no') DEFAULT 'no',
  `recommended` enum('yes','no') DEFAULT 'no',
  `hasvarients` enum('yes','no') DEFAULT 'no',
  `product_description` longtext DEFAULT NULL,
  `stock` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `seller_id`, `cat_id`, `subcat_id`, `name`, `rate`, `saleprice`, `image`, `other_images`, `topdeals`, `hasvarients`, `product_description`, `stock`, `created_at`) VALUES
(16, 5, 2, 33, 'Poco C85 5G Power Black 8GB RAM 128GB ROM', 16999.00, 16899.00, 'uploads/products/1781195417_1[1].jpeg', 'uploads/products/17811954174797_2[1].jpeg', 'no', 'no', 'Operating System	Android 15, Xiaomi HyperOS\r\nRAM Memory Installed	8 GB\r\nProcessor Series	Mediatek Dimensity 6300\r\nProcessor Speed	2.2 GHz\r\nMemory Storage Capacity	128 GB\r\nColour	Spring Green\r\nSIM Card Slot Count	Single SIM\r\nConnector Type	USB Type C\r\nForm Factor	Bar\r\nBiometric Security Feature	Fingerprint Recognition\r\nSim Card Size	Nano\r\nWater Resistance Level	Water Resistant\r\nHeadphones Jack	[Unknown]', 100, '2026-06-11 16:30:17'),
(17, 3, 2, 33, 'realme P4x 5G Smartphone, Lake Green, 6GB RAM, 128GB Storage', 21999.00, 19689.00, 'uploads/products/1781195528_1[1].jpeg', 'uploads/products/17811955284669_2[1].jpeg', 'no', 'no', 'Operating System	Android\r\nRAM Memory Installed	6 GB\r\nProcessor Series	Mediatek Dimensity 8000\r\nProcessor Speed	2.6 Hz\r\nMemory Storage Capacity	128 GB\r\nColour	Lake Green\r\nSIM Card Slot Count	Dual SIM\r\nConnector Type	USB Type C\r\nForm Factor	Smartphone\r\nBiometric Security Feature	Fingerprint Recognition\r\nHuman Interface Types	Touchscreen\r\nSim Card Size	Nano\r\nWater Resistance Level	Water Repellent\r\nHeadphones Jack	3.5 mm\r\nCompatible Devices	5g Networks\r\nSpecific Absorption Rate	1.6 Watts per Kilogram\r\nProduct Features	TRIPLE CAMERA\r\nFlash Memory Supported Size Maximum	1024 GB', 0, '2026-06-11 16:32:08'),
(18, 3, 2, 33, 'realme narzo 90 5G (Flowing Silver,8GB+128GB) | 7000mAh Biggest Battery | 60W Fastest Charging | 50MP Front & Rear AI Cameras | 4000nits Brightest Display | AI Assist | IP69 Dust & Water Resistance', 19999.00, 19998.99, 'uploads/products/1781195599_1[1].jpeg', 'uploads/products/17811955993336_2[1].jpeg', 'yes', 'no', '7000mAh Biggest Battery & 60W Fastest Charging: 7000mAh Titan Battery with 60W Fast Charging delivers the segment’s biggest power backup. Get up to 50% charge in just 31 minutes—power up fast and play without pauses.\r\n6-Year Long-Lasting Battery Life: Built for longevity, the battery stays healthy even after years of heavy use. After 1600 charge cycles (~6 years), it still retains over 80% capacity.\r\nDual 50MP Camera: India’s only smartphone with a dual 50MP AI camera system. Capture ultra-clear portraits and scenes with advanced AI clarity and beauty algorithms.\r\n4000nits AMOLED Display: 4000nits AMOLED Sunlight Display delivers vivid clarity even under harsh sunlight. Enjoy 1.07 billion colors with 2160Hz PWM dimming for comfortable, lifelike viewing.\r\nIP66/68/69 Dust & Water Resistance: The realme NARZO 90 5G provides top-tier all-weather durability with IP66/68/69 dust and water resistance—ensuring unmatched reliability and confidence in any environment.', 100, '2026-06-11 16:33:19'),
(19, 3, 2, 33, 'realme NARZO 90x 5G (Flash Blue 2026, 6GB+128GB) | 7000mAh + 60W Biggest Battery & Fastest Charging in the Segment* | 144Hz Bright Display | Sony 50MP AI Rear Camera | 400% Ultra Boom Speaker', 33999.00, 19499.00, 'uploads/products/1781195815_1[1].jpeg', 'uploads/products/17811958151918_2[1].jpeg', 'yes', 'no', '7000mAh Titan Battery + 60W Fast Charge: Massive 7000mAh battery delivers all-day power even at 50% charge. Get 50% in just 35 minutes with 60W fast charging—no battery anxiety.\r\n6-Year Long-Lasting Battery Life: Stay connected even at 1% with hours of standby and call time. 6-Year Health Battery with anti-aging tech ensures long-term durability.\r\n144Hz 1200nit Ultra Bright Display: Enjoy ultra-smooth visuals on a 144Hz display with 1200nit brightness. Wet-Hand Touch and eye-care modes ensure comfort in every condition.\r\nSony 50MP AI Rear Camera: Capture sharp, detailed shots with the 50MP Sony AI main camera. Dual-View Video and AI selfies bring creativity to every moment.\r\nAI Edit Genie & Smart AI Modes: Edit photos instantly—just describe and let AI do the magic. Smarter outdoor performance with boosted smoothness, network, and brightness.', 0, '2026-06-11 16:36:55'),
(20, 3, 2, 33, 'Samsung Galaxy M06 5G Mobile (Blazing Black, 4GB RAM, 64GB Storage) | MediaTek Dimensity 6300 | AnTuTu 623K+ | 12 5G Bands | 25W Fast Charging | 4 Gen OS Upgrades | 50MP Camera | Without Charger', 14999.00, 12499.00, 'uploads/products/1781196208_1[1].jpeg', 'uploads/products/17811962085020_2[1].jpeg', 'yes', 'no', 'Monster Processor - Segment Leading MediaTek Dimensity 6300, AnTuTu score 623K+, Latest Android 15 Operating System having One UI 7.0 platform, 2.4GHz, 2GHz Clock Speed with Octa-Core Processor, Upto 6GB of RAM\r\nMonster 5G Experience - Complete 5G experience with 12 5G Bands (among the highest in the segment), All Network Support, Faster Download and Upload Speed on your mobile.\r\nMonster Design, Camera and Display - Refreshing design with new Linear camera deco, Slimmer with just 8.0 mm thickness, 50MP (F1.8) Main Wide Angle Camera + 2MP Depth Camera, 8MP (F2.0) Selfie Camera | Video Maximum Resolution of FHD (1920 x 1080) at 30fps.\r\nMonster Security and OS Upgrades - Knox Security with segment leading smartphone with 4 Generations of Android OS Upgrades and 4 Years of Security Updates to keep your phone updated with all latest software developments. Come with Android 14 Operating System having One UI 6 platform.\r\nMonster Battery - Get a massive 5000mAh Lithium-ion Battery (Non-Removable) with Segment leading Fast Charging 25W Support. Get more power in less time', 100, '2026-06-11 16:43:28'),
(22, 6, 2, 33, 'DEMO', 19999.00, 18999.00, 'uploads/products/1782023401_17820233034503812762089200526147.jpg', 'uploads/products/17820234012889_1782023311165303505416338057248.jpg', 'no', 'yes', 'Demo', 2, '2026-06-21 06:30:01'),
(23, 6, 2, 33, 'Demo 2', 49999.00, 45999.00, 'uploads/products/1782023549_1782023490342333990961262540430.jpg', 'uploads/products/17820235499430_17820234972567130619584769223443.jpg', 'yes', 'yes', 'Demo 2', 5, '2026-06-21 06:32:29');

-- --------------------------------------------------------

--
-- Table structure for table `product_reviews`
--

CREATE TABLE `product_reviews` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `rating` float(2,1) DEFAULT 0.0,
  `review` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_reviews`
--

INSERT INTO `product_reviews` (`id`, `user_id`, `product_id`, `rating`, `review`, `created_at`) VALUES
(1, 1, 1, 4.0, 'hhh', '2026-05-18 09:59:12'),
(2, 15, 1, 5.0, 'nice', '2026-05-29 17:30:25'),
(3, 16, 1, 5.0, 'wow ', '2026-06-02 07:43:14');

-- --------------------------------------------------------

--
-- Table structure for table `product_varients`
--

CREATE TABLE `product_varients` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `varient_name` varchar(255) NOT NULL,
  `rate` decimal(10,2) DEFAULT 0.00,
  `salerate` decimal(10,2) DEFAULT 0.00,
  `product_description` longtext DEFAULT NULL,
  `stock` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_varients`
--

INSERT INTO `product_varients` (`id`, `product_id`, `varient_name`, `rate`, `salerate`, `product_description`, `stock`, `created_at`) VALUES
(20, 22, '12/256', 24999.00, 23999.00, '\r\n                Demo', 2, '2026-06-21 06:30:01'),
(23, 23, '12/256', 55999.00, 55999.00, '     Other      Demo2 ', 2, '2026-06-21 06:33:39'),
(24, 23, '12/512', 80000.00, 80000.00, '        More    Demo2    ', 2, '2026-06-21 06:33:39');

-- --------------------------------------------------------

--
-- Table structure for table `razorpay_settings`
--

CREATE TABLE `razorpay_settings` (
  `id` int(11) NOT NULL,
  `razorpay_key` varchar(255) DEFAULT NULL,
  `razorpay_secret` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `razorpay_settings`
--

INSERT INTO `razorpay_settings` (`id`, `razorpay_key`, `razorpay_secret`, `created_at`, `updated_at`) VALUES
(1, 'rzp_live_Sp8JROA7JcLJaX', 'qZuO30Y4wmEL5ksj25zqj3Nj', '2026-05-16 05:00:11', '2026-05-18 13:11:31');

-- --------------------------------------------------------

--
-- Table structure for table `requested_pincodes`
--

CREATE TABLE `requested_pincodes` (
  `id` int(11) NOT NULL,
  `city` varchar(100) DEFAULT NULL,
  `pincode` varchar(10) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seller`
--

CREATE TABLE `seller` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `service_pincodes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `seller`
--

INSERT INTO `seller` (`id`, `name`, `username`, `password`, `phone`, `email`, `address`, `service_pincodes`, `created_at`) VALUES
(3, 'Zipzapcart', 'zipzapcart', '$2y$10$aNzFTyIGhwaA/OejoshRbepY4AhCAPa9CDvptVdgHlx96ZDgoJkOC', '123456789', 'zenvora@gmail.com', 'DELHI', '201013,201014,201310,211001,211003,211006,211016', '2026-05-04 16:27:08'),
(5, 'Zipzapcart', 'zipzapcart2', '$2y$10$Q8Yr7Eh.rOI694.ZQAiBBewU8grySNhUkO9vQ0uMa0q4sssSEXz0e', '123456789', 'zenvora@gmail.com', 'DELHI', '201013,201014,201310,211001,211003,211006,211016', '2026-05-04 16:27:08'),
(6, 'Amay Mobile', 'Amay123', '$2y$10$l9OIyY5jzY40MHMnz5mWKOnQDYpgHemTUh/GpqUhH2uCg/SYCm2h6', '8180012550', 'gurujigawande140@gmail.com', 'Ansing', '245101,245205,245301,245304', '2026-06-19 05:08:19'),
(7, 'TEST', 'test', '$2y$10$7CYzq/lbbmDk/ZPZntSWZ.rT7.mEMbCcfRQjUl0xWO0t1.1plTTg.', '1234567890', 'student@demo.com', 'Hhaha', '110001,201001', '2026-06-19 07:22:52');

-- --------------------------------------------------------

--
-- Table structure for table `seller_payouts`
--

CREATE TABLE `seller_payouts` (
  `id` int(11) NOT NULL,
  `seller_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `reference_no` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `payment_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `service_pincodes`
--

CREATE TABLE `service_pincodes` (
  `id` int(11) NOT NULL,
  `pincode` varchar(10) DEFAULT NULL,
  `delivery_charge` int(100) NOT NULL DEFAULT 50
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `service_pincodes`
--

INSERT INTO `service_pincodes` (`id`, `pincode`, `delivery_charge`) VALUES
(1, '211001', 50),
(2, '221001', 50),
(3, '110001', 50),
(4, '201001', 50),
(5, '201002', 50),
(6, '201003', 50),
(7, '201004', 50),
(8, '201005', 50),
(9, '201006', 50),
(10, '201007', 50),
(11, '201009', 50),
(12, '201010', 50),
(13, '201011', 50),
(14, '201012', 50),
(15, '201013', 50),
(16, '201102', 50),
(17, '201201', 50),
(18, '201204', 50),
(19, '201206', 50),
(20, '201302', 50),
(21, '245101', 50),
(22, '245205', 50),
(23, '245207', 50),
(24, '245301', 50),
(25, '245304', 50),
(26, '201014', 50),
(27, '201310', 50),
(28, '211003', 50),
(29, '211016', 50),
(30, '211006', 50),
(31, '444505', 40),
(32, '321001', 2);

-- --------------------------------------------------------

--
-- Table structure for table `splash`
--

CREATE TABLE `splash` (
  `id` int(11) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `splash`
--

INSERT INTO `splash` (`id`, `image`, `created_at`) VALUES
(1, 'uploads/splash.png', '2026-05-18 16:54:55');

-- --------------------------------------------------------

--
-- Table structure for table `subcategories`
--

CREATE TABLE `subcategories` (
  `id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subcategories`
--

INSERT INTO `subcategories` (`id`, `category_id`, `name`, `image`) VALUES
(1, 1, 'Mens Wear', 'uploads/subcategory/1779139239_images (2).jpg'),
(2, 1, 'Womens Wear', 'uploads/subcategory/1779139215_images (1).jpg'),
(3, 1, 'Kids Fashion', 'uploads/subcategory/1779139188_images.jpg'),
(33, 2, 'Mobiles', 'uploads/subcategory/1781194974_Modern_Multi_Phone_Mockup_Template_With_Customizable_Smart_Objects_high_resolution_preview_2693011.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `referral_code` varchar(20) DEFAULT NULL,
  `sponsor_code` varchar(20) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `gender` enum('male','female','other') DEFAULT NULL,
  `photo` text DEFAULT NULL,
  `firebase_uid` varchar(255) DEFAULT NULL,
  `login_type` enum('phone','google') DEFAULT 'phone',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `paidstatus` enum('free','paid') DEFAULT 'free',
  `wallet_balance` int(100) NOT NULL,
  `startdate` date DEFAULT NULL,
  `enddate` date DEFAULT NULL,
  `fcm_token` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `phone`, `email`, `referral_code`, `sponsor_code`, `name`, `photo`, `firebase_uid`, `login_type`, `is_active`, `created_at`, `updated_at`, `paidstatus`, `wallet_balance`, `startdate`, `enddate`, `fcm_token`) VALUES
(10, '8887812068', NULL, '59EDADC5', '0017145D', 'Ateet khare', NULL, NULL, 'phone', 1, '2026-05-18 08:48:17', '2026-06-14 07:27:39', 'free', 212157, NULL, NULL, 'daGuTmHIT1ue55HOJCkL8H:APA91bHdSPQ_wMtEsfMQVPpxVV4Tu4wYLOcokDY9tdxW4B7YoN6P4rs2FR-Szr_P_lYqlGaglPIZZUa8QZ87cBdeI21iKN4kpL5lipbc9f7c2X9vEcNGTf8'),
(11, '9235383134', NULL, '0017145D', '', 'Ateet Khare', NULL, NULL, 'phone', 1, '2026-05-18 08:55:25', '2026-05-18 08:55:40', 'free', 0, NULL, NULL, NULL),
(12, '8369741156', NULL, '17DB3BE5', '', 'Kiran Jagushte ', NULL, NULL, 'phone', 1, '2026-05-19 11:34:10', '2026-05-19 11:34:23', 'free', 0, NULL, NULL, NULL),
(13, '9082999351', NULL, 'CDAD32E2', '', 'pravin', NULL, NULL, 'phone', 1, '2026-05-20 03:12:02', '2026-05-20 03:12:21', 'free', 0, NULL, NULL, NULL),
(14, '7976708564', NULL, 'C51B5FDB', '', 'Gaurav Sharma', NULL, NULL, 'phone', 1, '2026-05-22 12:43:54', '2026-05-28 14:46:56', 'free', 0, NULL, NULL, NULL),
(15, '7976160206', NULL, '37A5A91B', '', 'khushi ', NULL, NULL, 'phone', 1, '2026-05-29 17:29:40', '2026-06-21 09:51:46', 'free', 0, NULL, NULL, 'd-iIPqGkQX29LG22umwNuK:APA91bFG9dYLwNToVC3i4LUdfT2VO7OBMih91IhgFb50XgDaaIKVFOJTfEdKxGZRklf4Qbcaiuo7REz_87RMZvo9uThLaYVpxMAdiwVhr5YJxcES7c5Ye4w'),
(16, '9883938011', NULL, '5DF3385F', '', 'royal', NULL, NULL, 'phone', 1, '2026-05-31 12:40:09', '2026-05-31 12:40:22', 'free', 0, NULL, NULL, NULL),
(17, '9264166786', NULL, '37E6D111', '', 'Blind Love', NULL, NULL, 'phone', 1, '2026-06-01 10:57:13', '2026-06-01 11:01:27', 'free', 0, NULL, NULL, NULL),
(18, '8180012550', NULL, '71F9677C', '', 'Gaurav Gawande', NULL, NULL, 'phone', 1, '2026-06-13 06:57:47', '2026-06-16 11:04:47', 'free', 0, NULL, NULL, 'edHYUXCySzOr34b18S5Plx:APA91bHMOSJ1akpJlkKRSAobDKHpeXX0YibYrKsnSq_DqxtNLd2fuzyFx40Y8lDa8Nm6Z6yGPW6QSsU26WurR6ueS-eTOHsSZDgUKGQilM2m-4FG7iaKpxk'),
(19, '9326627079', NULL, 'D42FCF46', '', 'Vighnesh Bhande ', NULL, NULL, 'phone', 1, '2026-06-28 06:37:44', '2026-06-28 06:37:59', 'free', 0, NULL, NULL, 'eqFe0R8ZRxuIZdVQ9b7UsP:APA91bE4nyy3xqw1B6YGsNBfnmNFpTPrFhkJdnvCwM8R8oxr7YkUb1sKqc8moaIt8mlbwFLuUT-I3P4fcpKjcaJ-_rMmYHFztopJCWZF_vLyQCCOY0yxehw');

-- --------------------------------------------------------

--
-- Table structure for table `user_addresses`
--

CREATE TABLE `user_addresses` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `pincode` varchar(20) DEFAULT NULL,
  `is_default` enum('yes','no') DEFAULT 'no',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `latitude` varchar(50) DEFAULT NULL,
  `longitude` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_addresses`
--

INSERT INTO `user_addresses` (`id`, `user_id`, `full_name`, `mobile`, `address`, `city`, `state`, `pincode`, `is_default`, `created_at`, `latitude`, `longitude`) VALUES
(7, 10, 'ATEET KHARE', '8887812068', 'ahahhah', 'Prayagraj', 'Uttar Pradesh', '211001', 'no', '2026-06-12 09:42:30', '25.4448388', '81.8146218'),
(8, 10, 'ATEET KHARE', '7236989565', 'hhhhh', 'Prayagraj', 'Uttar Pradesh', '211001', 'yes', '2026-06-12 09:43:02', '25.4448446', '81.8146564'),
(9, 18, 'Gaurav Gawande', '8180012550', 'shivpratap Nagar washim', 'Washim', 'Maharashtra', '444505', 'yes', '2026-06-13 08:42:15', '20.1168274', '77.1439323');

-- --------------------------------------------------------

--
-- Table structure for table `user_cashback`
--

CREATE TABLE `user_cashback` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `cashback_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `order_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `from_user_name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `transferred` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_cashback`
--

INSERT INTO `user_cashback` (`id`, `user_id`, `cashback_amount`, `order_amount`, `from_user_name`, `created_at`, `transferred`) VALUES
(2, 10, 100.00, 1000.00, 'Ateet2', '2026-06-12 18:07:33', 1);

-- --------------------------------------------------------

--
-- Table structure for table `user_notifications`
--

CREATE TABLE `user_notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `notification_text` text DEFAULT NULL,
  `is_read` enum('yes','no') DEFAULT 'no',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_notifications`
--

INSERT INTO `user_notifications` (`id`, `user_id`, `notification_text`, `is_read`, `created_at`) VALUES
(1, 10, 'Test Notification', 'no', '2026-06-12 15:07:00');

-- --------------------------------------------------------

--
-- Table structure for table `user_refund`
--

CREATE TABLE `user_refund` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `order_no` varchar(100) NOT NULL,
  `refund_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `source` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_refund`
--

INSERT INTO `user_refund` (`id`, `user_id`, `order_no`, `refund_amount`, `source`, `created_at`) VALUES
(2, 10, 'ORD1781258166703', 100.00, 'UPI', '2026-06-12 18:14:26');

-- --------------------------------------------------------

--
-- Table structure for table `wishlist`
--

CREATE TABLE `wishlist` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wishlist`
--

INSERT INTO `wishlist` (`id`, `user_id`, `product_id`, `created_at`) VALUES
(21, 10, 20, '2026-06-12 16:25:51'),
(22, 10, 18, '2026-06-12 23:38:46');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `appsetting`
--
ALTER TABLE `appsetting`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `banners`
--
ALTER TABLE `banners`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `coupons`
--
ALTER TABLE `coupons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delivery_boys`
--
ALTER TABLE `delivery_boys`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delivery_boy_payouts`
--
ALTER TABLE `delivery_boy_payouts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `onboarding_banners`
--
ALTER TABLE `onboarding_banners`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `post_comments`
--
ALTER TABLE `post_comments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `post_likes`
--
ALTER TABLE `post_likes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_varients`
--
ALTER TABLE `product_varients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `razorpay_settings`
--
ALTER TABLE `razorpay_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `requested_pincodes`
--
ALTER TABLE `requested_pincodes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `seller`
--
ALTER TABLE `seller`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `seller_payouts`
--
ALTER TABLE `seller_payouts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `service_pincodes`
--
ALTER TABLE `service_pincodes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `splash`
--
ALTER TABLE `splash`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `subcategories`
--
ALTER TABLE `subcategories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `referral_code` (`referral_code`);

--
-- Indexes for table `user_addresses`
--
ALTER TABLE `user_addresses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_cashback`
--
ALTER TABLE `user_cashback`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `user_notifications`
--
ALTER TABLE `user_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `user_refund`
--
ALTER TABLE `user_refund`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `order_id` (`order_no`);

--
-- Indexes for table `wishlist`
--
ALTER TABLE `wishlist`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `appsetting`
--
ALTER TABLE `appsetting`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `banners`
--
ALTER TABLE `banners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `coupons`
--
ALTER TABLE `coupons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delivery_boys`
--
ALTER TABLE `delivery_boys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `delivery_boy_payouts`
--
ALTER TABLE `delivery_boy_payouts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `onboarding_banners`
--
ALTER TABLE `onboarding_banners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `posts`
--
ALTER TABLE `posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `post_comments`
--
ALTER TABLE `post_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `post_likes`
--
ALTER TABLE `post_likes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `product_reviews`
--
ALTER TABLE `product_reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `product_varients`
--
ALTER TABLE `product_varients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `razorpay_settings`
--
ALTER TABLE `razorpay_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `requested_pincodes`
--
ALTER TABLE `requested_pincodes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seller`
--
ALTER TABLE `seller`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `seller_payouts`
--
ALTER TABLE `seller_payouts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `service_pincodes`
--
ALTER TABLE `service_pincodes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `splash`
--
ALTER TABLE `splash`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `subcategories`
--
ALTER TABLE `subcategories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `user_addresses`
--
ALTER TABLE `user_addresses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `user_cashback`
--
ALTER TABLE `user_cashback`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user_notifications`
--
ALTER TABLE `user_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_refund`
--
ALTER TABLE `user_refund`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `wishlist`
--
ALTER TABLE `wishlist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `product_varients`
--
ALTER TABLE `product_varients`
  ADD CONSTRAINT `product_varients_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `subcategories`
--
ALTER TABLE `subcategories`
  ADD CONSTRAINT `subcategories_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
