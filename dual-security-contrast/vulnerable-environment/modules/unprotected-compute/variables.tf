# ========================================
# MÓDULO COMPUTE DESPROTEGIDO - VARIABLES
# ========================================

variable "compartment_ocid" {
  type        = string
  description = "OCID of the compartment for compute resources"
}

variable "vcn_id" {
  type        = string
  description = "OCID of the VCN"
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

variable "instance_shape" {
  type        = string
  description = "Shape for vulnerable compute instances"
  default     = "VM.Standard.E4.Flex"
}

variable "instance_count" {
  type        = number
  description = "Number of vulnerable instances to create"
  default     = 2
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 5
    error_message = "Instance count must be between 1 and 5 for demo purposes."
  }
}

variable "disable_os_hardening" {
  type        = bool
  description = "Disable OS security hardening (INSECURE - for demo)"
  default     = true
}

variable "enable_password_auth" {
  type        = bool
  description = "Enable SSH password authentication (INSECURE - for demo)"
  default     = true
}

variable "install_vulnerable_apps" {
  type        = bool
  description = "Install vulnerable applications for demonstration"
  default     = true
}

variable "skip_vulnerability_scanning" {
  type        = bool
  description = "Skip vulnerability scanning service (INSECURE - for demo)"
  default     = true
}

variable "database_connection" {
  type        = string
  description = "Database connection string for vulnerable applications"
  default     = "localhost:1521/VULNDB23"
  sensitive   = true
}