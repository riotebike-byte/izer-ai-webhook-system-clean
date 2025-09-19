#!/usr/bin/env python3

import os
import json
import requests
import mysql.connector
from datetime import datetime, timedelta
from flask import Flask, request, jsonify
from typing import Dict, List, Any, Optional
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('webhook_system.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class DatabaseManager:
    def __init__(self):
        self.config = {
            'host': os.getenv('DB_HOST', 'localhost'),
            'user': os.getenv('DB_USER', 'root'),
            'password': os.getenv('DB_PASSWORD', ''),
            'database': os.getenv('DB_NAME', 'izer_webhook_system'),
            'charset': 'utf8mb4',
            'collation': 'utf8mb4_unicode_ci'
        }
        self.connection_pool = None

    def get_connection(self):
        try:
            return mysql.connector.connect(**self.config)
        except mysql.connector.Error as e:
            logger.error(f"Database connection error: {e}")
            return None

    def execute_query(self, query: str, params: tuple = None) -> Any:
        conn = self.get_connection()
        if not conn:
            return None

        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute(query, params)

            if query.strip().upper().startswith('SELECT'):
                result = cursor.fetchall()
            else:
                conn.commit()
                result = cursor.lastrowid

            return result
        except mysql.connector.Error as e:
            logger.error(f"Query execution error: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    def save_webhook_message(self, message: Dict) -> Optional[int]:
        query = """
        INSERT INTO webhook_messages
        (message_id, chat_time, chat_name, phone_number, current_message, source, processed)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        params = (
            message.get('message_id', f"msg_{datetime.now().timestamp()}"),
            message.get('chat_time', datetime.now()),
            message.get('chat_name', ''),
            message.get('phone_number', ''),
            message.get('current_message', ''),
            message.get('source', 'webhook'),
            False
        )

        return self.execute_query(query, params)

    def save_message_history(self, message_id: str, history: List[Dict]) -> bool:
        query = """
        INSERT INTO message_history (message_id, sender, content, timestamp, message_type)
        VALUES (%s, %s, %s, %s, %s)
        """

        try:
            conn = self.get_connection()
            if not conn:
                return False

            cursor = conn.cursor()
            for msg in history:
                params = (
                    message_id,
                    msg.get('sender', ''),
                    msg.get('content', ''),
                    msg.get('timestamp', datetime.now()),
                    msg.get('type', 'text')
                )
                cursor.execute(query, params)

            conn.commit()
            return True

        except mysql.connector.Error as e:
            logger.error(f"Error saving message history: {e}")
            return False
        finally:
            cursor.close()
            conn.close()

    def save_analytics_result(self, message_id: str, analysis: Dict) -> bool:
        query = """
        INSERT INTO analytics_results
        (message_id, urgency_score, category, sentiment, keywords, priority_level, action_required)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        params = (
            message_id,
            analysis.get('urgency_score', 0),
            analysis.get('category', 'general'),
            analysis.get('sentiment', 'neutral'),
            json.dumps(analysis.get('keywords', [])),
            analysis.get('priority_level', 'normal'),
            analysis.get('action_required', False)
        )

        return self.execute_query(query, params) is not None

class EnhancedWebhookProcessor:
    def __init__(self):
        self.db = DatabaseManager()
        self.openai_api_key = os.getenv('OPENAI_API_KEY')

        if not self.openai_api_key:
            logger.error("OPENAI_API_KEY environment variable not set")
            raise ValueError("OpenAI API key is required")

        self.agents_config = {
            'general_purpose': {'url': 'http://localhost:8095', 'capabilities': ['research', 'analysis', 'general']},
            'business_workflow': {'url': 'http://localhost:8093', 'capabilities': ['workflow', 'monitoring', 'business']},
            'code_debugger': {'url': 'http://localhost:8094', 'capabilities': ['debug', 'code', 'technical']},
            'agent_hub': {'url': 'http://localhost:8092', 'capabilities': ['routing', 'coordination']}
        }

        self.critical_groups = [
            'VIP Customers', 'Technical Support', 'Sales Team', 'Management',
            'Important Partners', 'İzer Management'
        ]

        self.important_customers = [
            '+905551234567', '+905551234568', '+905551234569'
        ]

    def analyze_message_with_history(self, message: Dict) -> Dict:
        try:
            current_msg = message.get('current_message', '')
            chat_name = message.get('chat_name', '')
            phone = message.get('phone_number', '')

            message_history = self.get_relevant_history(phone, chat_name)
            history_context = self.prepare_history_context(message_history)

            analysis_prompt = f"""
            Analyze this message with its conversation history for İzer's bicycle business:

            Current Message: "{current_msg}"
            From: {chat_name} ({phone})

            Conversation History:
            {history_context}

            Please provide analysis in this exact JSON format:
            {{
                "urgency_score": 1-10,
                "category": "sales|support|complaint|inquiry|technical|general",
                "sentiment": "positive|negative|neutral|urgent",
                "keywords": ["key", "words", "from", "message"],
                "priority_level": "critical|high|normal|low",
                "action_required": true/false,
                "recommended_response_time": "immediate|1hour|4hours|24hours",
                "business_context": "brief context about customer/situation",
                "suggested_next_action": "what should be done next"
            }}
            """

            headers = {
                'Authorization': f'Bearer {self.openai_api_key}',
                'Content-Type': 'application/json'
            }

            payload = {
                'model': 'gpt-4',
                'messages': [
                    {
                        'role': 'system',
                        'content': 'You are an AI assistant analyzing customer messages for İzer bicycle business. Provide accurate business intelligence.'
                    },
                    {
                        'role': 'user',
                        'content': analysis_prompt
                    }
                ],
                'temperature': 0.3,
                'max_tokens': 1000
            }

            response = requests.post(
                'https://api.openai.com/v1/chat/completions',
                headers=headers,
                json=payload,
                timeout=30
            )

            if response.status_code == 200:
                ai_response = response.json()
                content = ai_response['choices'][0]['message']['content']

                try:
                    analysis = json.loads(content)

                    if phone in self.important_customers or any(group in chat_name for group in self.critical_groups):
                        analysis['priority_level'] = 'critical'
                        analysis['urgency_score'] = min(10, analysis.get('urgency_score', 5) + 3)

                    return analysis

                except json.JSONDecodeError:
                    logger.error(f"Failed to parse AI response as JSON: {content}")
                    return self.get_fallback_analysis()
            else:
                logger.error(f"OpenAI API error: {response.status_code} - {response.text}")
                return self.get_fallback_analysis()

        except Exception as e:
            logger.error(f"Error in message analysis: {e}")
            return self.get_fallback_analysis()

    def get_relevant_history(self, phone: str, chat_name: str, limit: int = 10) -> List[Dict]:
        query = """
        SELECT mh.sender, mh.content, mh.timestamp, mh.message_type
        FROM message_history mh
        JOIN webhook_messages wm ON mh.message_id = wm.message_id
        WHERE wm.phone_number = %s OR wm.chat_name = %s
        ORDER BY mh.timestamp DESC
        LIMIT %s
        """

        result = self.db.execute_query(query, (phone, chat_name, limit))
        return result if result else []

    def prepare_history_context(self, history: List[Dict]) -> str:
        if not history:
            return "No previous conversation history available."

        context_lines = []
        for msg in reversed(history[-5:]):  # Last 5 messages
            timestamp = msg.get('timestamp', '')
            sender = msg.get('sender', 'Unknown')
            content = msg.get('content', '')
            context_lines.append(f"[{timestamp}] {sender}: {content}")

        return "\n".join(context_lines)

    def get_fallback_analysis(self) -> Dict:
        return {
            "urgency_score": 5,
            "category": "general",
            "sentiment": "neutral",
            "keywords": ["message", "analysis"],
            "priority_level": "normal",
            "action_required": True,
            "recommended_response_time": "4hours",
            "business_context": "Standard customer message requiring review",
            "suggested_next_action": "Manual review required"
        }

    def route_to_agent(self, message: Dict, analysis: Dict) -> Dict:
        try:
            urgency = analysis.get('urgency_score', 5)
            category = analysis.get('category', 'general')

            target_agent = 'general_purpose'

            if category in ['technical', 'support'] or urgency >= 8:
                target_agent = 'business_workflow'
            elif 'code' in analysis.get('keywords', []):
                target_agent = 'code_debugger'

            agent_config = self.agents_config.get(target_agent)

            if not agent_config:
                logger.error(f"Agent configuration not found for: {target_agent}")
                return {'success': False, 'error': 'Agent not available'}

            payload = {
                'message': message,
                'analysis': analysis,
                'routing_info': {
                    'routed_by': 'enhanced_webhook_processor',
                    'timestamp': datetime.now().isoformat(),
                    'reason': f"Category: {category}, Urgency: {urgency}"
                }
            }

            response = requests.post(
                f"{agent_config['url']}/process",
                json=payload,
                timeout=30
            )

            if response.status_code == 200:
                return {
                    'success': True,
                    'agent': target_agent,
                    'response': response.json()
                }
            else:
                logger.error(f"Agent {target_agent} responded with status {response.status_code}")
                return {
                    'success': False,
                    'error': f"Agent returned status {response.status_code}"
                }

        except requests.exceptions.RequestException as e:
            logger.error(f"Error routing to agent: {e}")
            return {
                'success': False,
                'error': f"Request failed: {str(e)}"
            }

    def process_webhook(self, webhook_data: Dict) -> Dict:
        try:
            logger.info(f"Processing webhook: {webhook_data}")

            message_id = webhook_data.get('message_id', f"msg_{datetime.now().timestamp()}")

            saved_id = self.db.save_webhook_message(webhook_data)
            if not saved_id:
                logger.error("Failed to save webhook message to database")
                return {'success': False, 'error': 'Database save failed'}

            if 'history' in webhook_data:
                self.db.save_message_history(message_id, webhook_data['history'])

            analysis = self.analyze_message_with_history(webhook_data)

            self.db.save_analytics_result(message_id, analysis)

            routing_result = self.route_to_agent(webhook_data, analysis)

            result = {
                'success': True,
                'message_id': message_id,
                'database_id': saved_id,
                'analysis': analysis,
                'routing': routing_result,
                'processed_at': datetime.now().isoformat()
            }

            logger.info(f"Successfully processed message {message_id}")
            return result

        except Exception as e:
            logger.error(f"Error processing webhook: {e}")
            return {
                'success': False,
                'error': str(e)
            }

app = Flask(__name__)
processor = EnhancedWebhookProcessor()

@app.route('/webhook', methods=['POST'])
def handle_webhook():
    try:
        data = request.get_json()

        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400

        result = processor.process_webhook(data)

        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 500

    except Exception as e:
        logger.error(f"Webhook endpoint error: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'service': 'enhanced-webhook-integration',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/stats', methods=['GET'])
def get_stats():
    try:
        stats_query = """
        SELECT
            COUNT(*) as total_messages,
            SUM(CASE WHEN processed = 1 THEN 1 ELSE 0 END) as processed_messages,
            SUM(CASE WHEN processed = 0 THEN 1 ELSE 0 END) as pending_messages
        FROM webhook_messages
        WHERE created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
        """

        stats = processor.db.execute_query(stats_query)

        if stats and len(stats) > 0:
            return jsonify({
                'success': True,
                'stats': stats[0]
            })
        else:
            return jsonify({
                'success': True,
                'stats': {
                    'total_messages': 0,
                    'processed_messages': 0,
                    'pending_messages': 0
                }
            })

    except Exception as e:
        logger.error(f"Error getting stats: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8100))
    app.run(host='0.0.0.0', port=port, debug=True)