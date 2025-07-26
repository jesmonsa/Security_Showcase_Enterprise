#!/bin/bash
# ========================================
# BASTION HOST SECURITY HARDENING SCRIPT
# Maximum security configuration for bastion host
# ========================================

set -e

# Variables from Terraform
ADMIN_PASSWORD="${admin_password}"
ENVIRONMENT="${environment}"
VAULT_ENDPOINT="${vault_endpoint}"

# Logging setup
LOG_FILE="/var/log/bastion-security-hardening.log"
exec 1> >(tee -a $LOG_FILE)
exec 2>&1

echo "========================================"
echo "Starting Bastion Host Security Hardening: $(date)"
echo "Environment: $ENVIRONMENT"
echo "Purpose: Secure Administrative Access"
echo "========================================"

# ========================================
# SYSTEM UPDATES - CRITICAL PATCHES ONLY
# ========================================
echo "[INFO] Updating system with security patches..."
yum update -y
yum install -y epel-release
yum install -y wget curl vim htop iotop net-tools audit
yum install -y fail2ban psacct sysstat

# ========================================
# MAXIMUM SSH HARDENING FOR BASTION
# ========================================
echo "[INFO] Applying maximum SSH hardening..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original

cat > /etc/ssh/sshd_config << 'EOF'
# Maximum Security SSH Configuration for Bastion Host
Port 22
Protocol 2

# Host keys - only secure algorithms
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Key exchange, ciphers, and MACs - only strongest
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512

# Authentication - maximum security
LoginGraceTime 20
PermitRootLogin no
StrictModes yes
MaxAuthTries 2
MaxSessions 2
MaxStartups 2:30:10

# Key-based authentication only
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
UsePAM yes

# No forwarding or tunneling
X11Forwarding no
X11DisplayOffset 10
X11UseLocalhost yes
AllowTcpForwarding no
AllowStreamLocalForwarding no
GatewayPorts no
PermitTunnel no
PermitUserRC no

# Connection settings
TCPKeepAlive no
ClientAliveInterval 300
ClientAliveCountMax 1
Compression no

# Logging - maximum verbosity
SyslogFacility AUTHPRIV
LogLevel VERBOSE

# User restrictions
AllowUsers opc
DenyUsers root bin daemon adm lp sync shutdown halt mail operator games gopher ftp nobody
DenyGroups root bin daemon adm lp mail operator games gopher ftp nobody

# Additional security
PermitUserEnvironment no
AcceptEnv LANG LC_*
UseDNS no
PrintMotd yes
PrintLastLog yes
Banner /etc/ssh/banner
EOF

# Create SSH warning banner
cat > /etc/ssh/banner << 'EOF'

===============================================================================
                              *** WARNING ***
                          AUTHORIZED ACCESS ONLY
===============================================================================

 This is a SECURE BASTION HOST providing controlled access to private resources.
 
 * All activities are monitored, logged, and recorded
 * Unauthorized access attempts will be prosecuted
 * Session recordings are maintained per security policy
 * This system is for authorized personnel only
 
 By proceeding, you acknowledge awareness of monitoring and agree to comply
 with all security policies and procedures.
 
===============================================================================

EOF

# Generate new host keys with stronger algorithms
rm -f /etc/ssh/ssh_host_*
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t ecdsa -b 521 -f /etc/ssh/ssh_host_ecdsa_key -N ""
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

# Set proper permissions
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub

systemctl restart sshd

# ========================================
# EXTREME FIREWALL HARDENING
# ========================================
echo "[INFO] Configuring maximum firewall security..."
systemctl enable firewalld
systemctl start firewalld

# Remove all default services and ports
firewall-cmd --permanent --remove-service=ssh
firewall-cmd --permanent --remove-service=dhcpv6-client

# Only allow SSH from management network (to be used with Bastion Service)
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.60.0.0/16" port protocol="tcp" port="22" accept'

# Enable connection tracking and logging
firewall-cmd --permanent --set-log-denied=all
firewall-cmd --reload

# ========================================
# USER SECURITY - BASTION SPECIFIC
# ========================================
echo "[INFO] Configuring bastion user security..."

# Set strong password for opc user
echo "opc:$ADMIN_PASSWORD" | chpasswd

# Create dedicated bastion user with restricted shell
useradd -m -s /bin/rbash -c "Bastion User" bastionuser
echo "bastionuser:$ADMIN_PASSWORD" | chpasswd

# Configure restricted bash environment
mkdir -p /home/bastionuser/bin
ln -s /usr/bin/ssh /home/bastionuser/bin/ssh
ln -s /usr/bin/scp /home/bastionuser/bin/scp
ln -s /usr/bin/ls /home/bastionuser/bin/ls
ln -s /usr/bin/pwd /home/bastionuser/bin/pwd
ln -s /usr/bin/exit /home/bastionuser/bin/exit

echo 'export PATH=$HOME/bin' >> /home/bastionuser/.bash_profile
echo 'export PS1="[BASTION]\u@\h:\w\$ "' >> /home/bastionuser/.bash_profile

chown -R bastionuser:bastionuser /home/bastionuser
chmod 755 /home/bastionuser/bin

# Configure sudo with extensive logging
cat >> /etc/sudoers << 'EOF'
Defaults logfile="/var/log/sudo.log"
Defaults log_input,log_output
Defaults requiretty
Defaults env_reset
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults timestamp_timeout=5
Defaults passwd_tries=2
Defaults badpass_message="Access denied. This incident will be reported."
EOF

# ========================================
# SYSTEM HARDENING - MAXIMUM SECURITY
# ========================================
echo "[INFO] Applying maximum system hardening..."

# Kernel parameters for extreme security
cat >> /etc/sysctl.conf << 'EOF'
# Network Security - Maximum Hardening
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
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# IPv6 Security (disable if not needed)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# Kernel Security
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 3
kernel.core_uses_pid = 1
kernel.pid_max = 65536

# File System Security
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 2
fs.protected_regular = 2

# Memory Protection
vm.mmap_rnd_bits = 32
vm.mmap_rnd_compat_bits = 16
EOF

sysctl -p

# ========================================
# ADVANCED FAIL2BAN CONFIGURATION
# ========================================
echo "[INFO] Configuring advanced Fail2Ban for bastion..."
yum install -y fail2ban

cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 86400
findtime = 600
maxretry = 2
ignoreip = 127.0.0.1/8
action = %(action_mwl)s

[sshd]
enabled = true
port = 22
logpath = /var/log/secure
maxretry = 2
bantime = 604800
findtime = 300

[sshd-ddos]
enabled = true
port = 22
logpath = /var/log/secure
filter = sshd-ddos
maxretry = 5
bantime = 3600

[recidive]
enabled = true
logpath = /var/log/fail2ban.log
banaction = iptables-allports
bantime = 2592000
findtime = 86400
maxretry = 3
EOF

# Create custom SSH brute force filter
cat > /etc/fail2ban/filter.d/sshd-ddos.conf << 'EOF'
[Definition]
failregex = sshd(?:\[\d+\])?: Did not receive identification string from <HOST>
            sshd(?:\[\d+\])?: Connection closed by <HOST> port \d+ \[preauth\]
            sshd(?:\[\d+\])?: Disconnected from <HOST> port \d+ \[preauth\]
ignoreregex =
EOF

systemctl enable fail2ban
systemctl start fail2ban

# ========================================
# COMPREHENSIVE AUDIT CONFIGURATION
# ========================================
echo "[INFO] Configuring comprehensive audit logging..."
yum install -y audit audit-libs

cat > /etc/audit/rules.d/bastion.rules << 'EOF'
# Bastion Host Comprehensive Audit Rules

# Remove any existing rules
-D

# Set buffer size
-b 8192

# Failure mode (0=silent, 1=printk, 2=panic)
-f 1

# Identity changes
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/sudoers -p wa -k identity
-w /etc/sudoers.d/ -p wa -k identity

# SSH configuration
-w /etc/ssh/sshd_config -p wa -k sshd
-w /etc/ssh/ -p wa -k ssh-config

# Authentication logs
-w /var/log/auth.log -p wa -k logins
-w /var/log/secure -p wa -k logins
-w /var/log/sudo.log -p wa -k actions

# System configuration
-w /etc/hosts -p wa -k network
-w /etc/hostname -p wa -k network
-w /etc/resolv.conf -p wa -k network

# Firewall changes
-w /etc/firewalld/ -p wa -k firewall
-w /etc/sysconfig/iptables -p wa -k firewall

# System calls monitoring
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change

# Process execution
-a always,exit -F arch=b64 -S execve -k process-execution
-a always,exit -F arch=b32 -S execve -k process-execution

# File access
-a always,exit -F arch=b64 -S open -S openat -S creat -k file-access
-a always,exit -F arch=b32 -S open -S openat -S creat -k file-access

# Network connections
-a always,exit -F arch=b64 -S connect -k network-connect
-a always,exit -F arch=b32 -S connect -k network-connect

# Module loading
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules
-a always,exit -F arch=b32 -S init_module -S delete_module -k modules

# Make rules immutable
-e 2
EOF

systemctl enable auditd
systemctl start auditd

# ========================================
# SESSION RECORDING AND MONITORING
# ========================================
echo "[INFO] Setting up session recording and monitoring..."

# Install script for session recording
yum install -y script

# Create session recording wrapper
cat > /usr/local/bin/record-session.sh << 'EOF'
#!/bin/bash
# Session recording wrapper for bastion host

USER=$(whoami)
DATE=$(date +"%Y%m%d_%H%M%S")
SESSION_DIR="/var/log/sessions"
SESSION_FILE="$SESSION_DIR/${USER}_${DATE}.log"

# Create session directory
mkdir -p $SESSION_DIR
chmod 750 $SESSION_DIR

# Start session recording
echo "[BASTION] Session recording started for $USER at $(date)" >> $SESSION_FILE
echo "[BASTION] Source IP: $SSH_CLIENT" >> $SESSION_FILE
echo "[BASTION] Terminal: $SSH_TTY" >> $SESSION_FILE
echo "========================================" >> $SESSION_FILE

# Run the original shell with recording
script -a -f $SESSION_FILE

echo "[BASTION] Session ended at $(date)" >> $SESSION_FILE
EOF

chmod +x /usr/local/bin/record-session.sh

# Modify shell profiles to enable recording
echo '/usr/local/bin/record-session.sh' >> /etc/profile

# ========================================
# INTRUSION DETECTION SYSTEM
# ========================================
echo "[INFO] Setting up intrusion detection..."

cat > /usr/local/bin/bastion-ids.sh << 'EOF'
#!/bin/bash
# Bastion Host Intrusion Detection System

LOG_FILE="/var/log/bastion-ids.log"
ALERT_FILE="/var/log/bastion-alerts.log"

# Function to log alerts
log_alert() {
    echo "$(date): ALERT - $1" >> $ALERT_FILE
    echo "$(date): ALERT - $1" >> $LOG_FILE
    logger -p auth.alert "BASTION ALERT: $1"
}

# Check for multiple failed login attempts
FAILED_LOGINS=$(grep "Failed password" /var/log/secure | grep "$(date '+%b %d')" | wc -l)
if [ $FAILED_LOGINS -gt 5 ]; then
    log_alert "Multiple failed login attempts detected: $FAILED_LOGINS"
fi

# Check for root login attempts
ROOT_ATTEMPTS=$(grep "root" /var/log/secure | grep "$(date '+%b %d')" | wc -l)
if [ $ROOT_ATTEMPTS -gt 0 ]; then
    log_alert "Root login attempts detected: $ROOT_ATTEMPTS"
fi

# Check for unusual sudo usage
SUDO_USAGE=$(grep "sudo:" /var/log/secure | grep "$(date '+%b %d')" | wc -l)
if [ $SUDO_USAGE -gt 10 ]; then
    log_alert "High sudo usage detected: $SUDO_USAGE commands"
fi

# Check for new processes
NEW_PROCESSES=$(ps aux | wc -l)
echo "$(date): Active processes: $NEW_PROCESSES" >> $LOG_FILE

# Check network connections
NETWORK_CONNECTIONS=$(netstat -tuln | grep LISTEN | wc -l)
echo "$(date): Listening services: $NETWORK_CONNECTIONS" >> $LOG_FILE

# Check for unusual file modifications
FILE_CHANGES=$(find /etc /home -type f -mtime -1 2>/dev/null | wc -l)
if [ $FILE_CHANGES -gt 20 ]; then
    log_alert "High number of file modifications: $FILE_CHANGES"
fi

# Check system load
LOAD_AVG=$(uptime | awk '{print $10}' | sed 's/,//')
LOAD_NUM=$(echo $LOAD_AVG | awk '{print $1*100}')
if [ ${LOAD_NUM%.*} -gt 200 ]; then
    log_alert "High system load detected: $LOAD_AVG"
fi

# Check for banned IPs
BANNED_IPS=$(fail2ban-client status sshd | grep "Banned IP list:" | awk -F':' '{print $2}' | wc -w)
if [ $BANNED_IPS -gt 0 ]; then
    echo "$(date): Banned IPs: $BANNED_IPS" >> $LOG_FILE
fi
EOF

chmod +x /usr/local/bin/bastion-ids.sh

# Schedule IDS to run every minute
echo "* * * * * /usr/local/bin/bastion-ids.sh" | crontab -

# ========================================
# SELINUX MAXIMUM ENFORCEMENT
# ========================================
echo "[INFO] Configuring SELinux for maximum security..."
setenforce 1
sed -i 's/SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

# Install additional SELinux tools
yum install -y policycoreutils-python-utils setroubleshoot-server

# Configure SELinux for SSH
setsebool -P ssh_sysadm_login off
setsebool -P ssh_chroot_rw_homedirs off

# ========================================
# SYSTEM MONITORING AND ALERTING
# ========================================
echo "[INFO] Setting up system monitoring..."

# Install system monitoring tools
yum install -y sysstat iotop htop

# Configure system accounting
systemctl enable psacct
systemctl start psacct

# Create comprehensive status script
cat > /usr/local/bin/bastion-status.sh << 'EOF'
#!/bin/bash
echo "==============================================="
echo "      BASTION HOST SECURITY STATUS"
echo "==============================================="
echo "Timestamp: $(date)"
echo "Hostname: $(hostname)"
echo "Environment: $ENVIRONMENT"
echo ""
echo "=== SYSTEM STATUS ==="
echo "Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
echo "Load Average: $(uptime | awk '{print $10,$11,$12}')"
echo "Memory Usage: $(free | grep Mem | awk '{printf("%.2f%%", $3/$2 * 100.0)}')"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}')"
echo ""
echo "=== SECURITY SERVICES ==="
echo "SSH: $(systemctl is-active sshd)"
echo "Firewall: $(systemctl is-active firewalld)"
echo "Fail2Ban: $(systemctl is-active fail2ban)"
echo "Audit: $(systemctl is-active auditd)"
echo "SELinux: $(getenforce)"
echo ""
echo "=== SECURITY STATISTICS ==="
echo "Failed Logins (today): $(grep 'Failed password' /var/log/secure | grep "$(date '+%b %d')" | wc -l)"
echo "Successful Logins (today): $(grep 'Accepted publickey' /var/log/secure | grep "$(date '+%b %d')" | wc -l)"
echo "Banned IPs: $(fail2ban-client status sshd | grep 'Banned IP list:' | awk -F':' '{print $2}' | wc -w)"
echo "Active Sessions: $(who | wc -l)"
echo ""
echo "=== NETWORK STATUS ==="
echo "Listening Services:"
netstat -tuln | grep LISTEN | awk '{print $1" "$4}' | sort
echo ""
echo "=== RECENT ALERTS ==="
tail -5 /var/log/bastion-alerts.log 2>/dev/null || echo "No recent alerts"
echo ""
echo "=== AUDIT SUMMARY ==="
echo "Audit Events (last hour): $(ausearch -ts recent 2>/dev/null | wc -l)"
echo "Session Recordings: $(ls -1 /var/log/sessions/*.log 2>/dev/null | wc -l)"
echo "==============================================="
EOF

chmod +x /usr/local/bin/bastion-status.sh

# ========================================
# LOG ROTATION AND MANAGEMENT
# ========================================
echo "[INFO] Configuring log rotation..."

cat > /etc/logrotate.d/bastion-logs << 'EOF'
/var/log/bastion-*.log
/var/log/sessions/*.log {
    daily
    missingok
    rotate 365
    compress
    delaycompress
    notifempty
    copytruncate
    postrotate
        systemctl reload rsyslog
    endscript
}

/var/log/sudo.log {
    daily
    missingok
    rotate 365
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
# MOTD AND FINAL CONFIGURATION
# ========================================
cat > /etc/motd << EOF

██████╗  ███████╗ ███████╗████████╗███╗ ███╗
██╔══██╗██╔════╝██╔════╝╚══██╔══╝████╗████║
██████╔╝███████╗█████╗     ██║   ██╔████╔██║
██╔══██╗██╔════╝╚════██╗    ██║   ██║╚██╔╝██║
██████╔╝███████╗███████║    ██║   ██║ ╚═╝ ██║
╚═════╝ ╚══════╝╚══════╝    ╚═╝   ╚═╝     ╚═╝

🛡️  MAXIMUM SECURITY BASTION HOST
🌍 Environment: $ENVIRONMENT  
🔒 Security Level: MAXIMUM
📅 Hardened: $(date)

⚠️  CRITICAL SECURITY NOTICE:
   • All activities are comprehensively monitored and recorded
   • Session recordings are maintained and auditable
   • Unauthorized access attempts trigger immediate alerts
   • This system enforces maximum security controls
   • Compliance with security policies is mandatory

🔍 Security Features:
   • Maximum SSH hardening (key-only, restricted algorithms)
   • Advanced firewall with connection logging
   • Real-time intrusion detection system
   • Comprehensive audit logging
   • Session recording and monitoring
   • SELinux maximum enforcement
   • Automated security updates
   • Fail2Ban with aggressive policies

🔍 Commands:
   /usr/local/bin/bastion-status.sh - Security status
   fail2ban-client status - Banned IPs
   ausearch -ts recent - Recent audit events

EOF

# ========================================
# FINAL SECURITY LOCKDOWN
# ========================================
echo "[INFO] Applying final security lockdown..."

# Set strict file permissions
chmod 700 /root
chmod 700 /home/opc
chmod 700 /home/bastionuser
chmod 600 /etc/ssh/sshd_config
chmod 600 /etc/shadow
chmod 600 /etc/gshadow
chmod 644 /etc/passwd
chmod 644 /etc/group

# Remove unnecessary packages and services
yum remove -y telnet rsh-client rsh-server tftp-server vsftpd
systemctl disable bluetooth 2>/dev/null || true
systemctl disable cups 2>/dev/null || true

# Clean up
yum clean all
rm -rf /tmp/*

# Set immutable flags on critical files
chattr +i /etc/passwd
chattr +i /etc/shadow
chattr +i /etc/group
chattr +i /etc/gshadow
chattr +i /etc/ssh/sshd_config

# Final security status
echo "========================================" >> $LOG_FILE
echo "BASTION HOST MAXIMUM SECURITY HARDENING COMPLETED: $(date)" >> $LOG_FILE
echo "Environment: $ENVIRONMENT" >> $LOG_FILE
echo "Security Level: MAXIMUM" >> $LOG_FILE
echo "Features Applied:" >> $LOG_FILE
echo "- Maximum SSH hardening with restricted algorithms" >> $LOG_FILE
echo "- Advanced firewall with connection logging" >> $LOG_FILE
echo "- Real-time intrusion detection system" >> $LOG_FILE
echo "- Comprehensive audit logging and session recording" >> $LOG_FILE
echo "- SELinux maximum enforcement" >> $LOG_FILE
echo "- Aggressive Fail2Ban policies" >> $LOG_FILE
echo "- System hardening with restricted user environments" >> $LOG_FILE
echo "- Automated security monitoring and alerting" >> $LOG_FILE
echo "- File system protection with immutable attributes" >> $LOG_FILE
echo "- Automated security updates" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# Restart all security services
systemctl restart sshd
systemctl restart firewalld
systemctl restart fail2ban
systemctl restart auditd

echo "[SUCCESS] Bastion host maximum security hardening completed!"
echo "[INFO] Security status: /usr/local/bin/bastion-status.sh"
echo "[INFO] This bastion host is now secured with maximum protection."
echo "[INFO] All access is monitored, logged, and recorded."

exit 0