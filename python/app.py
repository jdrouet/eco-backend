from datetime import datetime
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from gevent.pywsgi import WSGIServer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import sql
import psycopg2
import os
import time
import uuid
 
db = SQLAlchemy()
 
class LogEntry(db.Model):
    __tablename__ = 'mylogs'
 
    id = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    created_at = db.Column(db.TIMESTAMP, nullable=False)
    level = db.Column(db.String, nullable=False)
    payload = db.Column(db.JSON, nullable=False)
 
    def __init__(self, id, created_at, level, payload):
        self.id = id
        self.created_at = created_at
        self.level = level
        self.payload = payload
 
    def __repr__(self):
        return f"<LogEntry [id={self.id}, created_at={self.created_at}, level={self.level}]>"

    
    def serialize(self):
        res = {
                "id": self.id,
                "createdAt": int(time.mktime(self.created_at.timetuple())),
                "level": self.level
        }
        for key, value in self.payload.items():
            res[key] = value
        return res

    @staticmethod
    def from_payload(item):
        created_at = None
        level = None
        payload = {}
        for key, value in item.items():
            if key == "createdAt":
                created_at = datetime.fromtimestamp(value)
            elif key == "level":
                level = value
            else:
                payload[key] = value
        return LogEntry(None, created_at, level, payload)

app = Flask(__name__)

app.config.from_mapping(
    SQLALCHEMY_DATABASE_URI=os.getenv('DB_URL', 'postgresql://eco:dummy@localhost/eco'),
    SQLALCHEMY_TRACK_MODIFICATIONS=False,
)

db.init_app(app)

@app.route("/")
def status():
    return '', 204

@app.route("/search", methods=['GET'])
def search():
    limit = min(request.args.get('limit', default = 100, type = int), 200)
    offset = max(request.args.get('offset', default = 0, type = int), 0)
    rows = LogEntry.query.order_by(LogEntry.created_at.asc()).limit(limit).offset(offset).all()
    res = [entry.serialize() for entry in rows]
    return jsonify(res)

@app.route("/publish", methods=['POST'])
def publish():
    for row in request.json:
        entry = LogEntry.from_payload(row)
        db.session.add(entry)
    db.session.commit()
    return '', 204

if __name__ == '__main__':
    host = os.getenv('HOST', 'localhost')
    port = int(os.getenv('PORT', '5000'))
    print(f"Listen on {host}:{port}")
    http_server = WSGIServer((host, port), app)
    http_server.serve_forever()
