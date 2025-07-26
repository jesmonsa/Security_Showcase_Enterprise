# ========================================
# MÓDULO NETWORK SEGURO - VARIABLES
# Comprehensive network security configuration
# ========================================

variable "compartment_ocid" {
  type        = string
  description = "OCID of the network compartment"
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
# VCN CONFIGURATION
# ========================================
variable "vcn_cidr_block" {
  type        = string
  description = "CIDR block for the secure VCN"
  default     = "10.60.0.0/16"
  
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vcn_cidr_block))
    error_message = "VCN CIDR block must be a valid CIDR notation."
  }
}

variable "enable_ipv6" {
  type        = bool
  description = "Enable IPv6 for VCN (not recommended for maximum security control)"
  default     = false
}

# ========================================
# SECURITY CONFIGURATION
# ========================================
variable "enable_waf" {
  type        = bool
  description = "Enable Web Application Firewall for Load Balancer"
  default     = true
}

variable "enable_ddos_protection" {
  type        = bool
  description = "Enable DDoS protection"
  default     = true
}

variable "enable_flow_logs" {
  type        = bool
  description = "Enable VCN Flow Logs for network monitoring"
  default     = true
}

variable "enable_bastion_service" {
  type        = bool
  description = "Enable Oracle Bastion Service for secure access"
  default     = true
}

variable "enable_network_security_groups" {
  type        = bool
  description = "Enable Network Security Groups (NSGs) for granular control"
  default     = true
}

variable "enable_geo_blocking" {
  type        = bool
  description = "Enable geographic blocking in WAF"
  default     = false  # Puede interferir con demos globales
}

# ========================================
# WAF CONFIGURATION
# ========================================
variable "waf_domain_names" {
  type        = list(string)
  description = "Domain names to protect with WAF"
  default     = ["secure-demo.oracledemo.com"]
}

variable "waf_origin_uri" {
  type        = string
  description = "Origin URI for WAF (Load Balancer)"
  default     = ""
}

variable "enable_waf_bot_management" {
  type        = bool
  description = "Enable WAF bot management"
  default     = true
}

variable "enable_waf_rate_limiting" {
  type        = bool
  description = "Enable WAF rate limiting"
  default     = true
}

variable "waf_rate_limit_requests_per_second" {
  type        = number
  description = "Requests per second limit for WAF"
  default     = 100
  
  validation {
    condition     = var.waf_rate_limit_requests_per_second >= 1 && var.waf_rate_limit_requests_per_second <= 10000
    error_message = "WAF rate limit must be between 1 and 10000 requests per second."
  }
}

# ========================================
# BASTION CONFIGURATION
# ========================================
variable "bastion_client_cidr_block_allow_list" {
  type        = list(string)
  description = "CIDR blocks allowed to connect to Bastion Service"
  default     = ["0.0.0.0/0"]  # Restricciones adicionales en el servicio
}

variable "bastion_max_session_ttl_in_seconds" {
  type        = number
  description = "Maximum session TTL for Bastion Service in seconds"
  default     = 3600  # 1 hour
  
  validation {
    condition     = var.bastion_max_session_ttl_in_seconds >= 1800 && var.bastion_max_session_ttl_in_seconds <= 10800
    error_message = "Bastion session TTL must be between 30 minutes (1800s) and 3 hours (10800s)."
  }
}

# ========================================
# LOGGING CONFIGURATION
# ========================================
variable "log_retention_duration" {
  type        = number
  description = "Log retention duration in days"
  default     = 365
  
  validation {
    condition     = var.log_retention_duration >= 90 && var.log_retention_duration <= 2555
    error_message = "Log retention must be between 90 days and 7 years (2555 days)."
  }
}

variable "enable_audit_logs" {
  type        = bool
  description = "Enable audit logs for network resources"
  default     = true
}

variable "enable_security_logs" {
  type        = bool
  description = "Enable security-specific logs"
  default     = true
}

# ========================================
# LOAD BALANCER CONFIGURATION
# ========================================
variable "lb_shape" {
  type        = string
  description = "Load balancer shape"
  default     = "flexible"
  
  validation {
    condition     = contains(["flexible", "10Mbps", "100Mbps", "400Mbps", "8000Mbps"], var.lb_shape)
    error_message = "Load balancer shape must be flexible, 10Mbps, 100Mbps, 400Mbps, or 8000Mbps."
  }
}

variable "lb_shape_details_minimum_bandwidth_in_mbps" {
  type        = number
  description = "Minimum bandwidth for flexible load balancer in Mbps"
  default     = 10
  
  validation {
    condition     = var.lb_shape_details_minimum_bandwidth_in_mbps >= 10 && var.lb_shape_details_minimum_bandwidth_in_mbps <= 8000
    error_message = "Minimum bandwidth must be between 10 and 8000 Mbps."
  }
}

variable "lb_shape_details_maximum_bandwidth_in_mbps" {
  type        = number
  description = "Maximum bandwidth for flexible load balancer in Mbps"
  default     = 100
  
  validation {
    condition     = var.lb_shape_details_maximum_bandwidth_in_mbps >= 10 && var.lb_shape_details_maximum_bandwidth_in_mbps <= 8000
    error_message = "Maximum bandwidth must be between 10 and 8000 Mbps."
  }
}

variable "enable_lb_ssl_termination" {
  type        = bool
  description = "Enable SSL termination at Load Balancer"
  default     = true
}

variable "ssl_certificate_name" {
  type        = string
  description = "Name of SSL certificate for Load Balancer"
  default     = "secure-demo-cert"
}

# ========================================
# NETWORK SECURITY GROUPS CONFIGURATION  
# ========================================
variable "create_web_nsg" {
  type        = bool
  description = "Create Network Security Group for web tier"
  default     = true
}

variable "create_app_nsg" {
  type        = bool
  description = "Create Network Security Group for app tier"
  default     = true
}

variable "create_db_nsg" {
  type        = bool
  description = "Create Network Security Group for database tier"
  default     = true
}

variable "create_lb_nsg" {
  type        = bool
  description = "Create Network Security Group for load balancer"
  default     = true
}

variable "create_bastion_nsg" {
  type        = bool
  description = "Create Network Security Group for bastion"
  default     = true
}

# ========================================
# ADVANCED SECURITY FEATURES
# ========================================
variable "enable_intrusion_detection" {
  type        = bool
  description = "Enable network intrusion detection"
  default     = true
}

variable "enable_threat_intelligence" {
  type        = bool
  description = "Enable threat intelligence feeds"
  default     = true
}

variable "enable_network_firewall" {
  type        = bool
  description = "Enable OCI Network Firewall (additional cost)"
  default     = false  # Costoso, habilitar solo si se requiere máxima seguridad
}

# ========================================
# COMPLIANCE CONFIGURATION
# ========================================
variable "compliance_frameworks" {
  type        = list(string)
  description = "Compliance frameworks to adhere to"
  default     = ["PCI_DSS", "SOX", "GDPR", "ISO27001"]
}

variable "enable_pci_dss_mode" {
  type        = bool
  description = "Enable PCI DSS compliance mode with additional network controls"
  default     = false
}

# ========================================
# MONITORING INTEGRATION
# ========================================
variable "notification_email" {
  type        = string
  description = "Email for network security notifications"
  default     = ""
  
  validation {
    condition     = var.notification_email == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Notification email must be a valid email address or empty."
  }
}

variable "enable_siem_integration" {
  type        = bool
  description = "Enable SIEM integration for network logs"
  default     = false
}

# ========================================
# COST OPTIMIZATION
# ========================================
variable "enable_cost_optimization" {
  type        = bool
  description = "Enable cost optimization (may reduce some security features)"
  default     = false  # Seguridad sobre costo por defecto
}

# ========================================
# DEMO CONFIGURATION
# ========================================
variable "demo_mode" {
  type        = bool
  description = "Enable demo mode with additional logging and documentation"
  default     = true
}

variable "create_demo_endpoints" {
  type        = bool
  description = "Create demo endpoints for testing network security"
  default     = true
}