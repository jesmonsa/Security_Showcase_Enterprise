# ========================================
# MÓDULO MONITORING DESHABILITADO - VARIABLES
# ========================================

variable "compartment_ocid" {
  type        = string
  description = "OCID of the compartment for monitoring resources"
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

variable "disable_cloud_guard" {
  type        = bool
  description = "Disable Cloud Guard security monitoring (INSECURE - for demo)"
  default     = true
}

variable "disable_audit_logging" {
  type        = bool
  description = "Disable comprehensive audit logging (INSECURE - for demo)"
  default     = true
}

variable "disable_flow_logs" {
  type        = bool
  description = "Disable VCN Flow Logs (INSECURE - for demo)"
  default     = true
}

variable "disable_vulnerability_scanning" {
  type        = bool
  description = "Disable Vulnerability Scanning Service (INSECURE - for demo)"
  default     = true
}

variable "skip_security_alerts" {
  type        = bool
  description = "Skip security alert configuration (INSECURE - for demo)"
  default     = true
}