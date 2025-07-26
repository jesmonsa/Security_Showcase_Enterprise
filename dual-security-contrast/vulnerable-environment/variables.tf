# ========================================
# AMBIENTE VULNERABLE - VARIABLES
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
}

# ========================================
# ENVIRONMENT CONFIGURATION
# ========================================
variable "environment" {
  type        = string
  description = "Environment name for vulnerable demo"
  default     = "vulnerable"
}

# ========================================
# NETWORK CONFIGURATION - INSECURE
# ========================================
variable "vcn_cidr_block" {
  type        = string
  description = "CIDR block for the vulnerable VCN"
  default     = "10.50.0.0/16"  # Diferente rango para evitar conflictos
}

# ========================================
# COMPUTE CONFIGURATION - UNPROTECTED
# ========================================
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

# ========================================
# DATABASE CONFIGURATION - ORACLE 23ai VULNERABLE
# ========================================
variable "db_admin_password" {
  type        = string
  description = "Database admin password (deliberately weak for demo)"
  default     = "Welcome123!"  # WEAK PASSWORD INTENTIONALLY
  sensitive   = true
}

variable "enable_public_database_access" {
  type        = bool
  description = "Enable public access to database (INSECURE)"
  default     = true  # INSECURE BY DESIGN
}

# ========================================
# VULNERABILITY SIMULATION SETTINGS
# ========================================
variable "install_vulnerable_software" {
  type        = bool
  description = "Install intentionally vulnerable software for demo"
  default     = true
}

variable "enable_weak_ssl_ciphers" {
  type        = bool
  description = "Enable weak SSL ciphers for demonstration"
  default     = true
}

variable "disable_os_updates" {
  type        = bool
  description = "Disable automatic OS updates (INSECURE)"
  default     = true
}

# ========================================
# MONITORING CONFIGURATION - MINIMAL
# ========================================
variable "enable_basic_logging" {
  type        = bool
  description = "Enable only basic logging (not comprehensive)"
  default     = true
}

variable "disable_security_monitoring" {
  type        = bool
  description = "Disable security monitoring services"
  default     = true
}

# ========================================
# DEMO SPECIFIC SETTINGS
# ========================================
variable "demo_mode" {
  type        = bool
  description = "Enable demo mode with additional vulnerabilities"
  default     = true
}

variable "install_attack_tools" {
  type        = bool
  description = "Install penetration testing tools for demonstration"
  default     = false  # Solo si se requiere para demo avanzada
}

# ========================================
# COST OPTIMIZATION FOR DEMO
# ========================================
variable "use_always_free_resources" {
  type        = bool
  description = "Use Always Free resources where possible"
  default     = false
}

# ========================================
# WARNING ACKNOWLEDGMENT
# ========================================
variable "acknowledge_insecure_deployment" {
  type        = bool
  description = "Acknowledge that this deployment is intentionally insecure for demonstration purposes"
  default     = false
  
  validation {
    condition     = var.acknowledge_insecure_deployment == true
    error_message = "You must acknowledge that this deployment is intentionally insecure by setting acknowledge_insecure_deployment = true."
  }
}

variable "demo_disclaimer_accepted" {
  type        = bool
  description = "Accept that this environment should NEVER be used in production"
  default     = false
  
  validation {
    condition     = var.demo_disclaimer_accepted == true
    error_message = "You must accept the demo disclaimer by setting demo_disclaimer_accepted = true."
  }
}