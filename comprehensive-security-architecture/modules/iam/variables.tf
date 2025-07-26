# ========================================
# IAM MODULE - VARIABLES
# ========================================

variable "tenancy_ocid" {
  type        = string
  description = "OCID of the tenancy"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}

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
  description = "Whether to create IAM policies"
  default     = true
}