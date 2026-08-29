#!/bin/bash

apt update -y
apt install -y nginx

systemctl enable nginx
systemctl start nginx

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AWS 3-Tier Application</title>
</head>
<body>
    <h1>AWS 3-Tier Web Application</h1>
    <h2>Web Tier - Nginx</h2>
    <p>Web server is running successfully.</p>
</body>
</html>
EOF