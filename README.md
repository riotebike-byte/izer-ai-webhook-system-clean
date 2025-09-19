# İzer AI Webhook System

A comprehensive multi-agent AI system for processing WhatsApp webhook messages with detailed chat history analysis, designed specifically for İzer's bicycle business.

## Features

- **Real-time Message Processing**: Processes incoming WhatsApp webhook messages with chat history context
- **AI-Powered Analysis**: Uses OpenAI GPT-4 for intelligent message categorization and urgency scoring
- **Multi-Agent Architecture**: Routes messages to specialized agents based on content and priority
- **MySQL Database Integration**: Stores messages, history, and analysis results for reporting
- **Business Intelligence**: Prioritizes critical customers and groups for faster response times
- **RESTful API**: Clean endpoints for webhook processing, health checks, and statistics

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

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, contact the İzer development team.