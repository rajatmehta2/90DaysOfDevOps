import os
import time
import psycopg2
from flask import Flask
from redis import Redis

app = Flask(__name__)

# Connect to Redis
redis_host = os.environ.get("REDIS_HOST", "redis")
redis_port = int(os.environ.get("REDIS_PORT", 6379))
redis = Redis(host=redis_host, port=redis_port, socket_timeout=3)

# Connect to PostgreSQL
db_host = os.environ.get("DB_HOST", "db")
db_name = os.environ.get("DB_NAME", "postgres")
db_user = os.environ.get("DB_USER", "postgres")
db_password = os.environ.get("DB_PASSWORD", "postgres")

def get_db_status():
    try:
        conn = psycopg2.connect(
            host=db_host,
            database=db_name,
            user=db_user,
            password=db_password,
            connect_timeout=3
        )
        cur = conn.cursor()
        cur.execute("SELECT version();")
        db_version = cur.fetchone()[0]
        cur.close()
        conn.close()
        return f"Connected to PostgreSQL successfully! Database Version: {db_version}"
    except Exception as e:
        return f"Failed to connect to PostgreSQL: {str(e)}"

@app.route('/')
def hello():
    try:
        visits = redis.incr('counter')
    except Exception as e:
        visits = f"Failed to connect to Redis: {str(e)}"
        
    db_status = get_db_status()
    
    return f"""
    <html>
        <head>
            <title>Day 34: Advanced Docker Compose Stack</title>
            <style>
                body {{
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    background: linear-gradient(135deg, #0f2027 0%, #203a43 50%, #2c5364 100%);
                    color: white;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                }}
                .card {{
                    background: rgba(255, 255, 255, 0.05);
                    backdrop-filter: blur(12px);
                    padding: 40px;
                    border-radius: 20px;
                    box-shadow: 0 15px 35px 0 rgba(0, 0, 0, 0.5);
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    text-align: center;
                    max-width: 600px;
                    width: 90%;
                }}
                h1 {{ 
                    margin-bottom: 20px; 
                    font-size: 2.2em;
                    font-weight: 700; 
                    background: linear-gradient(to right, #00f2fe, #4facfe);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                }}
                p {{ font-size: 1.1em; line-height: 1.6; color: #cfd8dc; }}
                .counter-box {{
                    font-size: 1.5em;
                    font-weight: bold;
                    color: #00ff87;
                    margin: 20px 0;
                    padding: 10px;
                    background: rgba(0, 255, 135, 0.1);
                    border-radius: 8px;
                    display: inline-block;
                }}
                .status {{
                    background: rgba(0, 0, 0, 0.3);
                    padding: 15px;
                    border-radius: 10px;
                    font-family: 'Courier New', Courier, monospace;
                    word-break: break-all;
                    margin-top: 25px;
                    border-left: 5px solid #00f2fe;
                    text-align: left;
                    font-size: 0.95em;
                }}
                .label {{
                    display: block;
                    font-size: 0.8em;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                    color: #8a9ba8;
                    margin-bottom: 5px;
                }}
            </style>
        </head>
        <body>
            <div class="card">
                <h1>🐳 Day 34: Advanced Multi-Container App Stack 🚀</h1>
                <p>Hello, DevOps World! This Flask application is running inside a Docker container orchestrated by Docker Compose.</p>
                <span class="label">Redis Cache Counter</span>
                <div class="counter-box">
                    Page Visits: {visits}
                </div>
                <div class="status">
                    <span class="label">PostgreSQL Live Health Status</span>
                    <strong>Status:</strong> {db_status}
                </div>
            </div>
        </body>
    </html>
    """

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
