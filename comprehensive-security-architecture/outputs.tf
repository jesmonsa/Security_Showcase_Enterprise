# ========================================
# COMPREHENSIVE SECURITY ARCHITECTURE - OUTPUTS
# ========================================

# ========================================
# ARCHITECTURE SUMMARY
# ========================================
output "architecture_summary" {
  description = "Summary of the deployed security architecture"
  value = {
    project_name = local.project_name
    environment  = local.environment
    region      = var.region
    deployment_time = timestamp()
  }
}

# ========================================
# IAM OUTPUTS
# ========================================
output "iam_structure" {
  description = "IAM compartments and groups structure"
  value = {
    security_compartment_id   = module.iam.security_compartment_ocid
    security_compartment_name = module.iam.security_compartment_name
    user_groups              = module.iam.user_groups
    policies                 = module.iam.policies
  }
}

# ========================================
# NETWORK OUTPUTS
# ========================================
output "network_infrastructure" {
  description = "Network infrastructure details"
  value = {
    vcn_id              = module.network.vcn_id
    vcn_cidr_block      = module.network.vcn_cidr_block
    public_subnet_ids   = module.network.public_subnet_ids
    private_subnet_ids  = module.network.private_subnet_ids
    database_subnet_id  = module.network.database_subnet_id
    security_group_ids  = module.network.security_group_ids
    internet_gateway_id = module.network.internet_gateway_id
    nat_gateway_id      = module.network.nat_gateway_id
    service_gateway_id  = module.network.service_gateway_id
  }
}

# ========================================
# VAULT/KMS OUTPUTS
# ========================================
output "vault_kms" {
  description = "Vault and Key Management Service details"
  value = {
    vault_id        = module.vault_kms.vault_id
    vault_endpoint  = module.vault_kms.vault_endpoint
    master_key_id   = module.vault_kms.master_key_id
    master_key_state = module.vault_kms.master_key_state
  }
  sensitive = true
}

# ========================================
# COMPUTE OUTPUTS
# ========================================
output "compute_instances" {
  description = "Compute instances information"
  value = {
    instance_ids     = module.compute.instance_ids
    instance_names   = module.compute.instance_names
    private_ips      = module.compute.private_ips
    public_ips       = module.compute.public_ips
    security_status  = module.compute.security_hardening_status
  }
}

# ========================================
# DATABASE OUTPUTS
# ========================================
output "database_details" {
  description = "Database configuration and security status"
  value = var.enable_database ? {
    database_id           = module.database[0].database_id
    database_name         = module.database[0].database_name
    connection_urls       = module.database[0].connection_urls
    data_safe_status      = module.database[0].data_safe_status
    encryption_status     = module.database[0].encryption_status
    backup_configuration  = module.database[0].backup_configuration
  } : null
}

# ========================================
# WAF OUTPUTS
# ========================================
output "waf_configuration" {
  description = "Web Application Firewall configuration"
  value = var.enable_waf ? {
    waf_id            = module.waf[0].waf_id
    waf_domain        = module.waf[0].waf_domain
    waf_cname         = module.waf[0].waf_cname
    protection_rules  = module.waf[0].protection_rules
    policy_summary    = module.waf[0].policy_summary
  } : null
}

# ========================================
# MONITORING OUTPUTS
# ========================================
output "security_monitoring" {
  description = "Security monitoring and Cloud Guard status"
  value = {
    cloud_guard_enabled    = var.enable_cloud_guard
    cloud_guard_target_id  = var.enable_cloud_guard ? module.monitoring.cloud_guard_target_id : null
    audit_logging_enabled  = var.enable_audit_logging
    log_groups            = module.monitoring.log_groups
    notification_topics   = module.monitoring.notification_topics
  }
}

# ========================================
# SECURITY ZONES OUTPUTS
# ========================================
output "security_zones" {
  description = "Security Zones configuration"
  value = var.enable_security_zones ? {
    security_zone_id     = module.security_zones[0].security_zone_id
    security_zone_name   = module.security_zones[0].security_zone_name
    security_zone_status = module.security_zones[0].security_zone_status
    recipe_id           = module.security_zones[0].recipe_id
  } : null
}

# ========================================
# SECURITY POSTURE SUMMARY
# ========================================
output "security_posture_summary" {
  description = "Overall security posture and compliance status"
  value = {
    encryption_at_rest    = "Enabled with customer-managed keys"
    encryption_in_transit = "Enabled with TLS 1.2+"
    network_segmentation  = "Implemented with NSGs and Security Lists"
    access_control        = "IAM policies with least privilege"
    monitoring_logging    = var.enable_cloud_guard ? "Active with Cloud Guard" : "Basic logging enabled"
    vulnerability_mgmt    = var.enable_vulnerability_scanning ? "Active scanning" : "Manual assessment required"
    backup_strategy       = var.enable_database ? "Automated with encryption" : "Not applicable"
    compliance_frameworks = [
      "Oracle Security Best Practices",
      "CIS Controls",
      "NIST Cybersecurity Framework"
    ]
  }
}

# ========================================
# QUICK ACCESS URLS
# ========================================
output "quick_access_info" {
  description = "Quick access information for demo and management"
  value = {
    oci_console_url = "https://cloud.oracle.com"
    cloud_guard_url = "https://cloud.oracle.com/security/cloud-guard"
    vault_url       = "https://cloud.oracle.com/security/kms"
    
    # Connection commands
    bastion_ssh_command = var.enable_bastion_service ? module.compute.bastion_ssh_command : "Bastion service not enabled"
    
    # WAF access
    waf_protected_url = var.enable_waf ? "https://${module.waf[0].waf_domain}" : "WAF not enabled"
    
    # Database connection
    database_connection = var.enable_database ? module.database[0].connection_string : "Database not enabled"
  }
  sensitive = true
}

# ========================================
# COST ESTIMATION
# ========================================
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (USD)"
  value = {
    compute_instances = "$${var.instance_count * 50}"  # Approximate cost per E4.Flex instance
    autonomous_db     = var.enable_database ? "$200" : "$0"
    vault_kms        = "$10"
    waf              = var.enable_waf ? "$50" : "$0"
    cloud_guard      = "$25"
    network_components = "$20"
    storage_backup   = "$30"
    total_estimated  = "$${var.instance_count * 50 + (var.enable_database ? 200 : 0) + (var.enable_waf ? 50 : 0) + 85}"
    
    note = "Costs are estimates and may vary based on actual usage, region, and current OCI pricing"
  }
}

# ========================================
# NEXT STEPS RECOMMENDATIONS
# ========================================
output "next_steps" {
  description = "Recommended next steps after deployment"
  value = [
    "1. Review IAM policies and adjust permissions as needed",
    "2. Configure Cloud Guard detector recipes for your specific requirements", 
    "3. Set up notification channels for security alerts",
    "4. Implement application-specific WAF rules",
    "5. Configure Data Safe assessments and monitoring",
    "6. Review and customize security zone policies",
    "7. Set up regular backup and disaster recovery procedures",
    "8. Conduct security assessment and penetration testing",
    "9. Train team members on OCI security best practices",
    "10. Establish incident response procedures"
  ]
}