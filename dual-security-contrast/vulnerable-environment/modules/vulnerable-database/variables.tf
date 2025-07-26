# ========================================
# MÓDULO DATABASE VULNERABLE - VARIABLES
# ========================================

variable "compartment_ocid" {
  type        = string
  description = "OCID of the compartment for database resources"
}

variable "subnet_id" {
  type        = string
  description = "OCID of the subnet (should be public for vulnerability demo)"
}

variable "environment" {
  type        = string
  description = "Environment name (vulnerable)"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}

variable "db_name" {
  type        = string
  description = "Name of the vulnerable database"
  default     = "VULNDB23"
  
  validation {
    condition     = can(regex("^[A-Z][A-Z0-9]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only uppercase letters and numbers."
  }
}

variable "use_weak_passwords" {
  type        = bool
  description = "Use intentionally weak passwords for demonstration"
  default     = true
}

variable "disable_database_firewall" {
  type        = bool
  description = "Disable Oracle Database Firewall (INSECURE - for demo)"
  default     = true
}

variable "disable_data_safe" {
  type        = bool
  description = "Disable Oracle Data Safe (INSECURE - for demo)"
  default     = true
}

variable "disable_encryption" {
  type        = bool
  description = "Use only basic encryption (INSECURE - for demo)"
  default     = true
}

variable "allow_public_access" {
  type        = bool
  description = "Allow public access to database (CRITICAL RISK - for demo)"
  default     = true
}

variable "skip_backup_encryption" {
  type        = bool
  description = "Skip additional backup encryption (INSECURE - for demo)"
  default     = true
}

variable "disable_audit_logging" {
  type        = bool
  description = "Disable comprehensive audit logging (INSECURE - for demo)"
  default     = true
}