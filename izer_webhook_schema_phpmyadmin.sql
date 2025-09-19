-- İzer AI Webhook System Database Schema - phpMyAdmin Compatible Version
-- Optimized for phpMyAdmin import with maximum compatibility

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `izer_webhook_system`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `webhook_messages`
--

DROP TABLE IF EXISTS `webhook_messages`;
CREATE TABLE `webhook_messages` (
  `id` int(11) NOT NULL,
  `message_id` varchar(255) NOT NULL,
  `chat_time` datetime NOT NULL,
  `chat_name` varchar(255) NOT NULL,
  `phone_number` varchar(50) NOT NULL,
  `current_message` text NOT NULL,
  `is_vip_customer` tinyint(1) DEFAULT 0,
  `raw_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw_data`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `message_history`
--

DROP TABLE IF EXISTS `message_history`;
CREATE TABLE `message_history` (
  `id` int(11) NOT NULL,
  `webhook_message_id` int(11) NOT NULL,
  `sender` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `message_type` varchar(50) DEFAULT 'text',
  `from_me` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `analytics_results`
--

DROP TABLE IF EXISTS `analytics_results`;
CREATE TABLE `analytics_results` (
  `id` int(11) NOT NULL,
  `webhook_message_id` int(11) NOT NULL,
  `urgency_score` int(11) NOT NULL DEFAULT 1,
  `category` enum('sales','support','complaint','inquiry','technical','general') NOT NULL DEFAULT 'general',
  `sentiment` enum('positive','negative','neutral','urgent') NOT NULL DEFAULT 'neutral',
  `priority_level` enum('critical','high','normal','low') NOT NULL DEFAULT 'normal',
  `action_required` tinyint(1) DEFAULT 0,
  `recommended_response_time` enum('immediate','1hour','4hours','24hours') DEFAULT '24hours',
  `keywords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`keywords`)),
  `confidence_score` decimal(5,2) DEFAULT 0.00,
  `analysis_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`analysis_details`)),
  `processed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `agent_routing`
--

DROP TABLE IF EXISTS `agent_routing`;
CREATE TABLE `agent_routing` (
  `id` int(11) NOT NULL,
  `webhook_message_id` int(11) NOT NULL,
  `agent_type` varchar(100) NOT NULL,
  `agent_url` varchar(255) NOT NULL,
  `routing_success` tinyint(1) DEFAULT 0,
  `response_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`response_data`)),
  `response_time_ms` int(11) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `routed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `critical_groups`
--

DROP TABLE IF EXISTS `critical_groups`;
CREATE TABLE `critical_groups` (
  `id` int(11) NOT NULL,
  `group_name` varchar(255) NOT NULL,
  `group_identifier` varchar(255) NOT NULL,
  `priority_level` enum('critical','high','normal','low') DEFAULT 'normal',
  `auto_escalate` tinyint(1) DEFAULT 0,
  `max_response_time_minutes` int(11) DEFAULT 1440,
  `notification_settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`notification_settings`)),
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `important_customers`
--

DROP TABLE IF EXISTS `important_customers`;
CREATE TABLE `important_customers` (
  `id` int(11) NOT NULL,
  `customer_name` varchar(255) NOT NULL,
  `phone_number` varchar(50) NOT NULL,
  `priority_level` enum('critical','high','normal','low') DEFAULT 'high',
  `customer_type` enum('vip','partner','management','technical','sales') DEFAULT 'vip',
  `auto_escalate` tinyint(1) DEFAULT 1,
  `preferred_agent_type` varchar(100) DEFAULT NULL,
  `special_instructions` text DEFAULT NULL,
  `max_response_time_minutes` int(11) DEFAULT 60,
  `contact_info` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`contact_info`)),
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `system_stats`
--

DROP TABLE IF EXISTS `system_stats`;
CREATE TABLE `system_stats` (
  `id` int(11) NOT NULL,
  `stat_type` varchar(100) NOT NULL,
  `stat_value` varchar(255) NOT NULL,
  `numeric_value` decimal(10,2) DEFAULT NULL,
  `time_period` enum('hourly','daily','weekly','monthly') DEFAULT 'daily',
  `reference_date` date NOT NULL,
  `additional_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`additional_data`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `webhook_messages`
--
ALTER TABLE `webhook_messages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_message_id` (`message_id`),
  ADD KEY `idx_phone_number` (`phone_number`),
  ADD KEY `idx_chat_time` (`chat_time`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_webhook_phone_time` (`phone_number`,`chat_time`);

--
-- Tablo için indeksler `message_history`
--
ALTER TABLE `message_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_message_history_webhook` (`webhook_message_id`),
  ADD KEY `idx_timestamp` (`timestamp`);

--
-- Tablo için indeksler `analytics_results`
--
ALTER TABLE `analytics_results`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_webhook_analysis` (`webhook_message_id`),
  ADD KEY `idx_urgency_score` (`urgency_score`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_priority_level` (`priority_level`),
  ADD KEY `idx_analytics_urgency_category` (`urgency_score`,`category`);

--
-- Tablo için indeksler `agent_routing`
--
ALTER TABLE `agent_routing`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_routing_webhook` (`webhook_message_id`),
  ADD KEY `idx_agent_type` (`agent_type`),
  ADD KEY `idx_routing_success` (`routing_success`),
  ADD KEY `idx_routing_agent_success` (`agent_type`,`routing_success`);

--
-- Tablo için indeksler `critical_groups`
--
ALTER TABLE `critical_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_group_identifier` (`group_identifier`),
  ADD KEY `idx_priority_level` (`priority_level`),
  ADD KEY `idx_is_active` (`is_active`);

--
-- Tablo için indeksler `important_customers`
--
ALTER TABLE `important_customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_customer_phone` (`phone_number`),
  ADD KEY `idx_priority_level` (`priority_level`),
  ADD KEY `idx_customer_type` (`customer_type`),
  ADD KEY `idx_is_active` (`is_active`);

--
-- Tablo için indeksler `system_stats`
--
ALTER TABLE `system_stats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_stat_type` (`stat_type`),
  ADD KEY `idx_reference_date` (`reference_date`),
  ADD KEY `idx_time_period` (`time_period`);

--
-- Dökümü yapılmış tablolar için AUTO_INCREMENT değeri
--

--
-- Tablo için AUTO_INCREMENT değeri `webhook_messages`
--
ALTER TABLE `webhook_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `message_history`
--
ALTER TABLE `message_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `analytics_results`
--
ALTER TABLE `analytics_results`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `agent_routing`
--
ALTER TABLE `agent_routing`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `critical_groups`
--
ALTER TABLE `critical_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `important_customers`
--
ALTER TABLE `important_customers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `system_stats`
--
ALTER TABLE `system_stats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `message_history`
--
ALTER TABLE `message_history`
  ADD CONSTRAINT `fk_message_history_webhook` FOREIGN KEY (`webhook_message_id`) REFERENCES `webhook_messages` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `analytics_results`
--
ALTER TABLE `analytics_results`
  ADD CONSTRAINT `fk_analytics_webhook` FOREIGN KEY (`webhook_message_id`) REFERENCES `webhook_messages` (`id`) ON DELETE CASCADE;

--
-- Tablo kısıtlamaları `agent_routing`
--
ALTER TABLE `agent_routing`
  ADD CONSTRAINT `fk_routing_webhook` FOREIGN KEY (`webhook_message_id`) REFERENCES `webhook_messages` (`id`) ON DELETE CASCADE;

--
-- Test verileri ekleme
--

INSERT INTO `important_customers` (`customer_name`, `phone_number`, `priority_level`, `customer_type`, `special_instructions`) VALUES
('Test Müşteri - Ahmet', '+905551234567', 'critical', 'vip', 'Test amaçlı VIP müşteri'),
('İzer Müşteri - Fatma Demir', '+905559876543', 'high', 'vip', 'Değerli müşteri - hızlı yanıt gerekli'),
('İzer Müşteri - Can Özkan', '+905557894561', 'high', 'vip', 'Düzenli müşteri - satış odaklı');

INSERT INTO `critical_groups` (`group_name`, `group_identifier`, `priority_level`, `max_response_time_minutes`) VALUES
('İzer Management', 'izer_management', 'critical', 15),
('Technical Support', 'technical_support', 'high', 60),
('Sales Team', 'sales_team', 'high', 120),
('VIP Customers', 'vip_customers', 'high', 60),
('Partner Network', 'partner_network', 'normal', 240);

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;