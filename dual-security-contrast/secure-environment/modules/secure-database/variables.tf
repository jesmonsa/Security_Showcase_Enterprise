# ========================================
# MÓDULO DATABASE SEGURO - VARIABLES
# Oracle 23ai CON Database Firewall
# ========================================

variable "compartment_ocid" {
  type        = string
  description = "OCID of the database compartment"
}

variable "environment" {
  type        = string
  description = "Environment name (secure)"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}

# ========================================
# DATABASE CONFIGURATION
# ========================================
variable "db_name" {
  type        = string
  description = "Database name"
  default     = "SECUREDB23AI"
  
  validation {
    condition     = can(regex("^[A-Z][A-Z0-9]{0,13}$", var.db_name))
    error_message = "Database name must start with a letter, contain only uppercase letters and numbers, and be at most 14 characters long."
  }
}

variable "db_version" {
  type        = string
  description = "Oracle Database version"
  default     = "23ai"
  
  validation {
    condition     = contains(["23ai", "23c", "21c", "19c"], var.db_version)
    error_message = "Database version must be 23ai (recommended), 23c, 21c, or 19c."
  }
}

variable "cpu_core_count" {
  type        = number
  description = "Number of CPU cores for the database"
  default     = 2
  
  validation {
    condition     = var.cpu_core_count >= 1 && var.cpu_core_count <= 128
    error_message = "CPU core count must be between 1 and 128."
  }
}

variable "data_storage_size_in_tbs" {
  type        = number
  description = "Database storage size in TB"
  default     = 1
  
  validation {
    condition     = var.data_storage_size_in_tbs >= 1 && var.data_storage_size_in_tbs <= 384
    error_message = "Storage size must be between 1 and 384 TB."
  }
}

variable "db_workload" {
  type        = string
  description = "Database workload type"
  default     = "OLTP"
  
  validation {
    condition     = contains(["OLTP", "DW", "AJD", "APEX"], var.db_workload)
    error_message = "Database workload must be OLTP, DW (Data Warehouse), AJD (Autonomous JSON Database), or APEX."
  }
}

# ========================================
# SECURITY CONFIGURATION
# ========================================
variable "db_admin_password" {
  type        = string
  description = "Database admin password (leave empty for auto-generation)"
  default     = ""
  sensitive   = true
}

variable "use_strong_passwords" {
  type        = bool
  description = "Use strong password generation"
  default     = true
}

variable "enable_database_firewall" {
  type        = bool
  description = "Enable Oracle 23ai Database Firewall (CRITICAL SECURITY FEATURE)"
  default     = true
}

variable "enable_data_safe" {
  type        = bool
  description = "Enable Oracle Data Safe for comprehensive database security"
  default     = true
}

variable "enable_unified_auditing" {
  type        = bool
  description = "Enable unified auditing"
  default     = true
}

# ========================================
# NETWORK CONFIGURATION
# ========================================
variable "subnet_id" {
  type        = string
  description = "OCID of the private subnet for the database"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of Network Security Group OCIDs"
  default     = []
}

variable "whitelisted_ips" {
  type        = list(string)
  description = "List of whitelisted IP addresses (CIDR notation)"
  default     = ["10.60.0.0/16"]  # Solo subnet privada por defecto
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Enable private endpoint for database access"
  default     = true
}

variable "private_endpoint_label" {
  type        = string
  description = "Label for the private endpoint"
  default     = "secure-db-endpoint"
}

# ========================================
# ENCRYPTION CONFIGURATION
# ========================================
variable "kms_key_id" {
  type        = string
  description = "OCID of the KMS key for customer-managed encryption"
  default     = ""
}

variable "enable_backup_encryption" {
  type        = bool
  description = "Enable backup encryption"
  default     = true
}

# ========================================
# HIGH AVAILABILITY CONFIGURATION
# ========================================
variable "enable_data_guard" {
  type        = bool
  description = "Enable Data Guard for high availability"
  default     = true
}

variable "enable_auto_scaling" {
  type        = bool
  description = "Enable auto scaling"
  default     = true
}

variable "use_dedicated_infrastructure" {
  type        = bool
  description = "Use dedicated infrastructure for better isolation"
  default     = false  # Más costoso, habilitar si se requiere máximo aislamiento
}

# ========================================
# BACKUP CONFIGURATION
# ========================================
variable "backup_retention_days" {
  type        = number
  description = "Backup retention period in days"
  default     = 35
  
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 365
    error_message = "Backup retention must be between 7 and 365 days."
  }
}

variable "recovery_window_days" {
  type        = number
  description = "Point-in-time recovery window in days"
  default     = 30
  
  validation {
    condition     = var.recovery_window_days >= 1 && var.recovery_window_days <= 60
    error_message = "Recovery window must be between 1 and 60 days."
  }
}

variable "enable_cross_region_backup" {
  type        = bool
  description = "Enable cross-region backup for disaster recovery"
  default     = true
}

# ========================================
# MONITORING CONFIGURATION
# ========================================
variable "enable_performance_insights" {
  type        = bool
  description = "Enable performance insights"
  default     = true
}

variable "enable_operations_insights" {
  type        = bool
  description = "Enable operations insights"
  default     = true
}

# ========================================
# COMPLIANCE CONFIGURATION
# ========================================
variable "compliance_frameworks" {
  type        = list(string)
  description = "Compliance frameworks to adhere to"
  default     = ["PCI_DSS", "SOX", "GDPR", "ISO27001"]
}

variable "enable_fips_mode" {
  type        = bool
  description = "Enable FIPS 140-2 compliance mode"
  default     = false  # Puede impactar performance
}

# ========================================
# DEMO CONFIGURATION
# ========================================
variable "demo_mode" {
  type        = bool
  description = "Enable demo mode with additional logging"
  default     = true
}

variable "create_sample_data" {
  type        = bool
  description = "Create sample data for demonstration"
  default     = false  # Solo para demos específicas
}