#!/usr/bin/env python3
"""
Simple Flask API for DevOps Learning Labs
Demonstrates: Health checks, logging, metrics
"""

from flask import Flask, jsonify
import os
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(
    level=os.getenv('LOG_LEVEL', 'INFO'),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.route('/health', methods=['GET'])
def health():
    """Liveness probe - is the app running?"""
    logger.info("Health check requested")
    return jsonify({"status": "healthy"}), 200

@app.route('/ready', methods=['GET'])
def readiness():
    """Readiness probe - is the app ready for traffic?"""
    logger.info("Readiness check requested")
    # Check dependencies here (database, cache, etc.)
    return jsonify({"status": "ready"}), 200

@app.route('/api/info', methods=['GET'])
def info():
    """Return app info"""
    return jsonify({
        "app": "DevOps Learning API",
        "version": os.getenv('APP_VERSION', '1.0.0'),
        "environment": os.getenv('ENVIRONMENT', 'development')
    }), 200

@app.route('/api/data', methods=['GET'])
def data():
    """Return sample data"""
    logger.info("Data endpoint accessed")
    return jsonify({
        "data": [
            {"id": 1, "name": "Item 1"},
            {"id": 2, "name": "Item 2"},
            {"id": 3, "name": "Item 3"}
        ]
    }), 200

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    logger.info(f"Starting Flask app on port {port}")
    app.run(host='0.0.0.0', port=port, debug=os.getenv('DEBUG', 'False') == 'True')
