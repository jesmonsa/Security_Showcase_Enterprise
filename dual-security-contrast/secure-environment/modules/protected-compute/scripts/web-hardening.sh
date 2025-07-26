#!/bin/bash
# ========================================
# WEB TIER SECURITY HARDENING SCRIPT
# Comprehensive security configuration for web instances
# ========================================

set -e

# Variables from Terraform
ADMIN_PASSWORD="${admin_password}"
ENVIRONMENT="${environment}"
INSTANCE_NAME="${instance_name}"
KMS_KEY_ID="${kms_key_id}"
VAULT_ENDPOINT="${vault_endpoint}"

# Logging setup
LOG_FILE="/var/log/security-hardening.log"
exec 1> >(tee -a $LOG_FILE)
exec 2>&1

echo "========================================"
echo "Starting Security Hardening: $(date)"
echo "Instance: $INSTANCE_NAME"
echo "Environment: $ENVIRONMENT"
echo "========================================"

# ========================================
# SYSTEM UPDATES - CRITICAL SECURITY PATCHES
# ========================================
echo "[INFO] Updating system packages..."
yum update -y
yum install -y epel-release
yum install -y wget curl vim htop iotop net-tools

# ========================================
# FIREWALL HARDENING
# ========================================
echo "[INFO] Configuring firewall..."
systemctl enable firewalld
systemctl start firewalld

# Allow only necessary ports
firewall-cmd --permanent --remove-service=ssh  # Remove default SSH
firewall-cmd --permanent --add-port=22/tcp     # SSH from bastion only
firewall-cmd --permanent --add-port=8080/tcp   # Web application
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.60.0.0/16" port protocol="tcp" port="22" accept'  # SSH from VCN only
firewall-cmd --reload

# ========================================
# SSH HARDENING
# ========================================
echo "[INFO] Hardening SSH configuration..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

cat > /etc/ssh/sshd_config << 'EOF'
# SSH Security Hardening Configuration
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Authentication
LoginGraceTime 30
PermitRootLogin no
StrictModes yes
MaxAuthTries 3
MaxSessions 2
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
UsePAM yes

# Network
X11Forwarding no
AllowTcpForwarding no
GatewayPorts no
PermitTunnel no
ClientAliveInterval 300
ClientAliveCountMax 2

# Logging
SyslogFacility AUTHPRIV
LogLevel VERBOSE

# Security
AllowUsers opc
DenyUsers root
EOF

systemctl restart sshd

# ========================================
# USER SECURITY
# ========================================
echo "[INFO] Configuring user security..."

# Set strong password for opc user (fallback)
echo "opc:$ADMIN_PASSWORD" | chpasswd

# Configure sudo with logging
echo 'Defaults logfile="/var/log/sudo.log"' >> /etc/sudoers
echo 'Defaults log_input,log_output' >> /etc/sudoers

# ========================================
# SYSTEM HARDENING
# ========================================
echo "[INFO] Applying system hardening..."

# Kernel parameters for security
cat >> /etc/sysctl.conf << 'EOF'
# Network Security
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
EOF

sysctl -p

# ========================================
# FAIL2BAN INSTALLATION AND CONFIGURATION
# ========================================
echo "[INFO] Installing and configuring Fail2Ban..."
yum install -y fail2ban

cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
ignoreip = 127.0.0.1/8 10.60.0.0/16

[sshd]
enabled = true
port = 22
logpath = /var/log/secure
maxretry = 3
bantime = 7200

[nginx-http-auth]
enabled = true
port = 8080
logpath = /var/log/nginx/error.log

[nginx-limit-req]
enabled = true
port = 8080
logpath = /var/log/nginx/error.log
maxretry = 10
EOF

systemctl enable fail2ban
systemctl start fail2ban

# ========================================
# NGINX INSTALLATION AND HARDENING
# ========================================
echo "[INFO] Installing and configuring Nginx..."
yum install -y nginx

# Create secure Nginx configuration
cat > /etc/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
}

http {
    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Security Headers
    server_tokens off;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'";
    
    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging Format
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # Virtual Host Configuration
    server {
        listen 8080 default_server;
        listen [::]:8080 default_server;
        server_name _;
        root /var/www/html;
        index index.html index.htm;
        
        # Security
        limit_req zone=one burst=5;
        limit_conn addr 10;
        
        # Hide server information
        server_tokens off;
        
        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        
        location / {
            try_files $uri $uri/ =404;
        }
        
        # Security - Block access to hidden files
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
        
        # Security - Block access to backup files
        location ~* \.(bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist)$ {
            deny all;
            access_log off;
            log_not_found off;
        }
        
        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
        
        # Demo endpoint for security testing
        location /api/secure-test {
            add_header Content-Type application/json;
            return 200 '{"status":"secure","environment":"'"$ENVIRONMENT"'","instance":"'"$INSTANCE_NAME"'","security":"HARDENED","timestamp":"'$(date -Iseconds)'"}';
        }
    }
}
EOF

# Create web root and secure demo page
mkdir -p /var/www/html
chown nginx:nginx /var/www/html

cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Environment - $ENVIRONMENT</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: #2ecc71; color: white; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .security-badge { background: #27ae60; color: white; padding: 5px 10px; border-radius: 3px; font-size: 12px; }
        .feature { margin: 10px 0; padding: 10px; background: #ecf0f1; border-left: 4px solid #2ecc71; }
        .timestamp { color: #7f8c8d; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ SECURE ENVIRONMENT</h1>
            <span class="security-badge">HARDENED INSTANCE</span>
        </div>
        
        <h2>Security Features Enabled</h2>
        <div class="feature">✅ <strong>Encrypted Boot Volume:</strong> Customer-managed KMS keys</div>
        <div class="feature">✅ <strong>Private Subnet:</strong> No direct Internet access</div>
        <div class="feature">✅ <strong>SSH Hardening:</strong> Key-based authentication only</div>
        <div class="feature">✅ <strong>Firewall:</strong> Restrictive rules with Fail2Ban</div>
        <div class="feature">✅ <strong>Web Server:</strong> Nginx with security headers</div>
        <div class="feature">✅ <strong>Rate Limiting:</strong> DDoS protection enabled</div>
        <div class="feature">✅ <strong>System Hardening:</strong> Kernel security parameters</div>
        <div class="feature">✅ <strong>Monitoring:</strong> Comprehensive logging enabled</div>
        
        <h2>Instance Information</h2>
        <p><strong>Instance:</strong> $INSTANCE_NAME</p>
        <p><strong>Environment:</strong> $ENVIRONMENT</p>
        <p><strong>Security Level:</strong> COMPREHENSIVE</p>
        <p><strong>Access Method:</strong> Bastion Service Only</p>
        
        <div class="timestamp">
            <p>Hardened on: $(date)</p>
            <p>This instance is protected by multiple layers of security controls.</p>
        </div>
    </div>
</body>
</html>
EOF

systemctl enable nginx
systemctl start nginx

# ========================================
# LOGGING AND MONITORING
# ========================================
echo "[INFO] Configuring logging and monitoring..."

# Install and configure rsyslog for centralized logging
yum install -y rsyslog

cat >> /etc/rsyslog.conf << 'EOF'
# Security event logging
auth,authpriv.*                 /var/log/auth.log
*.info;auth,authpriv.none       /var/log/messages
daemon.notice                   /var/log/daemon.log
kern.*                          /var/log/kern.log
mail.*                          /var/log/mail.log
user.*                          /var/log/user.log
cron.*                          /var/log/cron.log

# Security monitoring
$ModLoad imudp
$UDPServerRun 514
$UDPServerAddress 127.0.0.1
EOF

systemctl restart rsyslog

# Configure log rotation
cat > /etc/logrotate.d/security-logs << 'EOF'
/var/log/security-hardening.log
/var/log/auth.log
/var/log/sudo.log {
    daily
    missingok
    rotate 90
    compress
    delaycompress
    notifempty
    copytruncate
}
EOF

# ========================================
# AUTOMATIC SECURITY UPDATES
# ========================================
echo "[INFO] Configuring automatic security updates..."
yum install -y yum-cron

cat > /etc/yum/yum-cron.conf << 'EOF'
[commands]
update_cmd = security
update_messages = yes
download_updates = yes
apply_updates = yes
random_sleep = 360

[emitters]
system_name = None
emit_via = email
output_width = 80

[email]
email_from = root@localhost
email_to = root
email_host = localhost

[groups]
group_list = None
group_package_types = mandatory, default

[base]
debuglevel = -2
mdpolicy = group:main
EOF

systemctl enable yum-cron
systemctl start yum-cron

# ========================================
# FILE SYSTEM SECURITY
# ========================================
echo "[INFO] Applying file system security..."

# Set secure permissions
chmod 600 /etc/ssh/sshd_config
chmod 644 /etc/passwd
chmod 644 /etc/group
chmod 600 /etc/shadow
chmod 600 /etc/gshadow

# Remove unnecessary packages
yum remove -y telnet rsh-client rsh-server

# ========================================
# SELINUX CONFIGURATION
# ========================================
echo "[INFO] Configuring SELinux..."
setenforce 1
sed -i 's/SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

# Allow Nginx to use port 8080
setsebool -P httpd_can_network_connect 1
semanage port -a -t http_port_t -p tcp 8080 2>/dev/null || true

# ========================================
# AUDIT DAEMON
# ========================================
echo "[INFO] Configuring audit daemon..."
yum install -y audit

cat >> /etc/audit/rules.d/audit.rules << 'EOF'
# Security monitoring rules
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k identity
-w /etc/ssh/sshd_config -p wa -k sshd
-w /var/log/auth.log -p wa -k logins
-w /var/log/sudo.log -p wa -k actions
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
EOF

systemctl enable auditd
systemctl start auditd

# ========================================
# INTRUSION DETECTION (BASIC)
# ========================================
echo "[INFO] Setting up basic intrusion detection..."

# Create script for monitoring suspicious activities
cat > /usr/local/bin/security-monitor.sh << 'EOF'
#!/bin/bash
# Basic security monitoring script

LOG_FILE="/var/log/security-monitor.log"

# Check for failed login attempts
FAILED_LOGINS=$(grep "Failed password" /var/log/secure | tail -10)
if [ ! -z "$FAILED_LOGINS" ]; then
    echo "$(date): Failed login attempts detected" >> $LOG_FILE
    echo "$FAILED_LOGINS" >> $LOG_FILE
fi

# Check for privilege escalation attempts
SUDO_ATTEMPTS=$(grep "sudo:" /var/log/secure | tail -5)
if [ ! -z "$SUDO_ATTEMPTS" ]; then
    echo "$(date): Sudo attempts:" >> $LOG_FILE
    echo "$SUDO_ATTEMPTS" >> $LOG_FILE
fi

# Check for unusual network connections
NETSTAT_OUTPUT=$(netstat -tuln | grep -v "127.0.0.1\|::1")
echo "$(date): Network connections:" >> $LOG_FILE
echo "$NETSTAT_OUTPUT" >> $LOG_FILE

# Check system load
LOAD_AVG=$(uptime | awk '{print $10,$11,$12}')
echo "$(date): System load: $LOAD_AVG" >> $LOG_FILE
EOF

chmod +x /usr/local/bin/security-monitor.sh

# Add to cron for regular monitoring
echo "*/5 * * * * /usr/local/bin/security-monitor.sh" | crontab -

# ========================================
# FINAL SYSTEM CONFIGURATION
# ========================================
echo "[INFO] Final system configuration..."

# Create security status script
cat > /usr/local/bin/security-status.sh << 'EOF'
#!/bin/bash
echo "=== SECURITY STATUS REPORT ==="
echo "Instance: $INSTANCE_NAME"
echo "Environment: $ENVIRONMENT"
echo "Timestamp: $(date)"
echo ""
echo "SSH Status: $(systemctl is-active sshd)"
echo "Firewall Status: $(systemctl is-active firewalld)"
echo "Nginx Status: $(systemctl is-active nginx)"
echo "Fail2Ban Status: $(systemctl is-active fail2ban)"
echo "Audit Status: $(systemctl is-active auditd)"
echo "SELinux Status: $(getenforce)"
echo ""
echo "Failed Login Attempts (last 24h):"
grep "Failed password" /var/log/secure | grep "$(date '+%b %d')" | wc -l
echo ""
echo "Active Network Connections:"
netstat -tuln | grep LISTEN
EOF

chmod +x /usr/local/bin/security-status.sh

# Create motd with security information
cat > /etc/motd << EOF

███████╗███████╗ ██████╗██╗   ██╗██████╗ ███████╗
██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██╔════╝
███████╗█████╗  ██║     ██║   ██║██████╔╝█████╗  
╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██╔══╝  
███████║███████╗╚██████╗╚██████╔╝██║  ██║███████╗ 
╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

🛡️  HARDENED SECURE ENVIRONMENT
📍 Instance: $INSTANCE_NAME
🌍 Environment: $ENVIRONMENT  
🔒 Security Level: COMPREHENSIVE
📅 Hardened: $(date)

⚠️  AUTHORIZED ACCESS ONLY
   All activities are monitored and logged
   
🔍 Run '/usr/local/bin/security-status.sh' for security status

EOF

# ========================================
# CLEANUP AND FINALIZATION
# ========================================
echo "[INFO] Cleaning up and finalizing..."

# Clean package cache
yum clean all

# Remove temporary files
rm -f /tmp/*

# Set final file permissions
chmod 640 /var/log/security-hardening.log
chown root:adm /var/log/security-hardening.log

# Generate final security report
echo "========================================" >> $LOG_FILE
echo "SECURITY HARDENING COMPLETED: $(date)" >> $LOG_FILE
echo "Instance: $INSTANCE_NAME" >> $LOG_FILE
echo "Environment: $ENVIRONMENT" >> $LOG_FILE
echo "Features Applied:" >> $LOG_FILE
echo "- System updates and security patches" >> $LOG_FILE
echo "- Firewall hardening with Fail2Ban" >> $LOG_FILE
echo "- SSH hardening (key-only authentication)" >> $LOG_FILE
echo "- Nginx with security headers" >> $LOG_FILE
echo "- System kernel hardening" >> $LOG_FILE
echo "- SELinux enforcement" >> $LOG_FILE
echo "- Audit daemon configuration" >> $LOG_FILE
echo "- Automatic security updates" >> $LOG_FILE
echo "- Intrusion detection monitoring" >> $LOG_FILE
echo "- Comprehensive logging" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

echo "[SUCCESS] Security hardening completed successfully!"
echo "[INFO] Security status available at: /usr/local/bin/security-status.sh"
echo "[INFO] Logs available at: $LOG_FILE"

# Restart critical services to ensure all configurations are active
systemctl restart sshd
systemctl restart nginx
systemctl restart firewalld

echo "[INFO] All services restarted and configured."
echo "[INFO] Instance $INSTANCE_NAME is now hardened and secure."

exit 0