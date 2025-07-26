# ========================================
# MÓDULO IAM ENDURECIDO - VARIABLES
# ========================================

variable "tenancy_ocid" {
  type        = string
  description = "OCID of the tenancy"
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

variable "create_compartment_hierarchy" {
  type        = bool
  description = "Create hierarchical compartment structure for better security isolation"
  default     = true
}

variable "enable_least_privilege_policies" {
  type        = bool
  description = "Enable least privilege IAM policies"
  default     = true
}

variable "enforce_mfa_requirements" {
  type        = bool
  description = "Enforce MFA requirements for administrative users"
  default     = true
}

variable "enable_identity_domains" {
  type        = bool
  description = "Enable Identity Domains for advanced identity management"
  default     = true
}