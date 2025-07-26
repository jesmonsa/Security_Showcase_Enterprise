# ========================================
# MÓDULO IAM INSEGURO - "QUÉ NO HACER"
# Deliberadamente con malas prácticas
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
# COMPARTMENT STRUCTURE - SIN SEPARACIÓN
# ========================================

# Un solo compartment para TODO (mala práctica)
resource "oci_identity_compartment" "vulnerable_everything" {
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-everything-mixed"
  description    = "Single compartment for all resources - INSECURE DESIGN"
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-everything-mixed"
    Type = "insecure-compartment"
    Security = "NONE"
    Warning = "MIXED_RESOURCES_INSECURE"
  })
}

# ========================================
# USER GROUPS - EXCESIVOS PERMISOS
# ========================================

# Grupo con permisos de administrador para TODOS
resource "oci_identity_group" "everyone_admin" {
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-everyone-admin"
  description    = "Everyone gets admin access - WORST PRACTICE"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-everyone-admin"
    Type = "insecure-group"
    Permissions = "EXCESSIVE"
  })
}

# Grupo de desarrolladores con acceso root
resource "oci_identity_group" "developers_with_root" {
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-devs-root-access"
  description    = "Developers with root access - DANGEROUS"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-devs-root-access"
    Type = "insecure-group"
    Risk = "HIGH"
  })
}

# ========================================
# DYNAMIC GROUPS - PERMISOS AMPLIOS
# ========================================

# Dynamic group con acceso a TODO
resource "oci_identity_dynamic_group" "instances_all_access" {
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-instances-all-access"
  description    = "Compute instances with access to everything"
  
  # Regla muy amplia - INSEGURA
  matching_rule = "ALL {instance.compartment.id = '${oci_identity_compartment.vulnerable_everything.id}'}"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-instances-all-access"
    Type = "insecure-dynamic-group"
    Scope = "TOO_BROAD"
  })
}

# ========================================
# POLÍTICAS - EXCESIVAMENTE PERMISIVAS
# ========================================

# Política que da acceso total a todos
resource "oci_identity_policy" "everyone_admin_policy" {
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-everyone-admin-policy"
  description    = "Admin access for everyone - EXTREMELY DANGEROUS"
  
  statements = [
    # PELIGROSO: Acceso completo a TODO
    "Allow group ${oci_identity_group.everyone_admin.name} to manage all-resources in tenancy",
    "Allow group ${oci_identity_group.everyone_admin.name} to manage policies in tenancy",
    "Allow group ${oci_identity_group.everyone_admin.name} to manage groups in tenancy",
    "Allow group ${oci_identity_group.everyone_admin.name} to manage users in tenancy",
    "Allow group ${oci_identity_group.everyone_admin.name} to manage compartments in tenancy",
    "Allow group ${oci_identity_group.everyone_admin.name} to manage domains in tenancy",
    
    # INSEGURO: Desarrolladores con permisos root
    "Allow group ${oci_identity_group.developers_with_root.name} to manage all-resources in tenancy",
    "Allow group ${oci_identity_group.developers_with_root.name} to read audit-events in tenancy",
    "Allow group ${oci_identity_group.developers_with_root.name} to manage policies in tenancy"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-everyone-admin-policy"
    Type = "insecure-policy"
    Risk = "CRITICAL"
  })
}

# Política para dynamic groups - muy permisiva
resource "oci_identity_policy" "instances_excessive_policy" {
  compartment_id = oci_identity_compartment.vulnerable_everything.id
  name           = "${var.environment}-instances-excessive-policy"
  description    = "Excessive permissions for compute instances"
  
  statements = [
    # PELIGROSO: Instancias pueden hacer de todo
    "Allow dynamic-group ${oci_identity_dynamic_group.instances_all_access.name} to manage all-resources in compartment ${oci_identity_compartment.vulnerable_everything.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.instances_all_access.name} to read users in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.instances_all_access.name} to read groups in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.instances_all_access.name} to manage policies in compartment ${oci_identity_compartment.vulnerable_everything.name}",
    
    # INSEGURO: Acceso a otros compartments
    "Allow dynamic-group ${oci_identity_dynamic_group.instances_all_access.name} to inspect all-resources in tenancy"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-instances-excessive-policy"
    Type = "insecure-policy"
    Scope = "TOO_BROAD"
  })
}

# ========================================
# CREDENTIAL MANAGEMENT - INSEGURO
# ========================================

# API Key con permisos excesivos (simulado con grupo)
resource "oci_identity_group" "service_accounts_admin" {
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-service-accounts-admin"
  description    = "Service accounts with admin access - BAD PRACTICE"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-service-accounts-admin"
    Type = "service-account-group"
    Security = "NONE"
  })
}

# Política para service accounts - sin rotación ni restricciones
resource "oci_identity_policy" "service_accounts_policy" {
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-service-accounts-policy"
  description    = "Service accounts without rotation or restrictions"
  
  statements = [
    "Allow group ${oci_identity_group.service_accounts_admin.name} to manage all-resources in tenancy",
    # Sin restricciones de IP, tiempo, o MFA
    "Allow group ${oci_identity_group.service_accounts_admin.name} to use cloud-shell in tenancy"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-service-accounts-policy"
    Type = "insecure-service-policy"
    Rotation = "NEVER"
  })
}

# ========================================
# OUTPUTS PARA OTROS MÓDULOS
# ========================================

# Compartment único para todos los recursos
output "root_compartment_ocid" {
  description = "OCID of the single compartment for all resources (INSECURE)"
  value       = oci_identity_compartment.vulnerable_everything.id
}

output "vulnerable_compartment_name" {
  description = "Name of the vulnerable compartment"
  value       = oci_identity_compartment.vulnerable_everything.name
}

# Grupos con permisos excesivos
output "insecure_groups" {
  description = "Groups with excessive permissions"
  value = {
    everyone_admin = {
      id   = oci_identity_group.everyone_admin.id
      name = oci_identity_group.everyone_admin.name
    }
    developers_with_root = {
      id   = oci_identity_group.developers_with_root.id
      name = oci_identity_group.developers_with_root.name
    }
    service_accounts_admin = {
      id   = oci_identity_group.service_accounts_admin.id
      name = oci_identity_group.service_accounts_admin.name
    }
  }
}

# Dynamic groups inseguros
output "insecure_dynamic_groups" {
  description = "Dynamic groups with excessive permissions"
  value = {
    instances_all_access = {
      id   = oci_identity_dynamic_group.instances_all_access.id
      name = oci_identity_dynamic_group.instances_all_access.name
    }
  }
}

# Resumen de vulnerabilidades IAM
output "iam_vulnerabilities_summary" {
  description = "Summary of IAM vulnerabilities in this environment"
  value = {
    compartment_separation = "NONE - Single compartment for all resources"
    permission_model = "EXCESSIVE - Everyone has admin access"
    service_accounts = "UNMANAGED - No rotation, excessive permissions"
    dynamic_groups = "TOO_BROAD - Access to all resources"
    policies = "PERMISSIVE - No principle of least privilege"
    mfa_enforcement = "DISABLED - No MFA requirements"
    credential_rotation = "NEVER - Static credentials"
    audit_trail = "MINIMAL - Basic logging only"
    
    risk_level = "CRITICAL"
    compliance_status = "NON_COMPLIANT"
    remediation_priority = "IMMEDIATE"
  }
}