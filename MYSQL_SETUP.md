# MySQL Database Setup Guide

## Prerequisites

- MySQL 5.7+ or MySQL 8.0+
- Python 3.8+
- Administrative access to MySQL

## Installation

### macOS (using Homebrew)
```bash
brew install mysql
brew services start mysql
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

### Windows
Download and install MySQL from https://dev.mysql.com/downloads/mysql/

## Database Setup

### 1. Connect to MySQL
```bash
mysql -u root -p
```

### 2. Create Database and User
```sql
-- Create database
CREATE DATABASE izer_webhook_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create dedicated user (recommended for production)
CREATE USER 'izer_webhook'@'localhost' IDENTIFIED BY 'your_secure_password_here';

-- Grant privileges
GRANT ALL PRIVILEGES ON izer_webhook_system.* TO 'izer_webhook'@'localhost';
FLUSH PRIVILEGES;

-- Exit MySQL
EXIT;
```

### 3. Import Database Schema
```bash
mysql -u izer_webhook -p izer_webhook_system < schema.sql
```

### 4. Verify Setup
```bash
mysql -u izer_webhook -p izer_webhook_system -e "SHOW TABLES;"
```

Expected output:
```
+--------------------------------+
| Tables_in_izer_webhook_system  |
+--------------------------------+
| agent_routing                  |
| analytics_results              |
| critical_groups                |
| important_customers            |
| message_history                |
| system_stats                   |
| webhook_messages               |
+--------------------------------+
```

## Environment Configuration

Update your `.env` file:
```env
DB_HOST=localhost
DB_USER=izer_webhook
DB_PASSWORD=your_secure_password_here
DB_NAME=izer_webhook_system
```

## Production Security

### 1. Secure Installation
```bash
sudo mysql_secure_installation
```

### 2. Configure Firewall
```bash
# Ubuntu/Debian
sudo ufw allow from your_app_server_ip to any port 3306

# CentOS/RHEL
sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='your_app_server_ip' port protocol='tcp' port='3306' accept"
```

### 3. Regular Backups
```bash
# Create backup
mysqldump -u izer_webhook -p izer_webhook_system > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
mysql -u izer_webhook -p izer_webhook_system < backup_file.sql
```

## Troubleshooting

### Connection Issues
```bash
# Check MySQL status
sudo systemctl status mysql

# Check if MySQL is listening
netstat -tlnp | grep :3306

# Check MySQL error log
sudo tail -f /var/log/mysql/error.log
```

### Performance Optimization
```sql
-- For production, consider these settings in my.cnf:
[mysqld]
innodb_buffer_pool_size = 2G
innodb_log_file_size = 256M
max_connections = 200
query_cache_size = 128M
```

### Testing Connection
```python
import mysql.connector
from mysql.connector import Error

try:
    connection = mysql.connector.connect(
        host='localhost',
        database='izer_webhook_system',
        user='izer_webhook',
        password='your_secure_password_here'
    )

    if connection.is_connected():
        print("✅ Successfully connected to MySQL database")
        cursor = connection.cursor()
        cursor.execute("SELECT DATABASE();")
        record = cursor.fetchone()
        print(f"Connected to database: {record}")

except Error as e:
    print(f"❌ Error connecting to MySQL: {e}")

finally:
    if connection.is_connected():
        cursor.close()
        connection.close()
        print("MySQL connection closed")
```

## Next Steps

After setting up MySQL:

1. **Start the webhook system:**
   ```bash
   python3 enhanced_webhook_integration.py
   ```

2. **Start WhatsApp connector:**
   ```bash
   node whatsapp_real_data_connector.js
   ```

3. **Scan QR code** with WhatsApp mobile app

4. **Test the system** by sending a WhatsApp message

The system will automatically:
- Capture WhatsApp messages with chat history
- Store them in MySQL database
- Analyze them with AI
- Route to appropriate agents
- Provide detailed analytics and reporting