-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 23, 2026 at 12:55 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `carwash_app`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `customer_email` varchar(100) NOT NULL,
  `service_name` varchar(100) NOT NULL,
  `location` varchar(255) NOT NULL,
  `notes` text DEFAULT NULL,
  `booking_date` date NOT NULL,
  `booking_time` time NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `car_id` int(11) NOT NULL,
  `team_id` int(11) DEFAULT NULL,
  `status` enum('pending','assigned','completed','rejected','cancelled') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `customer_email`, `service_name`, `location`, `notes`, `booking_date`, `booking_time`, `created_at`, `car_id`, `team_id`, `status`) VALUES
(11, 'ahmad.customer@gmail.com', 'Steam Car Wash', 'alersal', '', '2026-01-30', '16:20:00', '2026-01-16 12:29:54', 15, NULL, 'rejected'),
(12, 'lara@gmail.com', 'VIP Car Wash', 'almasyon', '', '2026-01-16', '23:20:00', '2026-01-16 21:11:53', 16, 9, 'completed'),
(20, 'd@gmail.com', 'Normal Car Wash', 'rrrrrrrrrrrrrrrrr', 'fsds', '2026-01-23', '05:52:00', '2026-01-20 04:52:31', 24, 9, 'cancelled'),
(21, 'd@gmail.com', 'Normal Car Wash', 'gsf', 'gsf', '2026-01-30', '04:11:00', '2026-01-20 05:11:33', 25, 9, 'cancelled'),
(22, 'd@gmail.com', 'Normal Car Wash', 'fs', 'hdg', '2026-01-22', '04:22:00', '2026-01-20 05:22:52', 26, 9, 'cancelled'),
(23, 'd@gmail.com', 'Steam Car Wash', 'sssssssssssss', 'gf', '2026-01-22', '04:20:00', '2026-01-20 05:25:59', 27, 9, 'cancelled'),
(24, 'deema@gmail.com', 'Normal Car Wash', 'ramallah', 'gsft', '2026-01-23', '04:32:00', '2026-01-20 05:32:45', 28, 9, 'completed'),
(40, 'deema@gmail.com', 'VIP Car Wash', 'ramallah', 'gdf', '2026-01-22', '05:50:00', '2026-01-20 05:50:52', 44, 9, 'pending'),
(41, 'deema@gmail.com', 'Normal Car Wash', 'ramallah', 'gdf', '2026-01-20', '07:00:00', '2026-01-20 05:53:52', 45, 9, 'pending'),
(42, 'deema@gmail.com', 'Steam Car Wash', 'ramallah', 'gdf', '2026-01-20', '07:00:00', '2026-01-20 05:54:21', 46, 10, 'pending'),
(43, 'd@gmail.com', 'Normal Car Wash', 'ramallah', 'fdgd', '2026-01-20', '07:00:00', '2026-01-20 05:56:56', 47, 11, 'cancelled'),
(44, 'deema@gmail.com', 'Normal Car Wash', 'ramallah', '534', '2026-01-20', '08:07:00', '2026-01-20 06:08:58', 48, 9, 'pending'),
(45, 'deema@gmail.com', 'Normal Car Wash', 'dfd', 'ramalha', '2026-01-20', '05:12:00', '2026-01-20 06:12:19', 49, 9, 'assigned'),
(46, 'deema@gmail.com', 'VIP Car Wash', 'fhhsb', '', '2023-03-28', '07:15:00', '2026-01-23 11:31:49', 50, 9, 'cancelled');

-- --------------------------------------------------------

--
-- Table structure for table `cars`
--

CREATE TABLE `cars` (
  `car_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `car_model` varchar(50) NOT NULL,
  `car_plate` varchar(20) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cars`
--

INSERT INTO `cars` (`car_id`, `user_id`, `car_model`, `car_plate`, `created_at`) VALUES
(12, 17, 'aaaaaaaaaa', 'aaaaaaaaaaaaaa', '2026-01-06 08:05:27'),
(13, 17, 'laa', 'laa', '2026-01-06 08:16:37'),
(14, 17, '11111111111111', '11111111111', '2026-01-06 08:30:37'),
(15, 52, 'bmw', '097467143', '2026-01-16 14:29:54'),
(16, 11, 'mercedes', 'ghl-4578', '2026-01-16 23:11:53'),
(24, 53, 'rsfd', '524368', '2026-01-20 06:52:31'),
(25, 53, 'fsr', '52336', '2026-01-20 07:11:33'),
(26, 53, '5342', '5342', '2026-01-20 07:22:52'),
(27, 53, '5234', 'fssssssssssss', '2026-01-20 07:25:59'),
(28, 17, 'fsdrs', '5243', '2026-01-20 07:32:45'),
(44, 17, 'fstd', '534', '2026-01-20 07:50:52'),
(45, 17, 'gdfd', '534', '2026-01-20 07:53:51'),
(46, 17, '5364', 'gdt', '2026-01-20 07:54:21'),
(47, 53, 'gsf', '534267', '2026-01-20 07:56:56'),
(48, 17, 'gdfdt', 'ABC123', '2026-01-20 08:08:58'),
(49, 17, 'gdft', '12xyz12', '2026-01-20 08:12:19'),
(50, 17, 'ccvnn', 'fcc78798', '2026-01-23 13:31:49');

-- --------------------------------------------------------

--
-- Table structure for table `feedbacks`
--

CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL,
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `feedbacks`
--

INSERT INTO `feedbacks` (`id`, `customer_id`, `service_id`, `rating`, `comment`, `created_at`) VALUES
(11, 11, 3, 5, 'Great service, very clean and fast.', '2026-01-16 21:17:49'),
(12, 11, 3, 4, 'Good overall but took a bit longer than expected.', '2026-01-16 21:17:49'),
(13, 11, 3, 3, 'Average experience, can be improved.', '2026-01-16 21:17:49');

-- --------------------------------------------------------

--
-- Table structure for table `services`
--

CREATE TABLE `services` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `image` varchar(255) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `services`
--

INSERT INTO `services` (`id`, `name`, `price`, `image`, `description`) VALUES
(1, 'Normal Car Wash', 15.00, 'normal_wash.jpg', 'Basic exterior car wash.'),
(2, 'VIP Car Wash', 25.00, 'vip_wash.jpg', 'Exterior + interior deep clean.'),
(3, 'Steam Car Wash', 35.00, 'steam_wash.jpg', 'Steam cleaning for interior and engine.'),
(4, 'Interior Wash', 15.00, 'interior_wash.jpg', 'Interior cleaning only.'),
(5, 'pressure wash car', 40.00, 'https://goma.co.in/uploads/systems/a16fcca3d8660ac1f66bc3e2c4759849.jpg', 'washing cars with a water pressure gun'),
(8, 'test service', 20.00, 'svc_1768682632_1528875d.jpg', 'test test'),
(9, 'test', 25.00, 'svc_69735ea51d6da5.88851458.jpg', 'test test test'),
(10, 'testing', 50.00, 'svc_69735e822bde40.95333737.jpg', 'vhjwbb');

-- --------------------------------------------------------

--
-- Table structure for table `teams`
--

CREATE TABLE `teams` (
  `team_id` int(11) NOT NULL,
  `team_name` varchar(50) NOT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `car_number_plate` varchar(20) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teams`
--

INSERT INTO `teams` (`team_id`, `team_name`, `employee_id`, `car_number_plate`, `created_at`) VALUES
(9, 'Team Alpha', 55, 'ABC-1234', '2026-01-06 07:46:47'),
(10, 'Team Beta', 14, 'DEF-5678', '2026-01-06 07:46:47'),
(11, 'Team Gamma', 15, 'GHI-9012', '2026-01-06 07:46:47'),
(12, 'Team Delta', 16, 'JKL-3456', '2026-01-06 07:46:47'),
(13, 'test  team', 51, 'whk-55432', '2026-01-18 01:05:11'),
(14, 'dcvdv', 1, 'vhvvf', '2026-01-23 13:18:49');

-- --------------------------------------------------------

--
-- Table structure for table `team_bookings`
--

CREATE TABLE `team_bookings` (
  `id` int(11) NOT NULL,
  `team_id` int(11) NOT NULL,
  `booking_date` date NOT NULL,
  `booking_time` time NOT NULL,
  `booking_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `team_bookings`
--

INSERT INTO `team_bookings` (`id`, `team_id`, `booking_date`, `booking_time`, `booking_id`, `created_at`) VALUES
(50, 9, '2026-01-23', '04:32:00', 24, '2026-01-20 05:32:45'),
(100, 9, '2026-01-22', '05:50:00', 40, '2026-01-20 05:50:52'),
(130, 9, '2026-01-16', '23:20:00', 12, '2026-01-17 18:36:42'),
(131, 9, '2026-01-20', '07:00:00', 41, '2026-01-20 05:53:52'),
(132, 10, '2026-01-20', '07:00:00', 42, '2026-01-20 05:54:21'),
(134, 9, '2026-01-20', '08:07:00', 44, '2026-01-20 06:08:58'),
(135, 9, '2026-01-20', '05:12:00', 45, '2026-01-20 06:12:19');

-- --------------------------------------------------------

--
-- Table structure for table `team_members`
--

CREATE TABLE `team_members` (
  `id` int(11) NOT NULL,
  `team_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `team_members`
--

INSERT INTO `team_members` (`id`, `team_id`, `employee_id`, `created_at`) VALUES
(10, 12, 16, '2026-01-16 19:43:03'),
(11, 11, 15, '2026-01-16 19:43:11'),
(12, 10, 14, '2026-01-16 19:43:19'),
(25, 13, 51, '2026-01-17 23:05:11'),
(26, 13, 54, '2026-01-20 05:28:44'),
(28, 9, 55, '2026-01-20 05:31:57'),
(29, 14, 1, '2026-01-23 11:18:49');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('customer','manager','employee') NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `balance` decimal(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `phone`, `created_at`, `balance`) VALUES
(1, 'cileen', 'cileen@gmail.com', '$2y$10$F.BMxYSkz81OBblBZkRB2.YuUJln82K2ji4hnCn2PfmA2asbqvnp.', 'employee', '0598000487', '2026-01-14 19:54:47', 0.00),
(9, 'gsf', 'aa@gmail.com', '$2y$10$v3Gv2YXDzM.pBjCagspsD.1XLq72IhIfuxeKIZhTYsf8GTfINZNVy', 'customer', '', '2026-01-06 00:15:08', 0.00),
(10, 'fsd', 'gf@gmail.com', '$2y$10$owAF8OhpE/Knb0rno5xtoececdsaQDQK8.kiwMI0P9aIHt2zqIZnW', 'customer', '62535', '2026-01-06 00:21:32', 0.00),
(11, 'lara@gmail.com', 'lara@gmail.com', '$2y$10$kxNNJRNju/53/Lc4uVJfEei/cYWfKDAzcZaf2uKH27S3gSieh7aye', 'customer', '05984', '2026-01-06 00:28:01', 0.00),
(12, 'la', 'la@gmail.com', '$2y$10$axxgCGtfAt9HnoU0619gc.n6G/IOPI1eWRkjnFNrvD7sFUuenJIpW', 'customer', '5343', '2026-01-06 05:03:21', 0.00),
(14, 'Employee Two', 'emp2@example.com', 'password_hash_here', 'employee', '0591000002', '2026-01-06 05:46:47', 0.00),
(15, 'Employee Three', 'emp3@example.com', 'password_hash_here', 'employee', '0591000003', '2026-01-06 05:46:47', 0.00),
(16, 'Employee Four', 'emp4@example.com', 'password_hash_here', 'employee', '0591000004', '2026-01-06 05:46:47', 0.00),
(17, 'Deema', 'deema@gmail.com', '$2y$10$sttw642FCcJx.9Ij9.ali.cUKZzfYGaS4XK.oLlJjTHBgFIKLyMj.', 'customer', '054362', '2026-01-06 05:50:14', 0.00),
(50, 'Nour', 'nour.manager@gmail.com', '$2y$10$siBmdZC8sBBl2WpzHSj5BuIUjke.2cVKhWX0Rt46lzGO7oLVH9LHO', 'manager', '0599000001', '2026-01-16 12:17:57', 0.00),
(51, 'Omar', 'omar.employee@gmail.com', '$2y$10$siBmdZC8sBBl2WpzHSj5BuIUjke.2cVKhWX0Rt46lzGO7oLVH9LHO', 'employee', '0599000002', '2026-01-16 12:17:57', 0.00),
(52, 'ahmad', 'ahmad.customer@gmail.com', '$2y$10$cX.9TCPEtjJf7m/mgQi87uau5Kf9a2UpcR8T6sBfGe2/ceju49YDa', 'customer', '0597648428', '2026-01-16 12:27:14', 0.00),
(53, 'deema', 'd@gmail.com', '$2y$10$JptShsq4pzEsC4e2x7OdjO8hTNXGh5w9pKBgavfdMVkg2O9JPfIae', 'customer', '059757189', '2026-01-20 04:51:34', 0.00),
(54, 'la', 'l@gmail.com', '$2y$10$VEo2pYHVQZEjVc9XEg9/Qe/cP1rVFmoSmb0IP3Q3Ldl3NfvkzvyEO', 'employee', '05963542', '2026-01-20 05:03:46', 0.00),
(55, 'w', 'w@gmail.com', '$2y$10$UQ04ki3Gs9uxghcQwDfluO2v6Li8iIPvasglwiWoooXyhU4/zM4Eq', 'employee', '7363', '2026-01-20 05:30:53', 0.00),
(56, 'na', 'na@gmail.com', '$2y$10$iZGZpnZGZ/OtrZKsA3IxVu66Qe1b3dtXBjJ4U.7La7ObS.mR8cGJu', 'customer', '5365', '2026-01-20 06:03:16', 0.00),
(57, 'ra', 'r@gmail.com', '$2y$10$O0hHxOjneJc94WcgYogiJesLQrWpdc.oSNDogor0FmeIsnVZQHWru', 'customer', '0597356410', '2026-01-20 06:15:00', 0.00);

-- --------------------------------------------------------

--
-- Table structure for table `wallets`
--

CREATE TABLE `wallets` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `card_number` varchar(20) NOT NULL,
  `card_holder` varchar(100) NOT NULL,
  `expiry_date` varchar(7) NOT NULL,
  `cvv` varchar(5) NOT NULL,
  `balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `wallets`
--

INSERT INTO `wallets` (`id`, `user_id`, `card_number`, `card_holder`, `expiry_date`, `cvv`, `balance`, `created_at`) VALUES
(1, 52, '', '', '', '', 470.00, '2026-01-16 12:27:14'),
(3, 17, '', '', '', '', 540.00, '2026-01-06 05:50:15'),
(4, 11, '', '', '', '', 75.00, '2026-01-16 21:03:12'),
(5, 53, '', '', '', '', 400.00, '2026-01-20 04:51:34'),
(6, 56, '', '', '', '', 0.00, '2026-01-20 06:03:16'),
(7, 57, '', '', '', '', 0.00, '2026-01-20 06:15:00');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cars`
--
ALTER TABLE `cars`
  ADD PRIMARY KEY (`car_id`),
  ADD KEY `fk_car_user` (`user_id`);

--
-- Indexes for table `feedbacks`
--
ALTER TABLE `feedbacks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_feedback_customer` (`customer_id`),
  ADD KEY `fk_feedback_service` (`service_id`);

--
-- Indexes for table `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `teams`
--
ALTER TABLE `teams`
  ADD PRIMARY KEY (`team_id`),
  ADD KEY `fk_team_employee` (`employee_id`);

--
-- Indexes for table `team_bookings`
--
ALTER TABLE `team_bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_team_slot` (`team_id`,`booking_date`,`booking_time`),
  ADD KEY `fk_team_booking` (`team_id`),
  ADD KEY `fk_booking` (`booking_id`);

--
-- Indexes for table `team_members`
--
ALTER TABLE `team_members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_employee` (`employee_id`),
  ADD UNIQUE KEY `uq_team_employee` (`team_id`,`employee_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `wallets`
--
ALTER TABLE `wallets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_wallet_user` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
  MODIFY `car_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `feedbacks`
--
ALTER TABLE `feedbacks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `services`
--
ALTER TABLE `services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `team_bookings`
--
ALTER TABLE `team_bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=137;

--
-- AUTO_INCREMENT for table `team_members`
--
ALTER TABLE `team_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `wallets`
--
ALTER TABLE `wallets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
