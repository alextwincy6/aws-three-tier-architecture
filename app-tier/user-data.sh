#!/bin/bash

apt-get update -y

apt-get install -y python3 python3-pip python3-venv

mkdir -p /opt/app

python3 -m venv /opt/app/venv

/opt/app/venv/bin/pip install flask

cat > /opt/app/app.py <<'EOF'
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Application Tier is working successfully!"

@app.route("/health")
def health():
    return "OK"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

cat > /etc/systemd/system/app.service <<'EOF'
[Unit]
Description=Flask Application
After=network.target

[Service]
WorkingDirectory=/opt/app
ExecStart=/opt/app/venv/bin/python /opt/app/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable app
systemctl start app