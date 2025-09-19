#!/usr/bin/env python3
"""
Gerçek WhatsApp verilerini webhook sistemine gönderen script
"""
import requests
import json
from datetime import datetime

# Webhook endpoint
WEBHOOK_URL = "http://localhost:8100/webhook"

def send_whatsapp_message(message_data):
    """WhatsApp mesajını webhook'a gönder"""
    try:
        response = requests.post(
            WEBHOOK_URL,
            json=message_data,
            headers={'Content-Type': 'application/json'},
            timeout=30
        )

        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        return response.json() if response.headers.get('content-type') == 'application/json' else response.text

    except Exception as e:
        print(f"Error: {e}")
        return None

# Gerçek İzer müşteri verisi örneği
real_customer_message = {
    "message_id": f"wamid.{datetime.now().strftime('%Y%m%d%H%M%S')}_real",
    "chat_time": datetime.now().isoformat() + "Z",
    "chat_name": "İzer Müşteri - Ahmet Yılmaz",
    "phone_number": "+905551234567",
    "current_message": "Merhaba İzer, geçen hafta aldığım Giant TCR bisikletinin vites değişimi çok sert. Ayar gerekiyor mu? Ayrıca ön fren diski gıcırdıyor. Ne zaman servis randevusu alabilirim?",
    "history": [
        {
            "sender": "İzer Müşteri - Ahmet Yılmaz",
            "content": "Selam, yeni aldığım bisikletle ilgili sorularım var",
            "timestamp": "2025-09-19T08:30:00Z",
            "type": "text"
        },
        {
            "sender": "İzer Support",
            "content": "Merhaba Ahmet Bey! Tabii ki, size yardımcı olmaktan mutluluk duyarız. Sorunlarınızı dinliyorum.",
            "timestamp": "2025-09-19T08:31:00Z",
            "type": "text"
        },
        {
            "sender": "İzer Müşteri - Ahmet Yılmaz",
            "content": "Giant TCR Advanced Pro aldım geçen hafta. Çok memnunum ama küçük sorunlar var",
            "timestamp": "2025-09-19T08:32:00Z",
            "type": "text"
        }
    ]
}

# Acil durum mesajı
urgent_message = {
    "message_id": f"wamid.{datetime.now().strftime('%Y%m%d%H%M%S')}_urgent",
    "chat_time": datetime.now().isoformat() + "Z",
    "chat_name": "İzer Müşteri - Fatma Demir",
    "phone_number": "+905559876543",
    "current_message": "ACİL! Bisikletimin fren kablosu koptu, şu anda yolda kaldım. Yakında tamirci var mı? Ankara Çankaya'dayım.",
    "history": [
        {
            "sender": "İzer Müşteri - Fatma Demir",
            "content": "Yardım edin lütfen!",
            "timestamp": "2025-09-19T09:45:00Z",
            "type": "text"
        }
    ]
}

# Satış sorgusu
sales_inquiry = {
    "message_id": f"wamid.{datetime.now().strftime('%Y%m%d%H%M%S')}_sales",
    "chat_time": datetime.now().isoformat() + "Z",
    "chat_name": "Potansiyel Müşteri - Can Özkan",
    "phone_number": "+905557894561",
    "current_message": "Merhaba, elektrikli bisiklet modelleri ve fiyatları hakkında bilgi alabilir miyim? Özellikle şehir içi kullanım için uygun olanları merak ediyorum. Bütçem 15-20 bin TL arası.",
    "history": [
        {
            "sender": "Potansiyel Müşteri - Can Özkan",
            "content": "İyi günler, e-bike bakıyorum",
            "timestamp": "2025-09-19T07:20:00Z",
            "type": "text"
        },
        {
            "sender": "İzer Sales",
            "content": "Merhaba! E-bike modellerimiz için size yardımcı olabilirim. Hangi amaçla kullanacaksınız?",
            "timestamp": "2025-09-19T07:21:00Z",
            "type": "text"
        }
    ]
}

if __name__ == "__main__":
    print("🚀 Gerçek WhatsApp verilerini webhook sistemine gönderiliyor...")
    print("=" * 60)

    # 1. Normal servis talebi
    print("\n📱 1. Normal Servis Talebi Gönderiliyor...")
    result1 = send_whatsapp_message(real_customer_message)

    # 2. Acil durum
    print("\n🚨 2. Acil Durum Mesajı Gönderiliyor...")
    result2 = send_whatsapp_message(urgent_message)

    # 3. Satış sorgusu
    print("\n💰 3. Satış Sorgusu Gönderiliyor...")
    result3 = send_whatsapp_message(sales_inquiry)

    print("\n" + "=" * 60)
    print("✅ Tüm gerçek WhatsApp verileri sisteme gönderildi!")
    print("🤖 AI analizi ve agent routing sonuçlarını kontrol edin.")