# ========================================
# MÓDULO NETWORK EXPUESTA - OUTPUTS
# ========================================

output "vcn_id" {
  description = "OCID of the vulnerable VCN"
  value       = oci_core_vcn.vulnerable_vcn.id
}

output "vcn_cidr_block" {
  description = "CIDR block of the vulnerable VCN"
  value       = oci_core_vcn.vulnerable_vcn.cidr_block
}

output "public_subnet_id" {
  description = "OCID of the public web subnet (INSECURE)"
  value       = oci_core_subnet.vulnerable_public_web.id
}

output "database_subnet_id" {
  description = "OCID of the public database subnet (CRITICAL RISK)"
  value       = oci_core_subnet.vulnerable_public_database.id
}

output "internet_gateway_id" {
  description = "OCID of the internet gateway"
  value       = oci_core_internet_gateway.vulnerable_igw.id
}

output "vulnerable_security_list_ids" {
  description = "List of insecure security list IDs"
  value = [
    oci_core_security_list.vulnerable_allow_all.id,
    oci_core_security_list.vulnerable_database_open.id
  ]
}

output "vulnerable_nsg_id" {
  description = "OCID of the vulnerable NSG"
  value       = oci_core_network_security_group.vulnerable_allow_all_nsg.id
}

# Resumen de vulnerabilidades de red
output "network_vulnerabilities_summary" {
  description = "Summary of network vulnerabilities"
  value = {
    vpc_security = {
      segmentation = "NONE - All resources in public subnets"
      database_exposure = "CRITICAL - Database in public subnet"
      access_control = "NONE - 0.0.0.0/0 allowed everywhere"
    }
    
    security_lists = {
      ingress_rules = "PERMISSIVE - All ports open to internet"
      egress_rules = "UNRESTRICTED - All outbound allowed"
      database_ports = "EXPOSED - Oracle 1521 open to internet"
    }
    
    network_security_groups = {
      configuration = "INSECURE - Allow all traffic"
      granularity = "NONE - No specific rules"
    }
    
    traffic_monitoring = {
      flow_logs = "DISABLED - No network traffic visibility"
      waf_protection = "NONE - No web application firewall"
      ddos_protection = "BASIC - No advanced DDoS protection"
    }
    
    access_methods = {
      bastion_service = "NOT_DEPLOYED - Direct SSH access"
      vpn_gateway = "NOT_CONFIGURED - No secure remote access"
      private_connectivity = "NONE - All public access"
    }
    
    encryption = {
      traffic_encryption = "OPTIONAL - HTTP allowed"
      ssl_termination = "NOT_ENFORCED - Weak ciphers allowed"
    }
    
    compliance_status = {
      pci_dss = "NON_COMPLIANT - Network not segmented"
      sox = "NON_COMPLIANT - No access controls"
      iso27001 = "NON_COMPLIANT - No security controls"
      nist = "NON_COMPLIANT - Fails all categories"
    }
    
    risk_assessment = {
      overall_risk = "CRITICAL"
      attack_surface = "MAXIMUM - All services exposed"
      lateral_movement = "UNRESTRICTED - No segmentation"
      data_exfiltration = "POSSIBLE - No egress controls"
    }
    
    remediation_priority = "IMMEDIATE"
  }
}