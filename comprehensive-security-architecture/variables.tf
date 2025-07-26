# ========================================
# COMPREHENSIVE SECURITY ARCHITECTURE - VARIABLES
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
# ENVIRONMENT AND TAGGING
# ========================================
variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# ========================================
# IAM CONFIGURATION
# ========================================
variable "create_compartments" {
  type        = bool
  description = "Whether to create compartment structure"
  default     = true
}

variable "create_security_groups" {
  type        = bool
  description = "Whether to create security user groups"
  default     = true
}

variable "create_policies" {
  type        = bool
  description = "Whether to create security policies"
  default     = true
}

# ========================================
# NETWORK CONFIGURATION
# ========================================
variable "vcn_cidr_block" {
  type        = string
  description = "CIDR block for the VCN"
  default     = "10.40.0.0/16"
  
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vcn_cidr_block))
    error_message = "VCN CIDR block must be a valid CIDR notation."
  }
}

variable "enable_flow_logs" {
  type        = bool
  description = "Enable VCN Flow Logs for network monitoring"
  default     = true
}

# ========================================
# COMPUTE CONFIGURATION
# ========================================
variable "instance_shape" {
  type        = string
  description = "Shape for compute instances"
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
  description = "Number of compute instances to create"
  default     = 2
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "enable_os_hardening" {
  type        = bool
  description = "Enable OS security hardening scripts"
  default     = true
}

# ========================================
# DATABASE CONFIGURATION
# ========================================
variable "enable_database" {
  type        = bool
  description = "Whether to deploy Autonomous Database"
  default     = true
}

variable "enable_data_safe" {
  type        = bool
  description = "Enable Oracle Data Safe for database security"
  default     = true
}

variable "enable_vault_integration" {
  type        = bool
  description = "Enable Vault integration for database encryption"
  default     = true
}

# ========================================
# VAULT/KMS CONFIGURATION
# ========================================
variable "create_master_key" {
  type        = bool
  description = "Create master encryption key in Vault"
  default     = true
}

# ========================================
# WAF CONFIGURATION
# ========================================
variable "enable_waf" {
  type        = bool
  description = "Enable Web Application Firewall"
  default     = true
}

variable "waf_domain_names" {
  type        = list(string)
  description = "Domain names to protect with WAF"
  default     = ["comprehensive-security-demo.oracledemo.com"]
}

variable "waf_origin_servers" {
  type        = list(string)
  description = "Origin servers for WAF"
  default     = []
}

# ========================================
# MONITORING CONFIGURATION
# ========================================
variable "enable_cloud_guard" {
  type        = bool
  description = "Enable Oracle Cloud Guard"
  default     = true
}

variable "enable_audit_logging" {
  type        = bool
  description = "Enable comprehensive audit logging"
  default     = true
}

variable "log_retention_duration" {
  type        = number
  description = "Log retention duration in days"
  default     = 90
  
  validation {
    condition     = var.log_retention_duration >= 30 && var.log_retention_duration <= 365
    error_message = "Log retention must be between 30 and 365 days."
  }
}

# ========================================
# SECURITY ZONES
# ========================================
variable "enable_security_zones" {
  type        = bool
  description = "Enable Oracle Security Zones"
  default     = true
}

variable "security_zone_recipe_id" {
  type        = string
  description = "OCID of the Security Zone recipe to use"
  default     = ""
}

# ========================================
# ADDITIONAL SECURITY FEATURES
# ========================================
variable "enable_bastion_service" {
  type        = bool
  description = "Enable Oracle Bastion Service"
  default     = true
}

variable "enable_vulnerability_scanning" {
  type        = bool
  description = "Enable Vulnerability Scanning Service"
  default     = true
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