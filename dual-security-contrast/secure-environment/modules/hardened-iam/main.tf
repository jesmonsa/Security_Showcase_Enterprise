# ========================================
# MÓDULO IAM ENDURECIDO - "MEJORES PRÁCTICAS"
# Identity and Access Management con principio de menor privilegio
# ========================================

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.21.0"
      configuration_aliases = [oci, oci.home]
    }
  }
}

# Data sources
data "oci_identity_tenancy" "tenancy" {
  provider     = oci.home
  tenancy_id   = var.tenancy_ocid
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Local values para configuración segura
locals {
  compartment_name = "${var.environment}-security-architecture"
  
  # Estructura jerárquica de compartments
  compartment_hierarchy = {
    root = {
      name        = local.compartment_name
      description = "Root compartment for secure architecture - ${var.environment}"
    }
    network = {
      name        = "${var.environment}-network-compartment"
      description = "Network resources with strict access controls"
    }
    compute = {
      name        = "${var.environment}-compute-compartment"
      description = "Compute resources with security hardening"
    }
    database = {
      name        = "${var.environment}-database-compartment"
      description = "Database resources with advanced security"
    }
    security_services = {
      name        = "${var.environment}-security-services-compartment"
      description = "Security services (Vault, WAF, Cloud Guard)"
    }
  }
  
  # Grupos de seguridad con principio de menor privilegio
  security_groups = {
    security_admins = {
      name        = "${var.environment}-security-administrators"
      description = "Security administrators with limited, audited access to security services only"
    }
    security_analysts = {
      name        = "${var.environment}-security-analysts"
      description = "Security analysts with read-only access to security monitoring and logs"
    }
    database_admins = {
      name        = "${var.environment}-database-administrators"
      description = "Database administrators with access limited to database compartment only"
    }
    network_admins = {
      name        = "${var.environment}-network-administrators"
      description = "Network administrators with access limited to network compartment only"
    }
    developers = {
      name        = "${var.environment}-developers"
      description = "Developers with restricted access to development resources only"
    }
    auditors = {
      name        = "${var.environment}-auditors"
      description = "Auditors with read-only access for compliance and security assessment"
    }
  }
}

# ========================================
# COMPARTMENT HIERARCHY - STRUCTURED SEPARATION
# ========================================

# Root compartment para la arquitectura segura
resource "oci_identity_compartment" "security_compartment" {
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = local.compartment_hierarchy.root.name
  description    = local.compartment_hierarchy.root.description
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = local.compartment_hierarchy.root.name
    Type = "secure-root-compartment"
    Security = "COMPREHENSIVE"
    Compliance = "ENABLED"
  })
}

# Network compartment - Aislamiento de red
resource "oci_identity_compartment" "network_compartment" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.security_compartment.id
  name           = local.compartment_hierarchy.network.name
  description    = local.compartment_hierarchy.network.description
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = local.compartment_hierarchy.network.name
    Type = "secure-network-compartment"
    Access = "RESTRICTED"
  })
}

# Compute compartment - Recursos de cómputo
resource "oci_identity_compartment" "compute_compartment" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.security_compartment.id
  name           = local.compartment_hierarchy.compute.name
  description    = local.compartment_hierarchy.compute.description
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = local.compartment_hierarchy.compute.name
    Type = "secure-compute-compartment"
    Hardening = "ENABLED"
  })
}

# Database compartment - Recursos de base de datos
resource "oci_identity_compartment" "database_compartment" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.security_compartment.id
  name           = local.compartment_hierarchy.database.name
  description    = local.compartment_hierarchy.database.description
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = local.compartment_hierarchy.database.name
    Type = "secure-database-compartment"
    DatabaseFirewall = "ENABLED"
    DataSafe = "ENABLED"
  })
}

# Security services compartment - Servicios de seguridad
resource "oci_identity_compartment" "security_services_compartment" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.security_compartment.id
  name           = local.compartment_hierarchy.security_services.name
  description    = local.compartment_hierarchy.security_services.description
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = local.compartment_hierarchy.security_services.name
    Type = "secure-services-compartment"
    Services = "Vault,WAF,CloudGuard"
  })
}

# ========================================
# USER GROUPS - PRINCIPIO DE MENOR PRIVILEGIO
# ========================================

resource "oci_identity_group" "security_groups" {
  for_each   = local.security_groups
  provider   = oci.home
  
  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description    = each.value.description
  
  freeform_tags = merge(var.common_tags, {
    Name = each.value.name
    Type = "secure-group"
    Role = each.key
    Privilege = "LEAST_PRIVILEGE"
  })
}

# ========================================
# DYNAMIC GROUPS - GRANULAR SERVICE ACCESS
# ========================================

# Dynamic group para compute instances - Acceso limitado
resource "oci_identity_dynamic_group" "compute_instances" {
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-secure-compute-instances"
  description    = "Secure compute instances with limited access to required services only"
  
  # Regla específica para el compartment de compute
  matching_rule = "ALL {instance.compartment.id = '${oci_identity_compartment.compute_compartment.id}'}"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-secure-compute-instances"
    Type = "secure-dynamic-group"
    Access = "LIMITED"
  })
}

# Dynamic group para database instances - Acceso específico a Vault
resource "oci_identity_dynamic_group" "database_instances" {
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-secure-database-instances"
  description    = "Secure database instances with access to Vault and logging only"
  
  matching_rule = "ALL {resource.type = 'autonomousdatabase', resource.compartment.id = '${oci_identity_compartment.database_compartment.id}'}"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-secure-database-instances"
    Type = "secure-database-dynamic-group"
    Access = "VAULT_LOGGING_ONLY"
  })
}

# ========================================
# IAM POLICIES - LEAST PRIVILEGE PRINCIPLE
# ========================================

# Security administrators policy - Acceso limitado a servicios de seguridad
resource "oci_identity_policy" "security_admins_policy" {
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-security-admins-policy"
  description    = "Least privilege policy for security administrators"
  
  statements = [
    # Acceso a servicios de seguridad solamente
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage vaults in compartment ${oci_identity_compartment.security_services_compartment.name}",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage keys in compartment ${oci_identity_compartment.security_services_compartment.name}",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage secret-family in compartment ${oci_identity_compartment.security_services_compartment.name}",
    
    # Cloud Guard - Solo en compartment específico
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to use cloud-guard-family in compartment ${local.compartment_name}",
    
    # WAF management
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage waas-family in compartment ${oci_identity_compartment.security_services_compartment.name}",
    
    # Vulnerability scanning
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage vulnerability-scanning-family in compartment ${local.compartment_name}",
    
    # Bastion service
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage bastion-family in compartment ${oci_identity_compartment.network_compartment.name}",
    
    # Read access para auditoria
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to read all-resources in compartment ${local.compartment_name}",
    
    # Logging management
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage logging-family in compartment ${local.compartment_name}"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-security-admins-policy"
    Type = "secure-policy"
    Principle = "LEAST_PRIVILEGE"
  })
}

# Database administrators policy - Solo acceso a database compartment
resource "oci_identity_policy" "database_admins_policy" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.database_compartment.id
  name           = "${var.environment}-database-admins-policy"
  description    = "Database administrators with access limited to database compartment"
  
  statements = [
    # Solo database resources
    "Allow group ${oci_identity_group.security_groups["database_admins"].name} to manage autonomous-database-family in compartment ${oci_identity_compartment.database_compartment.name}",
    "Allow group ${oci_identity_group.security_groups["database_admins"].name} to manage database-family in compartment ${oci_identity_compartment.database_compartment.name}",
    
    # Acceso limitado a keys para database encryption
    "Allow group ${oci_identity_group.security_groups["database_admins"].name} to use keys in compartment ${oci_identity_compartment.security_services_compartment.name}",
    
    # Data Safe access
    "Allow group ${oci_identity_group.security_groups["database_admins"].name} to use data-safe-family in compartment ${oci_identity_compartment.database_compartment.name}",
    
    # Read access to logging for troubleshooting
    "Allow group ${oci_identity_group.security_groups["database_admins"].name} to read logging-family in compartment ${oci_identity_compartment.database_compartment.name}"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-database-admins-policy"
    Type = "secure-database-policy"
    Scope = "DATABASE_COMPARTMENT_ONLY"
  })
}

# Network administrators policy - Solo recursos de red
resource "oci_identity_policy" "network_admins_policy" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.network_compartment.id
  name           = "${var.environment}-network-admins-policy"
  description    = "Network administrators with access limited to network compartment"
  
  statements = [
    # Network resources only
    "Allow group ${oci_identity_group.security_groups["network_admins"].name} to manage virtual-network-family in compartment ${oci_identity_compartment.network_compartment.name}",
    "Allow group ${oci_identity_group.security_groups["network_admins"].name} to manage load-balancers in compartment ${oci_identity_compartment.network_compartment.name}",
    
    # DNS management
    "Allow group ${oci_identity_group.security_groups["network_admins"].name} to manage dns in compartment ${oci_identity_compartment.network_compartment.name}",
    
    # Read access to security services for NSG configuration
    "Allow group ${oci_identity_group.security_groups["network_admins"].name} to read waas-family in compartment ${oci_identity_compartment.security_services_compartment.name}"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-network-admins-policy"
    Type = "secure-network-policy"
    Scope = "NETWORK_COMPARTMENT_ONLY"
  })
}

# Developers policy - Acceso muy limitado
resource "oci_identity_policy" "developers_policy" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.compute_compartment.id
  name           = "${var.environment}-developers-policy"
  description    = "Developers with minimal access to development resources"
  
  statements = [
    # Limited compute access - no manage, only use
    "Allow group ${oci_identity_group.security_groups["developers"].name} to use instances in compartment ${oci_identity_compartment.compute_compartment.name}",
    "Allow group ${oci_identity_group.security_groups["developers"].name} to read instances in compartment ${oci_identity_compartment.compute_compartment.name}",
    
    # Bastion access for SSH (through bastion service only)
    "Allow group ${oci_identity_group.security_groups["developers"].name} to use bastion-family in compartment ${oci_identity_compartment.network_compartment.name}",
    
    # Read-only access to logs for troubleshooting
    "Allow group ${oci_identity_group.security_groups["developers"].name} to read logging-family in compartment ${oci_identity_compartment.compute_compartment.name}",
    
    # No database access - must go through application
    # No network management access
    # No security service access
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-developers-policy"
    Type = "secure-developer-policy"
    Access = "MINIMAL"
  })
}

# Auditors policy - Read-only para compliance
resource "oci_identity_policy" "auditors_policy" {
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-auditors-policy"
  description    = "Auditors with comprehensive read-only access for compliance"
  
  statements = [
    # Comprehensive read-only access para auditorías
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to inspect all-resources in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read audit-events in tenancy",
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read cloud-guard-family in tenancy",
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read policies in tenancy",
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read groups in tenancy",
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read users in tenancy",
    
    # Access to logging for compliance reporting
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read logging-family in compartment ${local.compartment_name}",
    
    # Vulnerability scanning reports
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read vulnerability-scanning-family in compartment ${local.compartment_name}"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-auditors-policy"
    Type = "secure-auditor-policy"
    Access = "READ_ONLY_COMPREHENSIVE"
  })
}

# Dynamic group policies - Minimal required access
resource "oci_identity_policy" "compute_instances_policy" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.compute_compartment.id
  name           = "${var.environment}-compute-instances-policy"
  description    = "Minimal policy for compute instances to access required services"
  
  statements = [
    # Access to Vault para obtener secretos (solo read)
    "Allow dynamic-group ${oci_identity_dynamic_group.compute_instances.name} to use keys in compartment ${oci_identity_compartment.security_services_compartment.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.compute_instances.name} to use secret-family in compartment ${oci_identity_compartment.security_services_compartment.name}",
    
    # Logging para aplicaciones
    "Allow dynamic-group ${oci_identity_dynamic_group.compute_instances.name} to use logging-family in compartment ${oci_identity_compartment.compute_compartment.name}",
    
    # NO access to database - debe ir a través de application layer
    # NO access to network management
    # NO access to other compartments
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-compute-instances-policy"
    Type = "secure-compute-policy"
    Access = "MINIMAL_REQUIRED"
  })
}

resource "oci_identity_policy" "database_instances_policy" {
  provider       = oci.home
  compartment_id = oci_identity_compartment.database_compartment.id
  name           = "${var.environment}-database-instances-policy"
  description    = "Policy for database instances to access Vault and logging"
  
  statements = [
    # Access to Vault para encryption keys
    "Allow dynamic-group ${oci_identity_dynamic_group.database_instances.name} to use keys in compartment ${oci_identity_compartment.security_services_compartment.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.database_instances.name} to use secret-family in compartment ${oci_identity_compartment.security_services_compartment.name}",
    
    # Logging access
    "Allow dynamic-group ${oci_identity_dynamic_group.database_instances.name} to use logging-family in compartment ${oci_identity_compartment.database_compartment.name}",
    
    # Data Safe integration
    "Allow dynamic-group ${oci_identity_dynamic_group.database_instances.name} to use data-safe-family in compartment ${oci_identity_compartment.database_compartment.name}"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-database-instances-policy"
    Type = "secure-database-instances-policy"
    Access = "VAULT_LOGGING_DATASAFE_ONLY"
  })
}

# ========================================
# LOCAL VALUES FOR OUTPUTS
# ========================================

locals {
  security_compartment_ocid = oci_identity_compartment.security_compartment.id
  security_compartment_name = oci_identity_compartment.security_compartment.name
}