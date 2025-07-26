# ========================================
# MÓDULO APLICACIÓN VULNERABLE - VARIABLES
# ========================================

variable "compartment_ocid" {
  type        = string
  description = "OCID of the compartment for application resources"
}

variable "compute_instance_ids" {
  type        = list(string)
  description = "List of compute instance IDs to deploy vulnerable application"
}

variable "instance_public_ips" {
  type        = list(string)
  description = "List of public IP addresses for compute instances"
}

variable "database_connection" {
  type        = string
  description = "Database connection string for vulnerable application"
  sensitive   = true
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

# ========================================
# VULNERABILITY CONFIGURATION
# ========================================

variable "enable_sql_injection" {
  type        = bool
  description = "Enable SQL injection vulnerabilities (INSECURE - for demo)"
  default     = true
}

variable "enable_xss_vulnerabilities" {
  type        = bool
  description = "Enable XSS vulnerabilities (INSECURE - for demo)"
  default     = true
}

variable "enable_path_traversal" {
  type        = bool
  description = "Enable path traversal vulnerabilities (INSECURE - for demo)"
  default     = true
}

variable "hardcode_secrets" {
  type        = bool
  description = "Hardcode secrets in application code (INSECURE - for demo)"
  default     = true
}

variable "disable_input_validation" {
  type        = bool
  description = "Disable input validation (INSECURE - for demo)"
  default     = true
}

variable "enable_verbose_errors" {
  type        = bool
  description = "Enable verbose error messages (INSECURE - for demo)"
  default     = true
}

variable "disable_https_enforcement" {
  type        = bool
  description = "Disable HTTPS enforcement (INSECURE - for demo)"
  default     = true
}