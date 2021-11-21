from datetime import datetime
from flask import Flask, jsonify, request
from gevent.pywsgi import WSGIServer
from jsonschema import validate
import os
import time
import requests

app = Flask(__name__)

@app.route("/")
def status():
    return '', 204

schema = {
    "type": "object",
    "properties": {
        "ts": {
            "type": "number",
        },
        "tags": {
            "type": "object",
        },
        "values": {
            "type": "object",
        }
    },
    "required": ["ts", "tags", "values"]
}

blackhole_url = os.getenv('BLACKHOLE_URL', 'http://localhost:3010')

@app.route("/publish", methods=['POST'])
def publish():
    event = request.json
    validate(instance=event, schema=schema)
    event['tags']['through'] = 'python'
    res = requests.post(blackhole_url, data=event)
    if res.status_code >= 300:
        return res.text, r.status_code
    return '', 204

if __name__ == '__main__':
    host = os.getenv('HOST', 'localhost')
    port = int(os.getenv('PORT', '5000'))
    print(f"Listen on {host}:{port}")
    http_server = WSGIServer((host, port), app)
    http_server.serve_forever()
