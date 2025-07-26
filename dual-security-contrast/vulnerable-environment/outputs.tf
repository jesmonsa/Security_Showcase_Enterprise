# ========================================
# AMBIENTE VULNERABLE - OUTPUTS
# ========================================

# ========================================
# ARCHITECTURE SUMMARY
# ========================================
output "vulnerable_architecture_summary" {
  description = "Summary of the vulnerable environment architecture"
  value = {
    project_name = local.project_name
    environment  = local.environment
    region      = var.region
    deployment_time = timestamp()
    
    warning = "🚨 THIS ENVIRONMENT IS DELIBERATELY INSECURE FOR DEMONSTRATION 🚨"
    purpose = "Security vulnerability demonstration and training"
    production_use = "NEVER - For demo purposes only"
  }
}

# ========================================
# ACCESS INFORMATION
# ========================================
output "access_information" {
  description = "Access information for vulnerable environment"
  value = {
    web_applications = module.vulnerable_application.application_urls
    load_balancer_ip = oci_load_balancer_load_balancer.vulnerable_lb.ip_addresses
    
    ssh_access = {
      commands = module.unprotected_compute.ssh_connection_commands
      private_key_location = module.unprotected_compute.ssh_private_key_path
      warning = "SSH access uses weak 2048-bit RSA key stored locally unencrypted"
    }
    
    database_access = {
      connection_details = module.vulnerable_database.insecure_connection_details
      warning = "Database is exposed on public subnet with weak password"
    }
  }
  sensitive = true
}

# ========================================
# VULNERABILITY TEST ENDPOINTS
# ========================================
output "vulnerability_test_endpoints" {
  description = "Endpoints for testing specific vulnerabilities"
  value = {
    sql_injection = module.vulnerable_application.vulnerable_endpoints.sql_injection
    xss = module.vulnerable_application.vulnerable_endpoints.xss
    path_traversal = module.vulnerable_application.vulnerable_endpoints.path_traversal
    information_disclosure = module.vulnerable_application.vulnerable_endpoints.information_disclosure
    
    health_checks = module.vulnerable_application.health_check_urls
    
    database_direct_access = {
      host = "Port 1521 accessible from internet"
      test_command = length(module.unprotected_compute.instance_public_ips) > 0 ? "telnet ${module.unprotected_compute.instance_public_ips[0]} 1521" : "N/A"
    }
  }
}

# ========================================
# COMPREHENSIVE VULNERABILITY SUMMARY
# ========================================
output "comprehensive_vulnerability_summary" {
  description = "Complete vulnerability assessment of all layers"
  value = {
    overall_risk_score = "9.5/10 - CRITICAL"
    
    layer_vulnerabilities = {
      iam = module.insecure_iam.iam_vulnerabilities_summary
      network = module.exposed_network.network_vulnerabilities_summary
      compute = module.unprotected_compute.compute_vulnerabilities_summary
      database = module.vulnerable_database.database_vulnerabilities_summary
      application = module.vulnerable_application.application_vulnerabilities_summary
      monitoring = module.monitoring_disabled.monitoring_vulnerabilities_summary
    }
    
    attack_vectors_summary = {
      network_attacks = "HIGH - All ports exposed, no WAF protection"
      application_attacks = "CRITICAL - OWASP Top 10 vulnerabilities active"
      database_attacks = "CRITICAL - Direct access, no Database Firewall"
      privilege_escalation = "HIGH - Excessive IAM permissions"
      data_exfiltration = "CRITICAL - No monitoring or DLP"
      persistence = "HIGH - No integrity monitoring"
    }
    
    compliance_status = {
      pci_dss = "NON_COMPLIANT - Fails all major requirements"
      sox = "NON_COMPLIANT - Inadequate controls and auditing"
      gdpr = "NON_COMPLIANT - No data protection measures"
      hipaa = "NON_COMPLIANT - PHI protection absent"
      iso27001 = "NON_COMPLIANT - No security management system"
      nist_csf = "NON_COMPLIANT - Fails identify, protect, detect, respond, recover"
    }
    
    business_impact_estimate = {
      data_breach_cost = "$4.45M USD average"
      regulatory_fines = "$10M+ USD potential"
      reputation_damage = "65% customer loss average"
      operational_downtime = "72 hours average"
      recovery_time = "280 days average"
      legal_costs = "$2M+ USD typical"
    }
  }
}

# ========================================
# ORACLE 23ai DATABASE FIREWALL STATUS
# ========================================
output "oracle_23ai_database_firewall_status" {
  description = "Oracle 23ai Database Firewall status (DISABLED for vulnerability demo)"
  value = {
    database_version = "Oracle 23ai"
    database_firewall = "DISABLED - No SQL injection protection at DB level"
    data_safe = "DISABLED - No advanced security assessment"
    
    vulnerability_exposure = {
      sql_injection_at_db = "VULNERABLE - Queries reach database unfiltered"
      privilege_escalation = "POSSIBLE - No query pattern analysis"
      data_exfiltration = "UNDETECTED - No abnormal query detection"
      insider_threats = "UNMONITORED - No user behavior analysis"
    }
    
    comparison_note = "This demonstrates Oracle 23ai WITHOUT Database Firewall - compare with secure environment that has Database Firewall ENABLED"
    
    missing_protections = [
      "Real-time SQL statement analysis",
      "Threat pattern detection",
      "Abnormal query identification", 
      "User behavior monitoring",
      "Automatic threat blocking",
      "Advanced audit capabilities"
    ]
  }
}

# ========================================
# DEMO EXECUTION COMMANDS
# ========================================
output "demo_execution_commands" {
  description = "Ready-to-use commands for vulnerability demonstration"
  value = {
    quick_vulnerability_tests = length(module.vulnerable_application.application_urls) > 0 ? {
      sql_injection = "curl \"${module.vulnerable_application.application_urls[0]}/?demo=sql&user_id=1'\""
      xss = "curl \"${module.vulnerable_application.application_urls[0]}/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E\""
      path_traversal = "curl \"${module.vulnerable_application.application_urls[0]}/?demo=path&file=../../etc/passwd\""
      information_disclosure = "curl \"${module.vulnerable_application.application_urls[0]}/health.php\""
    } : {}
    
    network_tests = length(module.unprotected_compute.instance_public_ips) > 0 ? {
      port_scan = "nmap -p 22,80,443,1521 ${module.unprotected_compute.instance_public_ips[0]}"
      database_port_test = "telnet ${module.unprotected_compute.instance_public_ips[0]} 1521"
      ssh_brute_force_test = "hydra -l opc -P /usr/share/wordlists/rockyou.txt ssh://${module.unprotected_compute.instance_public_ips[0]}"
    } : {}
    
    security_header_tests = length(module.vulnerable_application.application_urls) > 0 ? {
      missing_headers_check = "curl -I \"${module.vulnerable_application.application_urls[0]}\""
      ssl_test = "sslscan ${split("//", module.vulnerable_application.application_urls[0])[1]}"
    } : {}
    
    comparison_script = "./comparison-scripts/vulnerability-tests/test-all-vulnerabilities.sh vulnerable-env-info.txt secure-env-info.txt"
  }
}

# ========================================
# DEPLOYMENT INFORMATION FOR DEMO
# ========================================
output "deployment_info_for_demo" {
  description = "Deployment information formatted for demo scripts"
  value = {
    environment_type = "VULNERABLE"
    web_application_urls = module.vulnerable_application.application_urls
    load_balancer_ips = oci_load_balancer_load_balancer.vulnerable_lb.ip_addresses
    compute_instance_ips = module.unprotected_compute.instance_public_ips
    
    database_info = {
      version = "Oracle 23ai"
      database_firewall = "DISABLED"
      data_safe = "DISABLED"
      public_access = "ENABLED"
      connection_string = module.vulnerable_database.connection_string
    }
    
    security_status = {
      waf = "DISABLED"
      cloud_guard = "DISABLED"
      vulnerability_scanning = "DISABLED"
      encryption = "DEFAULT_ONLY"
      monitoring = "MINIMAL"
    }
    
    test_credentials = {
      ssh_user = "opc"
      ssh_key_path = module.unprotected_compute.ssh_private_key_path
      database_user = "ADMIN"
      database_password = "Welcome123!"
      web_admin_user = "admin"
      web_admin_password = "Welcome123!"
    }
  }
  sensitive = true
}

# ========================================
# COST INFORMATION
# ========================================
output "estimated_monthly_cost" {
  description = "Estimated monthly cost for vulnerable environment"
  value = {
    compute_instances = "$${var.instance_count * 50}"
    database = "$200"
    load_balancer = "$20"
    network = "$10"
    storage = "$30"
    total_estimated = "$${var.instance_count * 50 + 260}"
    
    note = "Costs are estimates for demo environment. Actual costs may vary."
    warning = "This environment should be destroyed immediately after demo to avoid ongoing costs."
  }
}

# ========================================
# NEXT STEPS AND WARNINGS
# ========================================
output "important_next_steps" {
  description = "Critical next steps and warnings"
  value = {
    immediate_actions = [
      "🔥 DESTROY this environment immediately after demo",
      "🔥 NEVER use these configurations in production",
      "🔥 NEVER store real data in this vulnerable environment",
      "📊 Document all vulnerabilities found for comparison",
      "🛡️ Deploy secure environment for comparison demo"
    ]
    
    demo_preparation = [
      "Test all vulnerability endpoints before live demo",
      "Prepare screenshots as backup in case of connectivity issues",
      "Review talking points for each vulnerability type",
      "Prepare audience-specific messaging (executive vs technical)",
      "Have comparison metrics ready for business impact discussion"
    ]
    
    security_reminders = [
      "This environment violates ALL security best practices",
      "Every component is configured insecurely by design",
      "Real attackers would compromise this in minutes",
      "The contrast with secure environment will be dramatic",
      "This demonstrates exactly what NOT to do in production"
    ]
    
    business_case_talking_points = [
      "Cost of vulnerability: $4.45M average data breach",
      "Cost of protection: ~$3,360 annually", 
      "ROI: 132,340% return on security investment",
      "Detection time: 287 days without monitoring vs 3.2 seconds with protection"
    ]
  }
}

# ========================================
# FINAL WARNING MESSAGE
# ========================================
output "final_warning" {
  description = "Final security warning about this vulnerable environment"
  value = {
    message = "🚨🚨🚨 CRITICAL SECURITY WARNING 🚨🚨🚨"
    
    warnings = [
      "This environment is INTENTIONALLY VULNERABLE",
      "It contains EVERY major security anti-pattern",
      "It WILL be compromised if exposed to internet",
      "It must be DESTROYED after demonstration",
      "It should NEVER host real data or applications"
    ]
    
    legal_disclaimer = "This vulnerable environment is provided for educational and demonstration purposes only. Use at your own risk. Not suitable for production use."
    
    destruction_reminder = "🔥 Remember to run 'terraform destroy' after your demo! 🔥"
  }
}