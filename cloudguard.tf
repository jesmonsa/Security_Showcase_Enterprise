# ===========================================
# ORACLE CLOUD GUARD CONFIGURATION
# ===========================================
# Cloud Guard provides centralized security monitoring and threat detection
# for the entire OCI environment

# Cloud Guard Configuration (Tenancy Level)
resource "oci_cloud_guard_cloud_guard_configuration" "cloud_guard_config" {
  count            = var.enable_cloud_guard ? 1 : 0
  compartment_id   = var.tenancy_ocid
  reporting_region = var.region
  status           = "ENABLED"
}

# Cloud Guard Target (para monitorear el compartment de la demo)
resource "oci_cloud_guard_target" "security_target" {
  count                = var.enable_cloud_guard ? 1 : 0
  compartment_id       = oci_identity_compartment.compartment.id
  display_name         = "SecurityTarget-${var.cliente}"
  target_resource_id   = oci_identity_compartment.compartment.id
  target_resource_type = "COMPARTMENT"

  description = "Cloud Guard target for ${var.cliente} security monitoring and threat detection"

  freeform_tags = merge(local.common_tags, {
    "Service" = "CloudGuard"
    "Purpose" = "SecurityMonitoring"
    "Scope"   = "Compartment"
  })

  depends_on = [
    oci_cloud_guard_cloud_guard_configuration.cloud_guard_config,
    oci_identity_compartment.compartment
  ]
}

# Logging para Cloud Guard (opcional pero recomendado)
resource "oci_logging_log_group" "cloudguard_log_group" {
  count          = var.enable_cloud_guard ? 1 : 0
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "CloudGuardLogs-${var.cliente}"
  description    = "Log group for Cloud Guard security events and alerts"

  freeform_tags = merge(local.common_tags, {
    "Service" = "Logging"
    "Purpose" = "SecurityLogs"
    "Source"  = "CloudGuard"
  })
}

resource "oci_logging_log" "cloudguard_security_log" {
  count        = var.enable_cloud_guard ? 1 : 0
  display_name = "SecurityEvents-${var.cliente}"
  log_group_id = oci_logging_log_group.cloudguard_log_group[0].id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "all"
      resource    = oci_cloud_guard_target.security_target[0].id
      service     = "cloudguard"
      source_type = "OCISERVICE"
    }

    compartment_id = oci_identity_compartment.compartment.id
  }

  is_enabled         = true
  retention_duration = 30

  freeform_tags = merge(local.common_tags, {
    "Service" = "Logging"
    "Purpose" = "SecurityEvents"
    "Source"  = "CloudGuard"
  })

  depends_on = [
    oci_logging_log_group.cloudguard_log_group,
    oci_cloud_guard_target.security_target
  ]
}