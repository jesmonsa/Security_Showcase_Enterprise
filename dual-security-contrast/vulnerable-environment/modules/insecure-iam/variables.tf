# ========================================
# MÓDULO IAM INSEGURO - VARIABLES
# ========================================

variable "tenancy_ocid" {
  type        = string
  description = "OCID of the tenancy"
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