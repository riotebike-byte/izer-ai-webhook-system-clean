#!/usr/bin/env node

/**
 * WhatsApp Real Data Connector
 * WhatsApp Web.js kullanarak gerçek WhatsApp verilerini çeker ve webhook sistemine gönderir
 */

const { Client, LocalAuth, MessageMedia } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const axios = require('axios');
const fs = require('fs');

// Webhook endpoint
const WEBHOOK_URL = 'http://localhost:8100/webhook';

// WhatsApp Client Configuration
const client = new Client({
    authStrategy: new LocalAuth({
        clientId: "izer-ai-system"
    }),
    puppeteer: {
        headless: true,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-accelerated-2d-canvas',
            '--no-first-run',
            '--no-zygote',
            '--single-process',
            '--disable-gpu'
        ]
    }
});

// Message history storage
let messageHistory = new Map();

// İzer business phone numbers (VIP müşteriler)
const IZER_VIP_NUMBERS = [
    '905551234567',  // Test number
    '905559876543',  // Fatma Demir
    '905557894561'   // Can Özkan
];

/**
 * QR kod gösterimi
 */
client.on('qr', (qr) => {
    console.log('🔗 WhatsApp Web QR Kodu:');
    qrcode.generate(qr, { small: true });
    console.log('📱 WhatsApp uygulamanızdan QR kodu tarayın');
});

/**
 * Bağlantı başarılı
 */
client.on('ready', () => {
    console.log('✅ WhatsApp Web.js başarıyla bağlandı!');
    console.log('🤖 İzer AI Webhook sistemi aktif...');
    console.log('📨 Gelen mesajlar webhook sistemine otomatik gönderilecek');
});

/**
 * Bağlantı durumu
 */
client.on('authenticated', () => {
    console.log('🔐 WhatsApp kimlik doğrulaması başarılı');
});

client.on('auth_failure', (msg) => {
    console.error('❌ WhatsApp kimlik doğrulaması başarısız:', msg);
});

client.on('disconnected', (reason) => {
    console.log('📴 WhatsApp bağlantısı kesildi:', reason);
});

/**
 * Chat geçmişini al
 */
async function getChatHistory(chat, limit = 10) {
    try {
        const messages = await chat.fetchMessages({ limit });
        return messages.map(msg => ({
            sender: msg.fromMe ? 'İzer Support' : (msg.author || msg.from),
            content: msg.body || '[Media]',
            timestamp: new Date(msg.timestamp * 1000).toISOString(),
            type: msg.type || 'text',
            fromMe: msg.fromMe
        })).reverse(); // Eski mesajlardan yeniye sırala
    } catch (error) {
        console.error('Chat geçmişi alınamadı:', error);
        return [];
    }
}

/**
 * WhatsApp mesajını webhook formatına çevir
 */
async function formatMessageForWebhook(message) {
    try {
        const chat = await message.getChat();
        const contact = await message.getContact();

        // Chat geçmişini al
        const history = await getChatHistory(chat, 20);

        // Phone number'ı temizle
        const phoneNumber = contact.number || message.from.replace('@c.us', '');

        // Contact name veya phone number kullan
        let contactName = contact.pushname || contact.name || `+${phoneNumber}`;

        // İzer müşterisi mi kontrol et
        const isIzerCustomer = IZER_VIP_NUMBERS.some(num => phoneNumber.includes(num.replace('+', '')));
        if (isIzerCustomer) {
            contactName = `İzer Müşteri - ${contactName}`;
        }

        // Webhook payload oluştur
        const webhookData = {
            message_id: `wamid.${Date.now()}_${message.id.id}`,
            chat_time: new Date(message.timestamp * 1000).toISOString(),
            chat_name: contactName,
            phone_number: `+${phoneNumber}`,
            current_message: message.body || '[Media Message]',
            history: history.filter(h => h.content && h.content.trim().length > 0)
        };

        return webhookData;
    } catch (error) {
        console.error('Mesaj formatlanırken hata:', error);
        return null;
    }
}

/**
 * Webhook'a mesaj gönder
 */
async function sendToWebhook(webhookData) {
    try {
        console.log(`📤 Webhook'a gönderiliyor: ${webhookData.chat_name}`);
        console.log(`💬 Mesaj: ${webhookData.current_message.substring(0, 100)}...`);

        const response = await axios.post(WEBHOOK_URL, webhookData, {
            headers: {
                'Content-Type': 'application/json'
            },
            timeout: 30000
        });

        console.log(`✅ Webhook başarılı (${response.status})`);

        if (response.data.analysis) {
            console.log(`🤖 AI Analizi:`);
            console.log(`   Aciliyet: ${response.data.analysis.urgency_score}/10`);
            console.log(`   Kategori: ${response.data.analysis.category}`);
            console.log(`   Öncelik: ${response.data.analysis.priority_level}`);
        }

        return response.data;
    } catch (error) {
        console.error('❌ Webhook hatası:', error.message);
        if (error.response) {
            console.error('Response:', error.response.data);
        }
        return null;
    }
}

/**
 * Mesaj filtreleme
 */
function shouldProcessMessage(message) {
    // Kendi gönderdiğimiz mesajları işleme
    if (message.fromMe) return false;

    // Sistem mesajlarını atla
    if (message.type === 'notification_template') return false;

    // Grup mesajlarını atla (isteğe bağlı)
    if (message.from.includes('@g.us')) return false;

    // Boş mesajları atla
    if (!message.body && message.type !== 'image' && message.type !== 'document') return false;

    return true;
}

/**
 * Yeni mesaj geldiğinde
 */
client.on('message', async (message) => {
    try {
        // Mesajı işlemeli mi?
        if (!shouldProcessMessage(message)) {
            return;
        }

        console.log('\n📨 Yeni mesaj geldi!');
        console.log(`👤 Kimden: ${message.from}`);
        console.log(`💬 İçerik: ${message.body || '[Media]'}`);

        // Webhook formatına çevir
        const webhookData = await formatMessageForWebhook(message);

        if (webhookData) {
            // Webhook'a gönder
            await sendToWebhook(webhookData);
        }

    } catch (error) {
        console.error('Mesaj işlenirken hata:', error);
    }
});

/**
 * Grup mesajları için (isteğe bağlı)
 */
client.on('message_create', async (message) => {
    // Sadece grup mesajları için ekstra işlem yapılabilir
    if (message.from.includes('@g.us') && !message.fromMe) {
        console.log(`📢 Grup mesajı: ${message.from}`);
    }
});

/**
 * Medya mesajları için
 */
client.on('message', async (message) => {
    if (message.hasMedia && shouldProcessMessage(message)) {
        try {
            const media = await message.downloadMedia();
            console.log(`📎 Medya mesajı: ${media.mimetype}`);

            // Medya ile birlikte webhook'a gönder
            const webhookData = await formatMessageForWebhook(message);
            if (webhookData) {
                webhookData.current_message = `[${media.mimetype} dosyası] ${message.body || ''}`;
                await sendToWebhook(webhookData);
            }
        } catch (error) {
            console.error('Medya işlenirken hata:', error);
        }
    }
});

/**
 * Test mesajı gönderme fonksiyonu
 */
async function sendTestMessage() {
    try {
        console.log('🧪 Test mesajları webhook sistemine gönderiliyor...');

        const testMessages = [
            {
                message_id: `wamid.test_${Date.now()}_1`,
                chat_time: new Date().toISOString(),
                chat_name: 'Test Müşteri - Ahmet',
                phone_number: '+905551234567',
                current_message: 'Bisikletimin freni çalışmıyor, acil yardım lazım!',
                history: [
                    {
                        sender: 'Test Müşteri - Ahmet',
                        content: 'Merhaba İzer',
                        timestamp: new Date(Date.now() - 60000).toISOString(),
                        type: 'text'
                    }
                ]
            }
        ];

        for (const testMsg of testMessages) {
            await sendToWebhook(testMsg);
            await new Promise(resolve => setTimeout(resolve, 1000));
        }

        console.log('✅ Test mesajları gönderildi');
    } catch (error) {
        console.error('Test mesajı hatası:', error);
    }
}

/**
 * Graceful shutdown
 */
process.on('SIGINT', async () => {
    console.log('\n🛑 WhatsApp Web.js kapatılıyor...');
    await client.destroy();
    process.exit(0);
});

process.on('SIGTERM', async () => {
    console.log('\n🛑 WhatsApp Web.js sonlandırılıyor...');
    await client.destroy();
    process.exit(0);
});

// Hata yakalama
process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
    process.exit(1);
});

/**
 * CLI komutları
 */
if (process.argv.includes('--test')) {
    console.log('🧪 Test modu başlatılıyor...');
    setTimeout(sendTestMessage, 2000);
}

// WhatsApp Client'ı başlat
console.log('🚀 İzer AI WhatsApp Connector başlatılıyor...');
console.log('📱 WhatsApp Web.js bağlantısı kuruluyor...');
client.initialize();

// Periyodik durum kontrolü
setInterval(() => {
    const state = client.getState();
    if (state !== 'CONNECTED') {
        console.log(`⚠️  Bağlantı durumu: ${state}`);
    }
}, 30000);

module.exports = {
    client,
    sendToWebhook,
    formatMessageForWebhook
};