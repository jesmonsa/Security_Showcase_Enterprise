#!/bin/bash
# Apache Server Cloud-Init Script for ${cliente}

# Update system
dnf update -y

# Install Apache
dnf install -y httpd

# Create health check endpoint
cat > /var/www/html/health <<EOF
OK
EOF

# Create index page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Apache Server - ${cliente}</title>
</head>
<body>
    <h1>Apache Web Server</h1>
    <p>Cliente: ${cliente}</p>
    <p>Servidor: Apache HTTP Server</p>
    <p>Status: Online</p>
    <hr>
    <p>Arquitectura de Referencia FSC</p>
</body>
</html>
EOF

# Start and enable Apache
systemctl enable httpd
systemctl start httpd

# Configure firewall
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# Install monitoring tools
dnf install -y htop telnet nc

echo "Apache Server setup completed for ${cliente}" > /var/log/cloud-init-output.log