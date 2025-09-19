-- İzer AI Webhook System Database Schema
-- Character set and collation for Turkish support
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Database creation (uncomment if needed)
-- CREATE DATABASE IF NOT EXISTS izer_webhook_system
--   CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE izer_webhook_system;

-- Drop tables if they exist
DROP TABLE IF EXISTS `agent_routing`;
DROP TABLE IF EXISTS `analytics_results`;
DROP TABLE IF EXISTS `message_history`;
DROP TABLE IF EXISTS `webhook_messages`;
DROP TABLE IF EXISTS `critical_groups`;
DROP TABLE IF EXISTS `important_customers`;
DROP TABLE IF EXISTS `system_stats`;

-- Webhook Messages Table - Stores incoming webhook messages
CREATE TABLE `webhook_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` varchar(255) NOT NULL,
  `chat_time` datetime NOT NULL,
  `chat_name` varchar(255) NOT NULL,
  `phone_number` varchar(50) NOT NULL,
  `current_message` text NOT NULL,
  `is_vip_customer` tinyint(1) DEFAULT '0',
  `raw_data` json DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_message_id` (`message_id`),
  KEY `idx_phone_number` (`phone_number`),
  KEY `idx_chat_time` (`chat_time`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Message History Table - Stores chat conversation history
CREATE TABLE `message_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `webhook_message_id` int(11) NOT NULL,
  `sender` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `message_type` varchar(50) DEFAULT 'text',
  `from_me` tinyint(1) DEFAULT '0',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_message_history_webhook` (`webhook_message_id`),
  KEY `idx_timestamp` (`timestamp`),
  CONSTRAINT `fk_message_history_webhook` FOREIGN KEY (`webhook_message_id`) REFERENCES `webhook_messages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Analytics Results Table - Stores AI analysis results
CREATE TABLE `analytics_results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `webhook_message_id` int(11) NOT NULL,
  `urgency_score` int(11) NOT NULL DEFAULT '1',
  `category` enum('sales','support','complaint','inquiry','technical','general') NOT NULL DEFAULT 'general',
  `sentiment` enum('positive','negative','neutral','urgent') NOT NULL DEFAULT 'neutral',
  `priority_level` enum('critical','high','normal','low') NOT NULL DEFAULT 'normal',
  `action_required` tinyint(1) DEFAULT '0',
  `recommended_response_time` enum('immediate','1hour','4hours','24hours') DEFAULT '24hours',
  `keywords` json DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT '0.00',
  `analysis_details` json DEFAULT NULL,
  `processed_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_webhook_analysis` (`webhook_message_id`),
  KEY `idx_urgency_score` (`urgency_score`),
  KEY `idx_category` (`category`),
  KEY `idx_priority_level` (`priority_level`),
  CONSTRAINT `fk_analytics_webhook` FOREIGN KEY (`webhook_message_id`) REFERENCES `webhook_messages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Agent Routing Table - Stores agent routing decisions and responses
CREATE TABLE `agent_routing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `webhook_message_id` int(11) NOT NULL,
  `agent_type` varchar(100) NOT NULL,
  `agent_url` varchar(255) NOT NULL,
  `routing_success` tinyint(1) DEFAULT '0',
  `response_data` json DEFAULT NULL,
  `response_time_ms` int(11) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `routed_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_routing_webhook` (`webhook_message_id`),
  KEY `idx_agent_type` (`agent_type`),
  KEY `idx_routing_success` (`routing_success`),
  CONSTRAINT `fk_routing_webhook` FOREIGN KEY (`webhook_message_id`) REFERENCES `webhook_messages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Critical Groups Table - Configuration for priority group settings
CREATE TABLE `critical_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_name` varchar(255) NOT NULL,
  `group_identifier` varchar(255) NOT NULL,
  `priority_level` enum('critical','high','normal','low') DEFAULT 'normal',
  `auto_escalate` tinyint(1) DEFAULT '0',
  `max_response_time_minutes` int(11) DEFAULT '1440',
  `notification_settings` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_group_identifier` (`group_identifier`),
  KEY `idx_priority_level` (`priority_level`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Important Customers Table - VIP customer settings and configuration
CREATE TABLE `important_customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_name` varchar(255) NOT NULL,
  `phone_number` varchar(50) NOT NULL,
  `priority_level` enum('critical','high','normal','low') DEFAULT 'high',
  `customer_type` enum('vip','partner','management','technical','sales') DEFAULT 'vip',
  `auto_escalate` tinyint(1) DEFAULT '1',
  `preferred_agent_type` varchar(100) DEFAULT NULL,
  `special_instructions` text DEFAULT NULL,
  `max_response_time_minutes` int(11) DEFAULT '60',
  `contact_info` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_customer_phone` (`phone_number`),
  KEY `idx_priority_level` (`priority_level`),
  KEY `idx_customer_type` (`customer_type`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- System Stats Table - Performance monitoring and statistics
CREATE TABLE `system_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stat_type` varchar(100) NOT NULL,
  `stat_value` varchar(255) NOT NULL,
  `numeric_value` decimal(10,2) DEFAULT NULL,
  `time_period` enum('hourly','daily','weekly','monthly') DEFAULT 'daily',
  `reference_date` date NOT NULL,
  `additional_data` json DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_stat_type` (`stat_type`),
  KEY `idx_reference_date` (`reference_date`),
  KEY `idx_time_period` (`time_period`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default important customers (İzer VIP customers)
INSERT INTO `important_customers` (`customer_name`, `phone_number`, `priority_level`, `customer_type`, `special_instructions`) VALUES
('Test Müşteri - Ahmet', '+905551234567', 'critical', 'vip', 'Test amaçlı VIP müşteri'),
('İzer Müşteri - Fatma Demir', '+905559876543', 'high', 'vip', 'Değerli müşteri - hızlı yanıt gerekli'),
('İzer Müşteri - Can Özkan', '+905557894561', 'high', 'vip', 'Düzenli müşteri - satış odaklı');

-- Insert default critical groups
INSERT INTO `critical_groups` (`group_name`, `group_identifier`, `priority_level`, `max_response_time_minutes`) VALUES
('İzer Management', 'izer_management', 'critical', 15),
('Technical Support', 'technical_support', 'high', 60),
('Sales Team', 'sales_team', 'high', 120),
('VIP Customers', 'vip_customers', 'high', 60),
('Partner Network', 'partner_network', 'normal', 240);

-- Create indexes for better performance
CREATE INDEX idx_webhook_phone_time ON webhook_messages(phone_number, chat_time);
CREATE INDEX idx_analytics_urgency_category ON analytics_results(urgency_score, category);
CREATE INDEX idx_routing_agent_success ON agent_routing(agent_type, routing_success);

SET FOREIGN_KEY_CHECKS = 1;

-- Show created tables
SHOW TABLES;

-- Display table structure information
SELECT
    TABLE_NAME as 'Table',
    TABLE_ROWS as 'Rows',
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) as 'Size_MB'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME;