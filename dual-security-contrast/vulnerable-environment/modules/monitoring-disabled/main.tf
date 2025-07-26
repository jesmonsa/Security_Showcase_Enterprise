# ========================================
# MÓDULO MONITORING DESHABILITADO - "QUÉ NO HACER"
# Sin observabilidad ni monitoreo de seguridad
# ========================================

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.21.0"
    }
  }
}

# ========================================
# CLOUD GUARD - DELIBERADAMENTE DESHABILITADO
# ========================================
# Nota: Cloud Guard se habilita a nivel de tenancy y requiere permisos especiales
# Aquí documentamos que intencionalmente NO se habilita

locals {
  cloud_guard_status = "DISABLED - No security monitoring active"
  
  # Documentar qué NO se está monitoreando
  missing_detections = [
    "Suspicious network activity",
    "Unauthorized API calls", 
    "Privilege escalation attempts",
    "Data exfiltration patterns",
    "Malware installation",
    "Configuration drift",
    "Compliance violations",
    "Insider threats"
  ]
}

# ========================================
# AUDIT LOGGING - MÍNIMO REQUERIDO
# ========================================
# Solo el logging básico requerido por OCI, sin configuración adicional

# Log Group básico (mínimo requerido)
resource "oci_logging_log_group" "minimal_log_group" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.environment}-minimal-logging"
  description    = "Minimal logging for vulnerable environment - NO security monitoring"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-minimal-logging"
    Type = "minimal-log-group"
    Security = "NONE"
    Monitoring = "DISABLED"
  })
}

# INSEGURO: Log básico sin retención extendida
resource "oci_logging_log" "basic_audit_log" {
  display_name = "${var.environment}-basic-audit-log"
  log_group_id = oci_logging_log_group.minimal_log_group.id
  log_type     = "SERVICE"
  
  # INSEGURO: Retención mínima
  retention_duration = 30  # Solo 30 días
  
  configuration {
    source {
      category    = "all"
      resource    = var.compartment_ocid
      service     = "audit"
      source_type = "OCISERVICE"
    }
    
    compartment_id = var.compartment_ocid
  }
  
  # INSEGURO: Sin archiving para retención a largo plazo
  is_enabled = true
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-basic-audit-log"
    Type = "minimal-audit-log"
    Retention = "SHORT"
    Security = "BASIC"
  })
}

# ========================================
# SIN FLOW LOGS - SIN VISIBILIDAD DE RED
# ========================================
# Intencionalmente NO se configuran VCN Flow Logs para mostrar
# la falta de visibilidad del tráfico de red

# ========================================
# SIN VULNERABILITY SCANNING SERVICE
# ========================================
# Intencionalmente NO se configura Vulnerability Scanning
# para mostrar la falta de detección de vulnerabilidades

# ========================================
# SIN SECURITY CENTER INTEGRATION
# ========================================
# Intencionalmente NO se integra con Security Center
# para mostrar la falta de visibilidad centralizada

# ========================================
# SIN SIEM INTEGRATION
# ========================================
# Intencionalmente NO se configura forwarding a SIEM
# para mostrar la falta de correlación de eventos

# ========================================
# NOTIFICATION TOPICS - MÍNIMOS
# ========================================

# Topic básico para notificaciones críticas del sistema (no de seguridad)
resource "oci_ons_notification_topic" "basic_notifications" {
  compartment_id = var.compartment_ocid
  name          = "${var.environment}-basic-notifications"
  description   = "Basic system notifications - NO security alerts"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-basic-notifications"
    Type = "basic-notifications"
    Security = "NOT_CONFIGURED"
  })
}

# INSEGURO: Sin suscripciones para alertas de seguridad
# Solo notificaciones básicas del sistema, sin alertas críticas

# ========================================
# ALARMS - SIN CONFIGURACIÓN DE SEGURIDAD
# ========================================

# INSEGURO: Solo alarm básico de disponibilidad, sin métricas de seguridad
resource "oci_monitoring_alarm" "basic_availability_alarm" {
  compartment_id        = var.compartment_ocid
  destinations          = [oci_ons_notification_topic.basic_notifications.id]
  display_name         = "${var.environment}-basic-availability"
  is_enabled           = true
  metric_compartment_id = var.compartment_ocid
  namespace            = "oci_computeagent"
  
  # INSEGURO: Solo métrica básica de CPU, sin métricas de seguridad
  query = "CpuUtilization[1m].mean() > 90"
  
  severity = "INFO"  # INSEGURO: Solo INFO, sin alertas CRITICAL
  
  # INSEGURO: Sin suppression para eventos de seguridad
  repeat_notification_duration = "PT2H"  # 2 horas - muy lento para seguridad
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-basic-availability"
    Type = "basic-alarm"
    Security = "NOT_CONFIGURED"
  })
}

# ========================================
# SIN SERVICE CONNECTOR HUB
# ========================================
# Intencionalmente NO se configura Service Connector Hub
# para mostrar la falta de integración y automatización

# ========================================
# SIN EVENTS SERVICE RULES
# ========================================
# Intencionalmente NO se configuran reglas de Events Service
# para respuesta automática a incidentes de seguridad

# ========================================
# OUTPUTS - DOCUMENTAR LO QUE FALTA
# ========================================

output "monitoring_status" {
  description = "Status of monitoring services (mostly disabled)"
  value = {
    cloud_guard = "DISABLED - No security monitoring"
    vulnerability_scanning = "DISABLED - No vulnerability detection"
    flow_logs = "DISABLED - No network traffic visibility"
    security_center = "NOT_INTEGRATED - No centralized security view"
    siem_integration = "NONE - No external SIEM forwarding"
    
    basic_logging = {
      log_group_id = oci_logging_log_group.minimal_log_group.id
      retention_days = 30
      archiving = "DISABLED"
    }
    
    notifications = {
      topic_id = oci_ons_notification_topic.basic_notifications.id
      security_subscriptions = "NONE"
      critical_alerts = "DISABLED"
    }
    
    alarms = {
      security_alarms = "NONE - No security metrics monitored"
      availability_only = oci_monitoring_alarm.basic_availability_alarm.id
      response_time = "2 hours - Too slow for security incidents"
    }
  }
}

output "log_groups" {
  description = "Basic log groups (minimal configuration)"
  value = {
    minimal_log_group = {
      id = oci_logging_log_group.minimal_log_group.id
      name = oci_logging_log_group.minimal_log_group.display_name
    }
  }
}

output "notification_topics" {
  description = "Basic notification topic (no security alerts)"
  value = {
    basic_notifications = {
      id = oci_ons_notification_topic.basic_notifications.id
      name = oci_ons_notification_topic.basic_notifications.name
    }
  }
}

# Resumen de vulnerabilidades de monitoreo
output "monitoring_vulnerabilities_summary" {
  description = "Summary of monitoring and detection vulnerabilities"
  value = {
    detection_capabilities = {
      cloud_guard = "DISABLED - No automated threat detection"
      vulnerability_scanning = "DISABLED - No regular security assessments"
      configuration_monitoring = "DISABLED - No drift detection"
      network_monitoring = "DISABLED - No flow logs or traffic analysis"
    }
    
    incident_response = {
      automated_response = "NONE - No automatic remediation"
      alert_escalation = "BASIC - Only system availability alerts"
      incident_tracking = "NONE - No security incident management"
      forensics_capability = "NONE - No detailed audit trails"
    }
    
    compliance_monitoring = {
      continuous_compliance = "DISABLED - No compliance scanning"
      policy_enforcement = "NONE - No automated policy checks"
      audit_trail = "BASIC - Minimal audit logging only"
      reporting = "NONE - No compliance reports generated"
    }
    
    visibility_gaps = {
      network_traffic = "BLIND - No flow logs or network monitoring"
      application_security = "NONE - No application-level monitoring"
      database_activity = "MINIMAL - Basic audit only"
      user_behavior = "NONE - No user activity analysis"
      api_usage = "BASIC - Only basic API audit logs"
    }
    
    siem_integration = {
      log_forwarding = "DISABLED - No external SIEM integration"
      event_correlation = "NONE - No cross-service event analysis"
      threat_intelligence = "NONE - No external threat feeds"
      security_orchestration = "NONE - No SOAR integration"
    }
    
    detection_time = {
      security_incidents = "287 days average - No proactive detection"
      data_breaches = "Unknown - May never be detected"
      insider_threats = "Unknown - No user behavior monitoring"
      configuration_drift = "Unknown - No baseline monitoring"
    }
    
    business_impact = {
      mean_time_to_detection = "287 days (industry average without monitoring)"
      mean_time_to_response = "Unknown - No automated alerting"
      compliance_risk = "HIGH - Unable to demonstrate continuous monitoring"
      audit_findings = "EXPECTED - Insufficient logging and monitoring"
    }
    
    remediation_priority = "CRITICAL"
    risk_multiplier = "10x - Blind to all security events"
  }
}

# Documentación de lo que debería estar configurado
output "missing_security_controls" {
  description = "Security monitoring controls that should be implemented"
  value = {
    immediate_needs = [
      "Enable Cloud Guard for automated threat detection",
      "Configure VCN Flow Logs for network visibility", 
      "Enable Vulnerability Scanning Service",
      "Set up security-focused alarms and notifications",
      "Configure Service Connector Hub for log aggregation",
      "Implement SIEM integration for external monitoring"
    ]
    
    advanced_capabilities = [
      "Security Center integration for centralized view",
      "Custom detector recipes for specific threats",
      "Automated incident response workflows",
      "Compliance monitoring and reporting",
      "User and Entity Behavior Analytics (UEBA)",
      "Threat intelligence integration"
    ]
    
    compliance_requirements = [
      "Extended audit log retention (7+ years for some regulations)",
      "Immutable audit trails", 
      "Real-time security monitoring",
      "Incident response documentation",
      "Regular security assessments",
      "Continuous compliance monitoring"
    ]
  }
}