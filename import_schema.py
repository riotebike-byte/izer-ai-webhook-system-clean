#!/usr/bin/env python3
"""
İzer Webhook System Database Schema Importer
Niobe MySQL veritabanına schema'yı import eder
"""
import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

# .env dosyasını yükle
load_dotenv()

# Database configuration from .env
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'user': os.getenv('DB_USER', 'ronit'),
    'password': os.getenv('DB_PASSWORD', 'izerko11'),
    'database': os.getenv('DB_NAME', 'izer_webhook_system'),
    'charset': 'utf8mb4',
    'collation': 'utf8mb4_unicode_ci'
}

def read_schema_file():
    """Schema dosyasını oku"""
    try:
        with open('izer_webhook_schema.sql', 'r', encoding='utf-8') as file:
            schema_content = file.read()
        return schema_content
    except Exception as e:
        print(f"❌ Schema dosyası okunamadı: {e}")
        return None

def execute_sql_statements(cursor, sql_content):
    """SQL ifadelerini çalıştır"""
    # SQL ifadelerini ayır
    statements = sql_content.split(';')

    executed_count = 0
    error_count = 0

    for statement in statements:
        statement = statement.strip()
        if not statement or statement.startswith('--'):
            continue

        try:
            cursor.execute(statement)
            executed_count += 1
            print(f"✅ SQL çalıştırıldı: {statement[:60]}...")
        except Error as e:
            error_count += 1
            print(f"⚠️  SQL hatası: {e}")
            print(f"   Statement: {statement[:100]}...")

    return executed_count, error_count

def import_schema():
    """Schema'yı veritabanına import et"""
    connection = None
    cursor = None

    try:
        print("🚀 İzer Webhook System Schema Import Başlatılıyor...")
        print(f"📍 Bağlantı: {DB_CONFIG['user']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}")

        # Schema dosyasını oku
        schema_content = read_schema_file()
        if not schema_content:
            return False

        # MySQL bağlantısı
        print("🔗 MySQL bağlantısı kuruluyor...")
        connection = mysql.connector.connect(**DB_CONFIG)

        if connection.is_connected():
            cursor = connection.cursor()
            print("✅ MySQL bağlantısı başarılı!")

            # Database bilgilerini göster
            cursor.execute("SELECT DATABASE(), VERSION(), USER()")
            db_info = cursor.fetchone()
            print(f"📊 Veritabanı: {db_info[0]}")
            print(f"🔧 MySQL Versiyonu: {db_info[1]}")
            print(f"👤 Kullanıcı: {db_info[2]}")

            # Schema'yı import et
            print("\n📥 Schema import ediliyor...")
            executed, errors = execute_sql_statements(cursor, schema_content)

            # Commit changes
            connection.commit()

            print(f"\n📊 Import Sonuçları:")
            print(f"   ✅ Başarılı: {executed} SQL ifadesi")
            print(f"   ⚠️  Hata: {errors} SQL ifadesi")

            # Tabloları listele
            print("\n📋 Oluşturulan tablolar:")
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
            for table in tables:
                print(f"   📄 {table[0]}")

            # Tablo detaylarını göster
            if tables:
                print("\n📈 Tablo detayları:")
                cursor.execute("""
                    SELECT
                        TABLE_NAME as 'Table',
                        TABLE_ROWS as 'Rows',
                        ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) as 'Size_MB'
                    FROM information_schema.TABLES
                    WHERE TABLE_SCHEMA = DATABASE()
                    ORDER BY TABLE_NAME
                """)
                table_info = cursor.fetchall()
                for info in table_info:
                    print(f"   📊 {info[0]}: {info[1]} rows, {info[2]} MB")

            print("\n🎉 Schema import başarıyla tamamlandı!")
            return True

    except Error as e:
        print(f"❌ MySQL Hatası: {e}")
        return False
    except Exception as e:
        print(f"❌ Genel Hata: {e}")
        return False
    finally:
        if cursor:
            cursor.close()
        if connection and connection.is_connected():
            connection.close()
            print("🔌 MySQL bağlantısı kapatıldı")

def test_connection():
    """Veritabanı bağlantısını test et"""
    try:
        print("🧪 Veritabanı bağlantısı test ediliyor...")
        connection = mysql.connector.connect(**DB_CONFIG)

        if connection.is_connected():
            cursor = connection.cursor()
            cursor.execute("SELECT 1")
            result = cursor.fetchone()
            print("✅ Bağlantı testi başarılı!")
            cursor.close()
            connection.close()
            return True
    except Error as e:
        print(f"❌ Bağlantı testi başarısız: {e}")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("İZER AI WEBHOOK SYSTEM - DATABASE SCHEMA IMPORTER")
    print("=" * 60)

    # Önce bağlantıyı test et
    if test_connection():
        # Schema'yı import et
        success = import_schema()
        if success:
            print("\n🚀 Sistem hazır! Enhanced webhook integration başlatılabilir.")
        else:
            print("\n❌ Schema import başarısız!")
    else:
        print("\n❌ Veritabanı bağlantısı kurulamadı!")

    print("=" * 60)