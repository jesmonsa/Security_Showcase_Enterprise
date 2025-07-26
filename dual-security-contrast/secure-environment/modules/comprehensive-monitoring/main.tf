# ========================================
# MÓDULO COMPREHENSIVE MONITORING - CLOUD GUARD & SECURITY
# Monitoreo integral de seguridad con Cloud Guard, Logging, y Alertas
# ========================================

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.21.0"
    }
  }
}

# Data sources
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "regions" {
}

data "oci_cloud_guard_detector_recipes" "detector_recipes" {
  compartment_id = var.tenancy_ocid
  state          = "ACTIVE"
}

data "oci_cloud_guard_responder_recipes" "responder_recipes" {
  compartment_id = var.tenancy_ocid
  state          = "ACTIVE"
}

locals {
  # Naming convention
  resource_prefix = "${var.environment}-secure"
  
  # Current region
  current_region = data.oci_identity_regions.regions.regions[0].name
  
  # Default detector and responder recipes
  oracle_detector_recipe = [
    for recipe in data.oci_cloud_guard_detector_recipes.detector_recipes.detector_recipe_collection[0].items :
    recipe if recipe.owner == "ORACLE"
  ][0]
  
  oracle_responder_recipe = [
    for recipe in data.oci_cloud_guard_responder_recipes.responder_recipes.responder_recipe_collection[0].items :
    recipe if recipe.owner == "ORACLE"
  ][0]
}

# ========================================
# CLOUD GUARD CONFIGURATION - COMPREHENSIVE SECURITY
# ========================================

# Enable Cloud Guard at tenancy level
resource "oci_cloud_guard_cloud_guard_configuration" "secure_cloud_guard_config" {
  compartment_id   = var.tenancy_ocid
  reporting_region = local.current_region
  status           = "ENABLED"
  
  # Self manage resources - full control
  self_manage_resources = true
}

# Cloud Guard Target for comprehensive monitoring
resource "oci_cloud_guard_target" "secure_cloud_guard_target" {
  compartment_id       = var.compartment_ocid
  display_name         = "${local.resource_prefix}-cloud-guard-target"
  target_resource_id   = var.compartment_ocid
  target_resource_type = "COMPARTMENT"
  description          = "Cloud Guard target for secure environment comprehensive monitoring"
  
  target_detector_recipes {
    detector_recipe_id = local.oracle_detector_recipe.id
  }
  
  target_responder_recipes {
    responder_recipe_id = local.oracle_responder_recipe.id
  }
  
  state = "ACTIVE"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-cloud-guard-target"
    Type = "cloud-guard-target"
    Security = "COMPREHENSIVE"
    Monitoring = "REAL_TIME"
  })
}

# ========================================
# VULNERABILITY SCANNING SERVICE
# ========================================

# Vulnerability Scanning Host Recipe
resource "oci_vulnerability_scanning_host_scan_recipe" "secure_host_scan_recipe" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.resource_prefix}-host-scan-recipe"
  
  port_settings {
    scan_level = "STANDARD"
  }
  
  agent_settings {
    scan_level = "STANDARD"
    agent_configuration {
      vendor = "OCI"
      cis_benchmark_settings {
        scan_level = "STRICT"
      }
    }
  }
  
  application_settings {
    application_scan_level = "STANDARD"
  }
  
  schedule {
    type           = "WEEKLY"
    day_of_week    = "SUNDAY"
    time_of_day    = "02:00"
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-host-scan-recipe"
    Type = "vulnerability-scan-recipe"
    Purpose = "SECURITY_ASSESSMENT"
    Schedule = "WEEKLY"
  })
}

# Vulnerability Scanning Host Target
resource "oci_vulnerability_scanning_host_scan_target" "secure_host_scan_target" {
  compartment_id         = var.compartment_ocid
  display_name           = "${local.resource_prefix}-host-scan-target"
  host_scan_recipe_id    = oci_vulnerability_scanning_host_scan_recipe.secure_host_scan_recipe.id
  target_compartment_id  = var.compartment_ocid
  description            = "Vulnerability scanning target for secure environment hosts"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-host-scan-target"
    Type = "vulnerability-scan-target"
    Scope = "ALL_COMPUTE_INSTANCES"
  })
}

# ========================================
# LOGGING ANALYTICS WORKSPACE
# ========================================

# Create Log Analytics Workspace
resource "oci_log_analytics_namespace" "secure_log_analytics_namespace" {
  namespace      = var.tenancy_ocid
  is_onboarded   = true
  compartment_id = var.compartment_ocid
}

resource "oci_log_analytics_log_analytics_entity" "secure_log_analytics_entity" {
  compartment_id = var.compartment_ocid
  entity_type_name = "Host (Linux)"
  name           = "${local.resource_prefix}-log-analytics-entity"
  namespace      = oci_log_analytics_namespace.secure_log_analytics_namespace.namespace
  
  properties = {
    "logPath" = "/var/log"
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-log-analytics-entity"
    Type = "log-analytics-entity"
    Purpose = "SECURITY_LOGS"
  })
}

# ========================================
# COMPREHENSIVE LOGGING CONFIGURATION
# ========================================

# Log Group for Security Events
resource "oci_logging_log_group" "security_log_group" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.resource_prefix}-security-logs"
  description    = "Comprehensive security logging for secure environment"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-security-logs"
    Type = "security-log-group"
    Purpose = "SECURITY_MONITORING"
  })
}

# Audit Logs
resource "oci_logging_log" "audit_logs" {
  display_name = "${local.resource_prefix}-audit-logs"
  log_group_id = oci_logging_log_group.security_log_group.id
  log_type     = "SERVICE"
  
  configuration {
    source {
      category    = "audit"
      resource    = var.compartment_ocid
      service     = "audit"
      source_type = "OCISERVICE"
    }
    
    compartment_id = var.compartment_ocid
  }
  
  is_enabled         = true
  retention_duration = var.log_retention_duration
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-audit-logs"
    Type = "audit-logs"
    Compliance = "SOX_GDPR_PCI"
  })
}

# VCN Flow Logs (if not already created by network module)
resource "oci_logging_log" "security_flow_logs" {
  count        = var.create_additional_flow_logs ? 1 : 0
  display_name = "${local.resource_prefix}-security-flow-logs"
  log_group_id = oci_logging_log_group.security_log_group.id
  log_type     = "SERVICE"
  
  configuration {
    source {
      category    = "all"
      resource    = var.vcn_id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    
    compartment_id = var.compartment_ocid
  }
  
  is_enabled         = true
  retention_duration = var.log_retention_duration
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-security-flow-logs"
    Type = "flow-logs"
    Purpose = "NETWORK_SECURITY_MONITORING"
  })
}

# Cloud Guard Logs
resource "oci_logging_log" "cloud_guard_logs" {
  display_name = "${local.resource_prefix}-cloud-guard-logs"
  log_group_id = oci_logging_log_group.security_log_group.id
  log_type     = "SERVICE"
  
  configuration {
    source {
      category    = "all"
      resource    = oci_cloud_guard_target.secure_cloud_guard_target.id
      service     = "cloudguard"
      source_type = "OCISERVICE"
    }
    
    compartment_id = var.compartment_ocid
  }
  
  is_enabled         = true
  retention_duration = var.log_retention_duration
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-cloud-guard-logs"
    Type = "cloud-guard-logs"
    Purpose = "THREAT_DETECTION"
  })
}

# ========================================
# NOTIFICATION TOPICS AND SUBSCRIPTIONS
# ========================================

# Security Alerts Topic
resource "oci_ons_notification_topic" "security_alerts_topic" {
  compartment_id = var.compartment_ocid
  name           = "${local.resource_prefix}-security-alerts"
  description    = "Security alerts and notifications for secure environment"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-security-alerts"
    Type = "notification-topic"
    Purpose = "SECURITY_ALERTS"
  })
}

# Email Subscription for Security Alerts
resource "oci_ons_subscription" "security_email_subscription" {
  count          = var.notification_email != "" ? 1 : 0
  compartment_id = var.compartment_ocid
  endpoint       = var.notification_email
  protocol       = "EMAIL"
  topic_id       = oci_ons_notification_topic.security_alerts_topic.id
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-security-email-subscription"
    Type = "email-subscription"
    Purpose = "SECURITY_NOTIFICATIONS"
  })
}

# Critical Alerts Topic (for immediate response)
resource "oci_ons_notification_topic" "critical_alerts_topic" {
  compartment_id = var.compartment_ocid
  name           = "${local.resource_prefix}-critical-alerts"
  description    = "Critical security alerts requiring immediate attention"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-critical-alerts"
    Type = "critical-notification-topic"
    Purpose = "CRITICAL_SECURITY_ALERTS"
    Priority = "IMMEDIATE"
  })
}

# ========================================
# MONITORING ALARMS AND RULES
# ========================================

# Database Connection Monitoring
resource "oci_monitoring_alarm" "database_connection_alarm" {
  compartment_id        = var.compartment_ocid
  destinations          = [oci_ons_notification_topic.security_alerts_topic.id]
  display_name          = "${local.resource_prefix}-database-connection-alarm"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_autonomous_database"
  query                 = "DatabaseConnections[1m].count() > 50"
  severity              = "WARNING"
  
  alarm_summary = "High number of database connections detected"
  body = "Alert: High number of concurrent database connections. This may indicate a potential attack or performance issue. Database Firewall and monitoring are active."
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-database-connection-alarm"
    Type = "monitoring-alarm"
    Purpose = "DATABASE_SECURITY"
  })
}

# Failed Login Attempts Alarm
resource "oci_monitoring_alarm" "failed_login_alarm" {
  compartment_id        = var.compartment_ocid
  destinations          = [oci_ons_notification_topic.critical_alerts_topic.id]
  display_name          = "${local.resource_prefix}-failed-login-alarm"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_compute_infrastructure_health"
  query                 = "FailedLoginAttempts[5m].count() > 10"
  severity              = "CRITICAL"
  
  alarm_summary = "Multiple failed login attempts detected"
  body = "CRITICAL: Multiple failed login attempts detected across compute instances. Potential brute force attack in progress. Fail2Ban and security hardening are active."
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-failed-login-alarm"
    Type = "monitoring-alarm"
    Purpose = "AUTHENTICATION_SECURITY"
    Priority = "CRITICAL"
  })
}

# Network Anomaly Detection
resource "oci_monitoring_alarm" "network_anomaly_alarm" {
  compartment_id        = var.compartment_ocid
  destinations          = [oci_ons_notification_topic.security_alerts_topic.id]
  display_name          = "${local.resource_prefix}-network-anomaly-alarm"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_vcn"
  query                 = "VnicEgressBytes[1m].rate() > 100000000"
  severity              = "WARNING"
  
  alarm_summary = "Unusual network traffic detected"
  body = "Alert: High outbound network traffic detected. This may indicate data exfiltration attempt or performance issue. Network monitoring and WAF protection are active."
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-network-anomaly-alarm"
    Type = "monitoring-alarm"
    Purpose = "NETWORK_SECURITY"
  })
}

# Cloud Guard Problem Detection
resource "oci_monitoring_alarm" "cloud_guard_problems_alarm" {
  compartment_id        = var.compartment_ocid
  destinations          = [oci_ons_notification_topic.critical_alerts_topic.id]
  display_name          = "${local.resource_prefix}-cloud-guard-problems"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_cloudguard"
  query                 = "Problems[5m].count() > 0"
  severity              = "CRITICAL"
  
  alarm_summary = "Cloud Guard security problems detected"
  body = "CRITICAL: Cloud Guard has detected security problems in the environment. Immediate investigation required. Automated responses may be in progress."
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-cloud-guard-problems"
    Type = "monitoring-alarm"
    Purpose = "CLOUD_GUARD_MONITORING"
    Priority = "CRITICAL"
  })
}

# ========================================
# APPLICATION PERFORMANCE MONITORING
# ========================================

# APM Domain for Application Monitoring
resource "oci_apm_apm_domain" "secure_apm_domain" {
  count          = var.enable_apm ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${local.resource_prefix}-apm-domain"
  description    = "APM domain for secure application monitoring"
  
  is_free_tier = var.apm_free_tier
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-apm-domain"
    Type = "apm-domain"
    Purpose = "APPLICATION_MONITORING"
  })
}

# ========================================
# SECURITY CENTER INTEGRATION
# ========================================

# Data Safe Service Integration
resource "oci_data_safe_data_safe_configuration" "secure_data_safe_config" {
  count                = var.enable_data_safe_global ? 1 : 0
  compartment_id       = var.tenancy_ocid
  is_enabled           = true
  global_settings_enabled = true
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-data-safe-config"
    Type = "data-safe-configuration"
    Purpose = "DATABASE_SECURITY"
  })
}

# ========================================
# CUSTOM MONITORING DASHBOARDS
# ========================================

# Security Dashboard
resource "oci_management_dashboard_management_dashboards_import" "security_dashboard" {
  count = var.create_security_dashboard ? 1 : 0
  
  import_details_json = jsonencode({
    dashboards = [{
      dashboardId = "${local.resource_prefix}-security-dashboard"
      displayName = "Security Monitoring Dashboard - ${var.environment}"
      description = "Comprehensive security monitoring dashboard for secure environment"
      compartmentId = var.compartment_ocid
      isOobDashboard = false
      isShowInHome = true
      metadataVersion = "1.0"
      isShowDescription = true
      isTimeRangeEditable = true
      widgets = [
        {
          id = "cloud-guard-widget"
          displayName = "Cloud Guard Status"
          description = "Cloud Guard problems and detections"
          visualization = "TABLE"
          widgetType = "LINE"
          x = 0
          y = 0
          width = 12
          height = 6
          nls = {}
          uiConfig = {}
          dataConfig = [{
            query = "CloudGuardProblems | where RiskLevel = 'HIGH' | summarize count() by bin(TimeGenerated, 1h)"
            visualization = "TABLE"
          }]
        },
        {
          id = "database-security-widget"
          displayName = "Database Security"
          description = "Database Firewall and Data Safe status"
          visualization = "SINGLEVALUE"
          widgetType = "SINGLEVALUE"
          x = 12
          y = 0
          width = 6
          height = 6
          nls = {}
          uiConfig = {}
          dataConfig = [{
            query = "DatabaseFirewallEvents | summarize count() by bin(TimeGenerated, 1h)"
            visualization = "SINGLEVALUE"
          }]
        }
      ]
      freeformTags = merge(var.common_tags, {
        Name = "${local.resource_prefix}-security-dashboard"
        Type = "security-dashboard"
        Purpose = "COMPREHENSIVE_MONITORING"
      })
    }]
  })
}

# ========================================
# EVENTS AND AUTOMATION
# ========================================

# Event Rule for Security Incidents
resource "oci_events_rule" "security_incident_rule" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.resource_prefix}-security-incident-rule"
  description    = "Event rule for automated response to security incidents"
  is_enabled     = true
  
  condition = jsonencode({
    eventType = ["com.oraclecloud.cloudguard.problemdetected"]
  })
  
  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      id          = oci_ons_notification_topic.critical_alerts_topic.id
    }
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-security-incident-rule"
    Type = "event-rule"
    Purpose = "AUTOMATED_RESPONSE"
  })
}

# ========================================
# METRICS AND CUSTOM MONITORING
# ========================================

# Custom Metric for Security Score
locals {
  security_metrics = {
    database_firewall_events = {
      namespace = "custom_security_metrics"
      name = "database_firewall_blocked_attempts"
      description = "Number of blocked SQL injection attempts by Database Firewall"
    }
    
    failed_authentication_attempts = {
      namespace = "custom_security_metrics"
      name = "failed_authentication_attempts"
      description = "Number of failed authentication attempts across all services"
    }
    
    cloud_guard_problems = {
      namespace = "custom_security_metrics"
      name = "cloud_guard_active_problems"
      description = "Number of active Cloud Guard security problems"
    }
    
    vulnerability_scan_results = {
      namespace = "custom_security_metrics"
      name = "vulnerability_scan_findings"
      description = "Number of vulnerabilities found in latest scans"
    }
  }
}

# ========================================
# LOCAL VALUES FOR OUTPUTS
# ========================================
locals {
  monitoring_summary = {
    cloud_guard = {
      enabled = true
      target_id = oci_cloud_guard_target.secure_cloud_guard_target.id
      configuration_id = oci_cloud_guard_cloud_guard_configuration.secure_cloud_guard_config.id
    }
    
    vulnerability_scanning = {
      enabled = true
      recipe_id = oci_vulnerability_scanning_host_scan_recipe.secure_host_scan_recipe.id
      target_id = oci_vulnerability_scanning_host_scan_target.secure_host_scan_target.id
    }
    
    logging = {
      security_log_group_id = oci_logging_log_group.security_log_group.id
      audit_logs_id = oci_logging_log.audit_logs.id
      cloud_guard_logs_id = oci_logging_log.cloud_guard_logs.id
    }
    
    notifications = {
      security_alerts_topic_id = oci_ons_notification_topic.security_alerts_topic.id
      critical_alerts_topic_id = oci_ons_notification_topic.critical_alerts_topic.id
    }
    
    apm = {
      enabled = var.enable_apm
      domain_id = var.enable_apm ? oci_apm_apm_domain.secure_apm_domain[0].id : null
    }
  }
}