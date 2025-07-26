# ========================================
# MÓDULO APLICACIÓN VULNERABLE - OUTPUTS
# ========================================

output "application_urls" {
  description = "URLs of vulnerable web applications"
  value = [
    for ip in var.instance_public_ips :
    "http://${ip}"  # INSEGURO: HTTP sin cifrado
  ]
}

output "health_check_urls" {
  description = "Health check URLs (expose system information)"
  value = [
    for ip in var.instance_public_ips :
    "http://${ip}/health.php"
  ]
}

output "vulnerable_endpoints" {
  description = "Endpoints vulnerable to specific attacks"
  value = {
    sql_injection = [
      for ip in var.instance_public_ips :
      "http://${ip}/?demo=sql&user_id=1'"
    ]
    xss = [
      for ip in var.instance_public_ips :
      "http://${ip}/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"
    ]
    path_traversal = [
      for ip in var.instance_public_ips :
      "http://${ip}/?demo=path&file=../../etc/passwd"
    ]
    information_disclosure = [
      for ip in var.instance_public_ips :
      "http://${ip}/server-info"
    ]
  }
}

output "hardcoded_secrets_locations" {
  description = "Locations where secrets are hardcoded (INSECURE)"
  value = {
    config_file = "/var/www/html/config.php"
    backup_file = "/var/www/html/.env.backup"
    log_file = "/var/log/vulnerable-app.log"
    source_code = "/var/www/html/index.php"
  }
}

# Resumen completo de vulnerabilidades de aplicación
output "application_vulnerabilities_summary" {
  description = "Complete summary of application vulnerabilities (OWASP Top 10)"
  value = {
    owasp_top_10_status = {
      A01_broken_access_control = {
        status = "VULNERABLE"
        description = "No access controls implemented"
        test_url = var.instance_public_ips[0] != "" ? "http://${var.instance_public_ips[0]}/admin" : "N/A"
        impact = "CRITICAL - Full system access possible"
      }
      
      A02_cryptographic_failures = {
        status = "VULNERABLE" 
        description = "Passwords and secrets stored in plaintext"
        evidence = "Hardcoded credentials in config.php"
        impact = "HIGH - All credentials compromised"
      }
      
      A03_injection = {
        status = "VULNERABLE"
        description = "SQL injection enabled without input sanitization"
        test_url = var.instance_public_ips[0] != "" ? "http://${var.instance_public_ips[0]}/?demo=sql&user_id=1'" : "N/A"
        impact = "CRITICAL - Full database access"
      }
      
      A04_insecure_design = {
        status = "VULNERABLE"
        description = "No security controls in application design"
        evidence = "No authentication, authorization, or input validation"
        impact = "CRITICAL - Fundamental security flaws"
      }
      
      A05_security_misconfiguration = {
        status = "VULNERABLE"
        description = "Apache configured with insecure settings"
        evidence = "Server info exposed, debug mode enabled"
        impact = "HIGH - Information disclosure"
      }
      
      A06_vulnerable_components = {
        status = "VULNERABLE"
        description = "Using potentially outdated PHP and Apache versions"
        evidence = "No automatic updates, version disclosure enabled"
        impact = "MEDIUM - Known vulnerabilities may exist"
      }
      
      A07_identification_failures = {
        status = "VULNERABLE"
        description = "No authentication or session management"
        evidence = "No login system implemented"
        impact = "CRITICAL - No user identity verification"
      }
      
      A08_software_integrity_failures = {
        status = "VULNERABLE"
        description = "No integrity checks on application code"
        evidence = "Files can be modified without detection"
        impact = "HIGH - Code tampering possible"
      }
      
      A09_logging_failures = {
        status = "VULNERABLE"
        description = "Inadequate logging and monitoring"
        evidence = "Basic logging only, no security event detection"
        impact = "HIGH - Attacks go undetected"
      }
      
      A10_server_side_request_forgery = {
        status = "VULNERABLE"
        description = "No SSRF protection in place"
        evidence = "URL parameters not validated"
        impact = "MEDIUM - Internal systems accessible"
      }
    }
    
    additional_vulnerabilities = {
      information_disclosure = {
        status = "ACTIVE"
        endpoints = ["/server-info", "/health.php", "/.env.backup"]
        sensitive_data_exposed = [
          "Server configuration",
          "PHP configuration", 
          "Database credentials",
          "Environment variables",
          "System information"
        ]
      }
      
      file_upload_vulnerabilities = {
        status = "ACTIVE"
        upload_directory = "/var/www/html/uploads"
        permissions = "777 - World writable"
        file_type_restrictions = "NONE"
        size_restrictions = "NONE"  
      }
      
      directory_listing = {
        status = "ENABLED"
        exposed_directories = ["/uploads", "/config"]
        sensitive_files_exposed = true
      }
      
      weak_ssl_configuration = {
        status = "HTTP_ONLY" 
        https_enforcement = "DISABLED"
        weak_ciphers = "ALLOWED"
        certificate_validation = "DISABLED"
      }
    }
    
    exploitation_difficulty = "TRIVIAL - No protection mechanisms"
    automated_scanning_detection = "100% - All vulnerabilities easily detectable"
    manual_testing_required = "NO - Obvious vulnerabilities"
    
    business_impact = {
      confidentiality = "COMPLETE LOSS - All data accessible"
      integrity = "COMPLETE LOSS - Data can be modified"
      availability = "HIGH RISK - System can be compromised"
      regulatory_compliance = "NON_COMPLIANT - Fails all security requirements"
    }
    
    remediation_effort = {
      immediate_fixes = [
        "Implement input validation and parameterized queries",
        "Remove hardcoded credentials", 
        "Enable HTTPS with proper SSL configuration",
        "Implement proper authentication and authorization",
        "Configure secure Apache settings"
      ]
      
      architectural_changes = [
        "Implement Web Application Firewall (WAF)",
        "Add comprehensive logging and monitoring",
        "Implement proper session management",
        "Add file upload restrictions",
        "Implement Content Security Policy (CSP)"
      ]
      
      estimated_time = "2-4 weeks for complete remediation"
      estimated_cost = "$50,000 - $100,000 for professional security remediation"
    }
    
    risk_rating = "CRITICAL (10/10)"
    cvss_score = "10.0 - Maximum severity"
  }
}

# Test commands para verificar vulnerabilidades
output "vulnerability_test_commands" {
  description = "Commands to test application vulnerabilities"
  value = var.instance_public_ips[0] != "" ? {
    sql_injection = "curl \"http://${var.instance_public_ips[0]}/?demo=sql&user_id=1'\""
    xss = "curl \"http://${var.instance_public_ips[0]}/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E\""
    path_traversal = "curl \"http://${var.instance_public_ips[0]}/?demo=path&file=../../etc/passwd\""
    information_disclosure = "curl \"http://${var.instance_public_ips[0]}/server-info\""
    health_check = "curl \"http://${var.instance_public_ips[0]}/health.php\""
    config_exposure = "curl \"http://${var.instance_public_ips[0]}/config.php\""
    backup_exposure = "curl \"http://${var.instance_public_ips[0]}/.env.backup\""
  } : {}
}

output "security_headers_test" {
  description = "Commands to test missing security headers"
  value = var.instance_public_ips[0] != "" ? {
    command = "curl -I \"http://${var.instance_public_ips[0]}\""
    expected_missing_headers = [
      "X-Frame-Options",
      "X-Content-Type-Options", 
      "X-XSS-Protection",
      "Content-Security-Policy",
      "Strict-Transport-Security"
    ]
    expected_insecure_headers = [
      "Server: Apache/2.4.6 (CentOS) - Vulnerable Demo"
    ]
  } : {}
}