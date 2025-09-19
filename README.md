# İzer AI Webhook System

A comprehensive multi-agent AI system for processing WhatsApp messages with detailed chat history analysis, designed specifically for İzer's bicycle business. The system includes **WhatsApp Web.js integration** for real-time message capture and **AI-powered routing** to specialized agents.

## Features

### 🚀 Core Features
- **WhatsApp Web.js Real-time Integration**: Live WhatsApp message capture with comprehensive chat history
- **AI-Powered Analysis**: OpenAI GPT-4 for intelligent message categorization, urgency scoring, and sentiment analysis
- **Multi-Agent Architecture**: Specialized AI agents for business workflow, technical support, and general inquiries
- **MySQL Database Integration**: Complete message storage with analytics and reporting capabilities
- **VIP Customer Detection**: Automatic identification and prioritization of İzer VIP customers
- **RESTful API**: Production-ready webhook endpoints with health monitoring

### 📱 WhatsApp Integration
- **QR Code Authentication**: Secure WhatsApp Web.js connection via mobile app
- **Real-time Message Capture**: Instant processing of incoming WhatsApp messages
- **Chat History Analysis**: Full conversation context for better AI responses
- **Media Message Support**: Handles images, documents, and media files
- **VIP Customer Prioritization**: Special handling for important business contacts
- **Message Filtering**: Smart filtering to process only relevant messages

### 🤖 AI & Analytics
- **Urgency Scoring**: 1-10 scale automated urgency assessment
- **Category Classification**: sales, support, complaint, inquiry, technical, general
- **Sentiment Analysis**: positive, negative, neutral, urgent sentiment detection
- **Response Time Recommendations**: immediate, 1hour, 4hours, 24hours
- **Business Intelligence**: Priority routing for critical customers and groups

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│ WhatsApp        │    │ Enhanced Webhook │    │ Multi-Agent System  │
│ Webhook         │───▶│ Processor        │───▶│ (Business/Code/etc) │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │ MySQL Database   │
                       │ - Messages       │
                       │ - History        │
                       │ - Analytics      │
                       └──────────────────┘
```

## Installation

### Prerequisites

- Python 3.8+
- MySQL 5.7+
- OpenAI API Key

### Setup

1. Clone the repository:
```bash
git clone https://github.com/your-username/izer-ai-webhook-system.git
cd izer-ai-webhook-system
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your database and API credentials
```

4. Set up the MySQL database:
```bash
mysql -u root -p < schema.sql
```

5. Start the webhook processor:
```bash
python enhanced_webhook_integration.py
```

6. Install Node.js dependencies for WhatsApp integration:
```bash
npm install whatsapp-web.js qrcode-terminal axios
```

7. Start WhatsApp Web.js connector:
```bash
node whatsapp_real_data_connector.js
```

8. Scan QR code with your WhatsApp mobile app to authenticate

## Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```env
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=izer_webhook_system

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Server Configuration
PORT=8100
```

### Critical Customers & Groups

The system automatically prioritizes messages from:

- VIP Customers
- Technical Support
- Sales Team
- Management
- Important Partners
- İzer Management

Important customer phone numbers can be configured in the `EnhancedWebhookProcessor` class.

## API Endpoints

### POST /webhook
Processes incoming webhook messages with chat history analysis.

**Request Body:**
```json
{
  "message_id": "unique_message_id",
  "chat_time": "2024-01-01T12:00:00Z",
  "chat_name": "Customer Name",
  "phone_number": "+905551234567",
  "current_message": "Message content",
  "history": [
    {
      "sender": "Customer Name",
      "content": "Previous message",
      "timestamp": "2024-01-01T11:59:00Z",
      "type": "text"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message_id": "unique_message_id",
  "database_id": 123,
  "analysis": {
    "urgency_score": 7,
    "category": "support",
    "sentiment": "negative",
    "priority_level": "high",
    "action_required": true,
    "recommended_response_time": "1hour"
  },
  "routing": {
    "success": true,
    "agent": "business_workflow",
    "response": {...}
  },
  "processed_at": "2024-01-01T12:00:01Z"
}
```

### GET /health
Returns service health status.

### GET /stats
Returns processing statistics for the last 24 hours.

## Database Schema

The system uses the following main tables:

- `webhook_messages`: Incoming message data
- `message_history`: Chat conversation history
- `analytics_results`: AI analysis results
- `agent_routing`: Agent routing decisions
- `critical_groups`: Priority group configurations
- `important_customers`: VIP customer settings
- `system_stats`: Performance monitoring

See `schema.sql` for complete database structure.

## Multi-Agent Integration

The system routes messages to specialized agents:

- **General Purpose Agent** (Port 8095): Research, analysis, general queries
- **Business Workflow Monitor** (Port 8093): Workflow monitoring, business processes
- **Code Debugger Agent** (Port 8094): Technical issues, debugging
- **Agent Hub** (Port 8092): Routing coordination

## Message Analysis

Each message is analyzed for:

- **Urgency Score** (1-10): Calculated urgency level
- **Category**: sales, support, complaint, inquiry, technical, general
- **Sentiment**: positive, negative, neutral, urgent
- **Keywords**: Extracted key terms
- **Priority Level**: critical, high, normal, low
- **Action Required**: Boolean flag for follow-up
- **Response Time**: immediate, 1hour, 4hours, 24hours

## Running in Production

For production deployment:

1. Use a process manager like PM2:
```bash
pm2 start enhanced_webhook_integration.py --name="webhook-processor"
```

2. Set up MySQL with proper users and permissions
3. Configure HTTPS reverse proxy (nginx/Apache)
4. Monitor logs and database performance
5. Set up backup procedures for the database

## Development

### Running Tests

```bash
# Test webhook endpoint
curl -X POST http://localhost:8100/webhook \
  -H "Content-Type: application/json" \
  -d @test_message.json

# Check health
curl http://localhost:8100/health

# Get statistics
curl http://localhost:8100/stats
```

### Adding New Agents

To integrate additional agents:

1. Add agent configuration in `agents_config`
2. Update routing logic in `route_to_agent()`
3. Ensure agent implements `/process` endpoint

## Monitoring

The system provides comprehensive logging and monitoring:

- Request/response logging
- Database operation monitoring
- Agent communication tracking
- Performance metrics
- Error handling and recovery

Check `webhook_system.log` for detailed operation logs.

## WhatsApp Web.js Integration

### Features

- **Real-time Message Capture**: Automatically captures all incoming WhatsApp messages
- **QR Code Authentication**: Secure connection via WhatsApp Web QR code scanning
- **Chat History Analysis**: Includes full conversation history for better AI context
- **VIP Customer Detection**: Automatic identification and prioritization of important customers
- **Media Message Support**: Handles images, documents, and other media files
- **Message Filtering**: Smart filtering to process only relevant business messages

### Setup and Usage

1. **Install Node.js Dependencies**:
   ```bash
   npm install whatsapp-web.js qrcode-terminal axios
   ```

2. **Start the WhatsApp Connector**:
   ```bash
   node whatsapp_real_data_connector.js
   ```

3. **Authenticate with QR Code**:
   - A QR code will be displayed in the terminal
   - Open WhatsApp on your mobile device
   - Go to Settings > Linked Devices > Link a Device
   - Scan the QR code displayed in the terminal

4. **System Activation**:
   - Once authenticated, the system will automatically start capturing messages
   - All incoming messages will be processed by the AI webhook system
   - Real-time analysis and routing to appropriate agents will begin

### VIP Customer Configuration

Update the VIP customer list in `whatsapp_real_data_connector.js`:

```javascript
const IZER_VIP_NUMBERS = [
    '905551234567',  // Important Customer 1
    '905559876543',  // Important Customer 2
    '905557894561'   // Important Customer 3
];
```

### Message Processing Flow

1. **Message Received**: WhatsApp Web.js captures incoming message
2. **History Collection**: Retrieves last 20 messages for context
3. **VIP Detection**: Checks if sender is a VIP customer
4. **Webhook Formatting**: Converts to webhook format with full context
5. **AI Analysis**: Sends to webhook system for AI processing
6. **Agent Routing**: Routes to appropriate specialized agent
7. **Response Generation**: AI generates appropriate response and actions

### Testing

Test the system with sample data:

```bash
# Send test messages to webhook system
node whatsapp_real_data_connector.js --test

# Or use the Python test script
python3 send_real_whatsapp_data.py
```

### Production Deployment

For production use:

1. **Process Management**:
   ```bash
   pm2 start whatsapp_real_data_connector.js --name="whatsapp-connector"
   pm2 save
   ```

2. **Monitoring**:
   ```bash
   pm2 logs whatsapp-connector
   pm2 status
   ```

3. **Auto-restart on System Boot**:
   ```bash
   pm2 startup
   pm2 save
   ```

### Troubleshooting

- **Authentication Issues**: Delete `.wwebjs_auth` folder and re-authenticate
- **Connection Problems**: Check internet connection and WhatsApp Web status
- **Message Not Processing**: Verify webhook endpoint is running on port 8100
- **Memory Issues**: Restart the connector process if memory usage is high

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, contact the İzer development team.