# ========================================
# AMBIENTE SEGURO - VARIABLES
# Configuración con mejores prácticas de seguridad
# ========================================

# ========================================
# OCI AUTHENTICATION
# ========================================
variable "tenancy_ocid" {
  type        = string
  description = "OCID of the tenancy"
}

variable "user_ocid" {
  type        = string
  description = "OCID of the user"
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint of the public key"
}

variable "private_key_path" {
  type        = string
  description = "Path to the private key file"
}

variable "region" {
  type        = string
  description = "OCI region for resource deployment"
  default     = "us-ashburn-1"
  
  validation {
    condition = contains([
      "us-ashburn-1", "us-phoenix-1", "ca-toronto-1", "ca-montreal-1",
      "eu-amsterdam-1", "eu-frankfurt-1", "eu-zurich-1", "uk-london-1",
      "ap-tokyo-1", "ap-osaka-1", "ap-sydney-1", "ap-melbourne-1",
      "sa-saopaulo-1", "me-jeddah-1", "ap-hyderabad-1", "ap-mumbai-1"
    ], var.region)
    error_message = "Invalid region specified. Please use a valid OCI region."
  }
}

variable "home_region" {
  type        = string
  description = "Home region for identity operations"
  default     = "us-ashburn-1"
}

# ========================================
# ENVIRONMENT CONFIGURATION
# ========================================
variable "environment" {
  type        = string
  description = "Environment name for secure demo"
  default     = "secure"
  
  validation {
    condition     = contains(["secure", "production", "staging"], var.environment)
    error_message = "Environment must be secure, production, or staging for this secure architecture."
  }
}

# ========================================
# NETWORK CONFIGURATION - SECURE
# ========================================
variable "vcn_cidr_block" {
  type        = string
  description = "CIDR block for the secure VCN"
  default     = "10.60.0.0/16"  # Diferente del vulnerable para evitar conflictos
  
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vcn_cidr_block))
    error_message = "VCN CIDR block must be a valid CIDR notation."
  }
}

# ========================================
# COMPUTE CONFIGURATION - HARDENED
# ========================================
variable "instance_shape" {
  type        = string
  description = "Shape for secure compute instances"
  default     = "VM.Standard.E4.Flex"
  
  validation {
    condition = contains([
      "VM.Standard.E3.Flex", "VM.Standard.E4.Flex", 
      "VM.Standard.A1.Flex", "VM.Optimized3.Flex"
    ], var.instance_shape)
    error_message = "Instance shape must be a supported flexible shape."
  }
}

variable "instance_count" {
  type        = number
  description = "Number of secure compute instances to create"
  default     = 2
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

# ========================================
# DATABASE CONFIGURATION - ORACLE 23ai SECURED
# ========================================
variable "db_admin_password" {
  type        = string
  description = "Strong database admin password (minimum 12 chars, mixed case, numbers, symbols)"
  default     = ""  # Será generado automáticamente si está vacío
  sensitive   = true
  
  validation {
    condition = var.db_admin_password == "" || (
      length(var.db_admin_password) >= 12 &&
      can(regex("[A-Z]", var.db_admin_password)) &&
      can(regex("[a-z]", var.db_admin_password)) &&
      can(regex("[0-9]", var.db_admin_password)) &&
      can(regex("[^A-Za-z0-9]", var.db_admin_password))
    )
    error_message = "Database password must be at least 12 characters with uppercase, lowercase, numbers, and symbols, or leave empty for auto-generation."
  }
}

variable "enable_database_firewall" {
  type        = bool
  description = "Enable Oracle 23ai Database Firewall (RECOMMENDED)"
  default     = true
}

variable "enable_data_safe" {
  type        = bool
  description = "Enable Oracle Data Safe for comprehensive database security"
  default     = true
}

# ========================================
# IAM SECURITY CONFIGURATION
# ========================================
variable "enforce_mfa_requirements" {
  type        = bool
  description = "Enforce MFA for all administrative users"
  default     = true
}

variable "enable_identity_domains" {
  type        = bool
  description = "Enable Identity Domains for advanced identity management"
  default     = true
}

# ========================================
# NETWORK SECURITY CONFIGURATION
# ========================================
variable "enable_waf" {
  type        = bool
  description = "Enable Web Application Firewall"
  default     = true
}

variable "enable_ddos_protection" {
  type        = bool
  description = "Enable DDoS protection"
  default     = true
}

variable "enable_flow_logs" {
  type        = bool
  description = "Enable VCN Flow Logs for network monitoring"
  default     = true
}

variable "enable_bastion_service" {
  type        = bool
  description = "Enable Oracle Bastion Service for secure access"
  default     = true
}

variable "waf_domain_names" {
  type        = list(string)
  description = "Domain names to protect with WAF"
  default     = ["secure-demo.oracledemo.com"]
}

variable "enable_geo_blocking" {
  type        = bool
  description = "Enable geographic blocking in WAF"
  default     = false  # Puede interferir con demos globales
}

# ========================================
# VAULT/KMS CONFIGURATION
# ========================================
variable "enable_hsm" {
  type        = bool
  description = "Enable Hardware Security Module (HSM) for highest security"
  default     = false  # HSM es costoso, usar solo si se requiere máxima seguridad
}

# ========================================
# MONITORING CONFIGURATION
# ========================================
variable "enable_cloud_guard" {
  type        = bool
  description = "Enable Oracle Cloud Guard"
  default     = true
}

variable "log_retention_duration" {
  type        = number
  description = "Log retention duration in days"
  default     = 365  # 1 año para compliance
  
  validation {
    condition     = var.log_retention_duration >= 90 && var.log_retention_duration <= 2555  # 7 años máximo
    error_message = "Log retention must be between 90 days and 7 years (2555 days)."
  }
}

variable "notification_email" {
  type        = string
  description = "Email for security notifications"
  default     = ""
  
  validation {
    condition     = var.notification_email == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Notification email must be a valid email address or empty."
  }
}

variable "enable_siem_integration" {
  type        = bool
  description = "Enable SIEM integration for external security monitoring"
  default     = false  # Requiere configuración externa
}

# ========================================
# ADVANCED SECURITY FEATURES
# ========================================
variable "enable_intrusion_detection" {
  type        = bool
  description = "Enable intrusion detection systems"
  default     = true
}

variable "enable_vulnerability_scanning" {
  type        = bool
  description = "Enable automated vulnerability scanning"
  default     = true
}

# ========================================
# COMPLIANCE CONFIGURATION
# ========================================
variable "compliance_frameworks" {
  type        = list(string)
  description = "Compliance frameworks to adhere to"
  default     = ["PCI_DSS", "SOX", "GDPR", "ISO27001"]
  
  validation {
    condition = alltrue([
      for framework in var.compliance_frameworks :
      contains(["PCI_DSS", "SOX", "GDPR", "HIPAA", "ISO27001", "NIST", "CIS"], framework)
    ])
    error_message = "Supported compliance frameworks: PCI_DSS, SOX, GDPR, HIPAA, ISO27001, NIST, CIS."
  }
}

# ========================================
# COST OPTIMIZATION
# ========================================
variable "enable_cost_optimization" {
  type        = bool
  description = "Enable cost optimization features (may reduce some security features)"
  default     = false  # Seguridad sobre costo por defecto
}

# ========================================
# DEMO CONFIGURATION
# ========================================
variable "demo_mode" {
  type        = bool
  description = "Enable demo mode with additional logging and documentation"
  default     = true
}

variable "enable_comparison_endpoints" {
  type        = bool
  description = "Enable endpoints for comparison with vulnerable environment"  
  default     = true
}

# ========================================
# BACKUP AND DISASTER RECOVERY
# ========================================
variable "enable_cross_region_backup" {
  type        = bool
  description = "Enable cross-region backup for disaster recovery"
  default     = true
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention in days"
  default     = 35  # 5 semanas
  
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 365
    error_message = "Backup retention must be between 7 and 365 days."
  }
}

# ========================================
# SECURITY ACKNOWLEDGMENT
# ========================================
variable "acknowledge_security_deployment" {
  type        = bool
  description = "Acknowledge that this deployment implements comprehensive security controls"
  default     = false
  
  validation {
    condition     = var.acknowledge_security_deployment == true
    error_message = "You must acknowledge the comprehensive security deployment by setting acknowledge_security_deployment = true."
  }
}

variable "security_commitment_accepted" {
  type        = bool
  description = "Accept commitment to maintain security best practices"
  default     = false
  
  validation {
    condition     = var.security_commitment_accepted == true
    error_message = "You must accept the security commitment by setting security_commitment_accepted = true."
  }
}