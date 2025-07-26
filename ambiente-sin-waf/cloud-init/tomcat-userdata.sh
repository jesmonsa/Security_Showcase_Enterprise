#!/bin/bash
# Tomcat Server Cloud-Init Script for ${cliente}

# Update system
dnf update -y

# Install Java and Tomcat
dnf install -y java-17-openjdk-devel tomcat

# Create simple webapp
mkdir -p /var/lib/tomcat/webapps/app
cat > /var/lib/tomcat/webapps/app/index.jsp <<EOF
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Tomcat Server - ${cliente}</title>
</head>
<body>
    <h1>Apache Tomcat Application Server</h1>
    <p>Cliente: ${cliente}</p>
    <p>Servidor: Apache Tomcat</p>
    <p>Java Version: <%= System.getProperty("java.version") %></p>
    <p>Status: Online</p>
    <hr>
    <p>Arquitectura de Referencia FSC</p>
</body>
</html>
EOF

# Configure Tomcat to listen on port 8080
sed -i 's/port="8080"/port="8080"/' /etc/tomcat/server.xml

# Start and enable Tomcat
systemctl enable tomcat
systemctl start tomcat

# Configure firewall for port 8080
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

# Install monitoring tools
dnf install -y htop telnet nc

echo "Tomcat Server setup completed for ${cliente}" > /var/log/cloud-init-output.log