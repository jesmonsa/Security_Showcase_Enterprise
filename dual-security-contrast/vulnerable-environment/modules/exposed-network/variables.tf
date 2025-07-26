# ========================================
# MÓDULO NETWORK EXPUESTA - VARIABLES
# ========================================

variable "compartment_ocid" {
  type        = string
  description = "OCID of the compartment for network resources"
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

variable "vcn_cidr_block" {
  type        = string
  description = "CIDR block for the vulnerable VCN"
  default     = "10.50.0.0/16"
}

variable "allow_all_traffic" {
  type        = bool
  description = "Allow all traffic (INSECURE - for demonstration)"
  default     = true
}

variable "disable_waf" {
  type        = bool
  description = "Disable WAF protection (INSECURE)"
  default     = true
}

variable "public_database_access" {
  type        = bool
  description = "Allow public access to database (CRITICAL RISK)"
  default     = true
}