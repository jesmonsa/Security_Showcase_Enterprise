# ========================================
# MÓDULO DATABASE VULNERABLE - OUTPUTS
# ========================================

output "database_id" {
  description = "OCID of the vulnerable Oracle 23ai database"
  value       = oci_database_autonomous_database.vulnerable_adb_23ai.id
}

output "database_name" {
  description = "Name of the vulnerable database"
  value       = oci_database_autonomous_database.vulnerable_adb_23ai.db_name
}

output "database_display_name" {
  description = "Display name of the vulnerable database"
  value       = oci_database_autonomous_database.vulnerable_adb_23ai.display_name
}

output "connection_string" {
  description = "Connection string for the vulnerable database (INSECURE EXPOSURE)"
  value       = length(oci_database_autonomous_database.vulnerable_adb_23ai.connection_urls) > 0 ? oci_database_autonomous_database.vulnerable_adb_23ai.connection_urls[0].profiles[0].host_format : "Connection URLs not available yet"
  sensitive   = true
}

output "connection_urls" {
  description = "All connection URLs for the database"
  value       = oci_database_autonomous_database.vulnerable_adb_23ai.connection_urls
  sensitive   = true
}

output "service_console_url" {
  description = "Service console URL"
  value       = oci_database_autonomous_database.vulnerable_adb_23ai.service_console_url
}

output "database_state" {
  description = "Current state of the database"
  value       = oci_database_autonomous_database.vulnerable_adb_23ai.state
}

# Información crítica de vulnerabilidades
output "database_vulnerabilities_summary" {
  description = "Summary of database vulnerabilities (Oracle 23ai without protections)"
  value = {
    database_version = "Oracle 23ai"
    
    security_features_disabled = {
      database_firewall = "DISABLED - No SQL injection protection at DB level"
      data_safe = "DISABLED - No vulnerability assessment, data discovery, or advanced auditing"
      transparent_data_encryption = "BASIC_ONLY - No customer-managed keys"
      advanced_security = "DISABLED - No advanced threat protection"
    }
    
    network_exposure = {
      subnet_type = "PUBLIC - Database accessible from internet"
      ip_whitelist = "NONE - Any IP can attempt connection"
      port_exposure = "1521 OPEN - Oracle port exposed to internet"
      ssl_enforcement = "OPTIONAL - HTTP connections may be allowed"
    }
    
    access_control = {
      admin_password = var.use_weak_passwords ? "WEAK - Predictable password" : "CONFIGURED"
      mfa_enabled = "NO - No multi-factor authentication"
      privilege_separation = "MINIMAL - Limited user roles"
      session_management = "BASIC - No advanced session controls"
    }
    
    backup_security = {
      encryption = "DEFAULT_ONLY - No additional encryption layers"
      cross_region = "DISABLED - No geographic redundancy"
      retention_policy = "BASIC - Standard retention only"
      access_control = "MINIMAL - Basic backup access controls"
    }
    
    monitoring_auditing = {
      audit_logging = "BASIC - Minimal audit trail"
      real_time_monitoring = "DISABLED - No real-time threat detection"
      cloud_guard_integration = "NONE - No security monitoring"
      siem_integration = "NONE - No SIEM forwarding"
    }
    
    compliance_status = {
      pci_dss = "NON_COMPLIANT - Database not properly isolated"
      sox = "NON_COMPLIANT - Insufficient access controls and auditing"
      gdpr = "NON_COMPLIANT - Data protection inadequate"
      hipaa = "NON_COMPLIANT - PHI protection insufficient"
      iso27001 = "NON_COMPLIANT - Security controls missing"
    }
    
    vulnerability_assessment = {
      sql_injection = "VULNERABLE - No database firewall protection"
      privilege_escalation = "POSSIBLE - Weak access controls"
      data_exfiltration = "HIGH_RISK - Minimal monitoring"
      unauthorized_access = "HIGH_RISK - Public exposure"
      data_tampering = "POSSIBLE - Limited integrity controls"
    }
    
    oracle_23ai_features_not_used = {
      database_firewall = "Available in 23ai but DISABLED"
      advanced_analytics = "Available but not secured"
      machine_learning = "Available but no security guardrails"
      json_enhancements = "Available but may introduce attack vectors"
      graph_analytics = "Available but no access controls"
    }
    
    attack_vectors = {
      direct_database_attacks = "HIGH - Public port 1521 exposure"
      sql_injection = "HIGH - No database firewall"
      credential_attacks = "MEDIUM - Weak passwords"
      man_in_the_middle = "MEDIUM - Optional SSL enforcement"
      data_extraction = "HIGH - Minimal monitoring"
      insider_threats = "HIGH - Limited access logging"
    }
    
    remediation_priority = "CRITICAL"
    estimated_risk_score = "9.5/10"
    
    business_impact = {
      data_breach_cost = "Estimated $4.45M+ per incident"
      regulatory_fines = "Up to $20M+ depending on regulations"
      reputation_damage = "Severe - 65% customer loss average"
      operational_downtime = "High - No HA configuration"
    }
  }
}

# Para aplicaciones que necesiten conectarse (configuración insegura)
output "insecure_connection_details" {
  description = "Insecure connection details for vulnerable applications"
  value = {
    warning = "THESE CONNECTION DETAILS ARE DELIBERATELY INSECURE FOR DEMO"
    database_host = length(oci_database_autonomous_database.vulnerable_adb_23ai.connection_urls) > 0 ? oci_database_autonomous_database.vulnerable_adb_23ai.connection_urls[0].profiles[0].host_format : "Not available"
    database_name = oci_database_autonomous_database.vulnerable_adb_23ai.db_name
    admin_user = "ADMIN"
    admin_password_hint = var.use_weak_passwords ? "Uses weak predictable password" : "Password configured"
    port = 1521
    ssl_required = false  # Inseguro - SSL no es obligatorio
    public_access = var.allow_public_access
  }
  sensitive = true
}

# Comandos de prueba de vulnerabilidad
output "vulnerability_test_commands" {
  description = "Commands to test database vulnerabilities (for authorized security testing only)"
  value = {
    warning = "USE ONLY FOR AUTHORIZED SECURITY TESTING"
    
    network_tests = [
      "nmap -p 1521 <DATABASE_IP>  # Test if Oracle port is open",
      "telnet <DATABASE_IP> 1521   # Test direct database connectivity"
    ]
    
    connection_tests = [
      "sqlplus admin/Welcome123!@<CONNECTION_STRING>  # Test weak password",
      "tnsping <TNS_NAME>  # Test TNS connectivity"
    ]
    
    sql_injection_tests = [
      "' OR 1=1 --  # Basic SQL injection test",
      "'; DROP TABLE test; --  # Destructive SQL injection test"
    ]
    
    note = "These tests should ONLY be run against the vulnerable environment for demonstration purposes"
  }
}