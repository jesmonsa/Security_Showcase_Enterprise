#!/bin/bash
# Bastion Host Cloud-Init Script for ${cliente}

# Update system
dnf update -y

# Install security tools
dnf install -y fail2ban htop telnet nc nmap-ncat

# Configure fail2ban for SSH protection
cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = 22
logpath = /var/log/secure
maxretry = 3
bantime = 3600
EOF

# Start and enable fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Configure SSH security
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
systemctl restart sshd

# Create motd
cat > /etc/motd <<EOF
================================================================================
  BASTION HOST - ${cliente}
  Arquitectura de Referencia FSC
  
  WARNING: Authorized access only!
  All connections are monitored and logged.
================================================================================
EOF

echo "Bastion Host setup completed for ${cliente}" > /var/log/cloud-init-output.log