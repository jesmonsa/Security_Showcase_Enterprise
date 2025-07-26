# ========================================
# MÓDULO COMPREHENSIVE MONITORING - VARIABLES
# Cloud Guard, Logging, Monitoring, y Alertas
# ========================================

variable "tenancy_ocid" {
  type        = string
  description = "OCID of the tenancy"
}

variable "compartment_ocid" {
  type        = string
  description = "OCID of the compartment for monitoring resources"
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
# CLOUD GUARD CONFIGURATION
# ========================================
variable "enable_cloud_guard" {
  type        = bool
  description = "Enable Oracle Cloud Guard"
  default     = true
}

variable "cloud_guard_reporting_region" {
  type        = string
  description = "Reporting region for Cloud Guard"
  default     = ""
}

variable "enable_cloud_guard_self_manage" {
  type        = bool
  description = "Enable self-management of Cloud Guard resources"
  default     = true
}

# ========================================
# VULNERABILITY SCANNING CONFIGURATION
# ========================================
variable "enable_vulnerability_scanning" {
  type        = bool
  description = "Enable automated vulnerability scanning"
  default     = true
}

variable "vulnerability_scan_level" {
  type        = string
  description = "Vulnerability scanning level"
  default     = "STANDARD"
  
  validation {
    condition     = contains(["STANDARD", "AGGRESSIVE"], var.vulnerability_scan_level)
    error_message = "Vulnerability scan level must be STANDARD or AGGRESSIVE."
  }
}

variable "vulnerability_scan_schedule" {
  type        = string
  description = "Vulnerability scan schedule"
  default     = "WEEKLY"
  
  validation {
    condition     = contains(["DAILY", "WEEKLY", "MONTHLY"], var.vulnerability_scan_schedule)
    error_message = "Vulnerability scan schedule must be DAILY, WEEKLY, or MONTHLY."
  }
}

variable "cis_benchmark_level" {
  type        = string
  description = "CIS benchmark scanning level"
  default     = "STRICT"
  
  validation {
    condition     = contains(["STRICT", "MEDIUM", "LENIENT"], var.cis_benchmark_level)
    error_message = "CIS benchmark level must be STRICT, MEDIUM, or LENIENT."
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
  description = "Enable comprehensive audit logging"
  default     = true
}

variable "create_additional_flow_logs" {
  type        = bool
  description = "Create additional VCN flow logs (if not created by network module)"
  default     = false
}

variable "vcn_id" {
  type        = string
  description = "OCID of the VCN for flow logs"
  default     = ""
}

variable "enable_log_analytics" {
  type        = bool
  description = "Enable OCI Log Analytics workspace"
  default     = true
}

# ========================================
# NOTIFICATION CONFIGURATION
# ========================================
variable "notification_email" {
  type        = string
  description = "Email for security notifications"
  default     = ""
  
  validation {
    condition     = var.notification_email == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Notification email must be a valid email address or empty."
  }
}

variable "enable_sms_notifications" {
  type        = bool
  description = "Enable SMS notifications for critical alerts"
  default     = false
}

variable "sms_phone_number" {
  type        = string
  description = "Phone number for SMS notifications (E.164 format)"
  default     = ""
}

variable "enable_slack_integration" {
  type        = bool
  description = "Enable Slack integration for notifications"
  default     = false
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack webhook URL for notifications"
  default     = ""
  sensitive   = true
}

# ========================================
# MONITORING AND ALERTING
# ========================================
variable "enable_comprehensive_monitoring" {
  type        = bool
  description = "Enable comprehensive monitoring with custom alarms"
  default     = true
}

variable "database_connection_threshold" {
  type        = number
  description = "Threshold for database connection alarms"
  default     = 50
  
  validation {
    condition     = var.database_connection_threshold >= 10 && var.database_connection_threshold <= 500
    error_message = "Database connection threshold must be between 10 and 500."
  }
}

variable "failed_login_threshold" {
  type        = number
  description = "Threshold for failed login attempts alarm"
  default     = 10
  
  validation {
    condition     = var.failed_login_threshold >= 3 && var.failed_login_threshold <= 100
    error_message = "Failed login threshold must be between 3 and 100."
  }
}

variable "network_traffic_threshold_mbps" {
  type        = number
  description = "Network traffic threshold in Mbps for anomaly detection"
  default     = 100
  
  validation {
    condition     = var.network_traffic_threshold_mbps >= 10 && var.network_traffic_threshold_mbps <= 10000
    error_message = "Network traffic threshold must be between 10 and 10000 Mbps."
  }
}

# ========================================
# APPLICATION PERFORMANCE MONITORING
# ========================================
variable "enable_apm" {
  type        = bool
  description = "Enable Application Performance Monitoring (APM)"
  default     = true
}

variable "apm_free_tier" {
  type        = bool
  description = "Use APM free tier"
  default     = true
}

variable "enable_synthetic_monitoring" {
  type        = bool
  description = "Enable synthetic monitoring for applications"
  default     = false  # Requires additional configuration
}

# ========================================
# DATA SAFE CONFIGURATION
# ========================================
variable "enable_data_safe_global" {
  type        = bool
  description = "Enable Data Safe at tenancy level"
  default     = true
}

variable "data_safe_assessment_schedule" {
  type        = string
  description = "Data Safe security assessment schedule"
  default     = "WEEKLY"
  
  validation {
    condition     = contains(["DAILY", "WEEKLY", "MONTHLY"], var.data_safe_assessment_schedule)
    error_message = "Data Safe assessment schedule must be DAILY, WEEKLY, or MONTHLY."
  }
}

# ========================================
# SECURITY DASHBOARD
# ========================================
variable "create_security_dashboard" {
  type        = bool
  description = "Create comprehensive security monitoring dashboard"
  default     = true
}

variable "dashboard_refresh_interval" {
  type        = number
  description = "Dashboard refresh interval in minutes"
  default     = 5
  
  validation {
    condition     = var.dashboard_refresh_interval >= 1 && var.dashboard_refresh_interval <= 60
    error_message = "Dashboard refresh interval must be between 1 and 60 minutes."
  }
}

# ========================================
# COMPLIANCE AND REPORTING
# ========================================
variable "compliance_frameworks" {
  type        = list(string)
  description = "Compliance frameworks to monitor"
  default     = ["PCI_DSS", "SOX", "GDPR", "ISO27001"]
  
  validation {
    condition = alltrue([
      for framework in var.compliance_frameworks :
      contains(["PCI_DSS", "SOX", "GDPR", "HIPAA", "ISO27001", "NIST", "CIS"], framework)
    ])
    error_message = "Supported compliance frameworks: PCI_DSS, SOX, GDPR, HIPAA, ISO27001, NIST, CIS."
  }
}

variable "enable_compliance_reporting" {
  type        = bool
  description = "Enable automated compliance reporting"
  default     = true
}

variable "compliance_report_schedule" {
  type        = string
  description = "Compliance report generation schedule"
  default     = "MONTHLY"
  
  validation {
    condition     = contains(["WEEKLY", "MONTHLY", "QUARTERLY"], var.compliance_report_schedule)
    error_message = "Compliance report schedule must be WEEKLY, MONTHLY, or QUARTERLY."
  }
}

# ========================================
# ADVANCED MONITORING FEATURES
# ========================================
variable "enable_anomaly_detection" {
  type        = bool
  description = "Enable ML-based anomaly detection"
  default     = true
}

variable "enable_predictive_analytics" {
  type        = bool
  description = "Enable predictive analytics for security trends"
  default     = false  # Advanced feature, may require additional setup
}

variable "enable_threat_intelligence" {
  type        = bool
  description = "Enable threat intelligence feeds integration"
  default     = true
}

variable "threat_intelligence_sources" {
  type        = list(string)
  description = "Threat intelligence sources to integrate"
  default     = ["OCI_THREAT_INTEL", "INDUSTRY_FEEDS"]
}

# ========================================
# INCIDENT RESPONSE
# ========================================
variable "enable_automated_response" {
  type        = bool
  description = "Enable automated incident response"
  default     = true
}

variable "auto_response_severity_threshold" {
  type        = string
  description = "Minimum severity for automated responses"
  default     = "MEDIUM"
  
  validation {
    condition     = contains(["LOW", "MEDIUM", "HIGH", "CRITICAL"], var.auto_response_severity_threshold)
    error_message = "Auto response severity threshold must be LOW, MEDIUM, HIGH, or CRITICAL."
  }
}

variable "enable_quarantine_response" {
  type        = bool
  description = "Enable automatic quarantine of compromised resources"
  default     = false  # Requires careful consideration
}

# ========================================
# INTEGRATION WITH EXTERNAL TOOLS
# ========================================
variable "enable_siem_integration" {
  type        = bool
  description = "Enable SIEM integration"
  default     = false
}

variable "siem_endpoint" {
  type        = string
  description = "SIEM endpoint for log forwarding"
  default     = ""
  sensitive   = true
}

variable "enable_splunk_integration" {
  type        = bool
  description = "Enable Splunk integration"
  default     = false
}

variable "splunk_hec_endpoint" {
  type        = string
  description = "Splunk HTTP Event Collector endpoint"
  default     = ""
  sensitive   = true
}

variable "splunk_hec_token" {
  type        = string
  description = "Splunk HTTP Event Collector token"
  default     = ""
  sensitive   = true
}

# ========================================
# COST OPTIMIZATION
# ========================================
variable "enable_cost_optimization" {
  type        = bool
  description = "Enable cost optimization features"
  default     = false  # Security over cost by default
}

variable "monitoring_tier" {
  type        = string
  description = "Monitoring tier (affects cost and features)"
  default     = "PREMIUM"
  
  validation {
    condition     = contains(["BASIC", "STANDARD", "PREMIUM"], var.monitoring_tier)
    error_message = "Monitoring tier must be BASIC, STANDARD, or PREMIUM."
  }
}

# ========================================
# DEMO CONFIGURATION
# ========================================
variable "demo_mode" {
  type        = bool
  description = "Enable demo mode with additional monitoring and documentation"
  default     = true
}

variable "create_demo_metrics" {
  type        = bool
  description = "Create demo metrics for testing monitoring"
  default     = true
}

variable "enable_demo_alerts" {
  type        = bool
  description = "Enable demo alerts with lower thresholds for testing"
  default     = true
}

# ========================================
# CUSTOM MONITORING
# ========================================
variable "custom_metrics_namespace" {
  type        = string
  description = "Namespace for custom security metrics"
  default     = "custom_security_metrics"
}

variable "enable_custom_dashboards" {
  type        = bool
  description = "Enable custom monitoring dashboards"
  default     = true
}

variable "dashboard_time_range" {
  type        = string
  description = "Default time range for dashboards"
  default     = "1h"
  
  validation {
    condition     = contains(["15m", "1h", "6h", "24h", "7d", "30d"], var.dashboard_time_range)
    error_message = "Dashboard time range must be 15m, 1h, 6h, 24h, 7d, or 30d."
  }
}