# ========================================
# IAM MODULE - COMPREHENSIVE SECURITY
# Identity and Access Management
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

data "oci_identity_compartments" "root" {
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "root"
}

# Local values
locals {
  compartment_name = "${var.environment}-security-compartment"
  
  # Security groups to create
  security_groups = var.create_security_groups ? {
    security_admins = {
      name        = "${var.environment}-security-admins"
      description = "Security administrators with full security service access"
    }
    security_analysts = {
      name        = "${var.environment}-security-analysts"
      description = "Security analysts with read-only access to security services"
    }
    developers = {
      name        = "${var.environment}-developers"
      description = "Developers with limited access to development resources"
    }
    auditors = {
      name        = "${var.environment}-auditors"
      description = "Auditors with read-only access for compliance reporting"
    }
  } : {}
}

# ========================================
# COMPARTMENT STRUCTURE
# ========================================

# Main security compartment
resource "oci_identity_compartment" "security_compartment" {
  count          = var.create_compartments ? 1 : 0
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = local.compartment_name
  description    = "Compartment for comprehensive security architecture - ${var.environment}"
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = local.compartment_name
    Type = "security-compartment"
  })
}

# Sub-compartments for resource organization
resource "oci_identity_compartment" "network_compartment" {
  count          = var.create_compartments ? 1 : 0
  provider       = oci.home
  compartment_id = oci_identity_compartment.security_compartment[0].id
  name           = "${var.environment}-network"
  description    = "Network resources compartment"
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-network"
    Type = "network-compartment"
  })
}

resource "oci_identity_compartment" "compute_compartment" {
  count          = var.create_compartments ? 1 : 0
  provider       = oci.home
  compartment_id = oci_identity_compartment.security_compartment[0].id
  name           = "${var.environment}-compute"
  description    = "Compute resources compartment"
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-compute"
    Type = "compute-compartment"
  })
}

resource "oci_identity_compartment" "database_compartment" {
  count          = var.create_compartments ? 1 : 0
  provider       = oci.home
  compartment_id = oci_identity_compartment.security_compartment[0].id
  name           = "${var.environment}-database"
  description    = "Database resources compartment"
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-database"
    Type = "database-compartment"
  })
}

resource "oci_identity_compartment" "security_services_compartment" {
  count          = var.create_compartments ? 1 : 0
  provider       = oci.home
  compartment_id = oci_identity_compartment.security_compartment[0].id
  name           = "${var.environment}-security-services"
  description    = "Security services compartment (Vault, WAF, etc.)"
  
  enable_delete = true
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-security-services"
    Type = "security-services-compartment"
  })
}

# ========================================
# USER GROUPS
# ========================================

resource "oci_identity_group" "security_groups" {
  for_each   = local.security_groups
  provider   = oci.home
  
  compartment_id = var.tenancy_ocid
  name           = each.value.name
  description    = each.value.description
  
  freeform_tags = merge(var.common_tags, {
    Name = each.value.name
    Type = "security-group"
    Role = each.key
  })
}

# ========================================
# DYNAMIC GROUPS FOR SERVICES
# ========================================

# Dynamic group for compute instances
resource "oci_identity_dynamic_group" "compute_instances" {
  count          = var.create_security_groups ? 1 : 0
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-compute-instances"
  description    = "Dynamic group for compute instances in security architecture"
  
  matching_rule = "All {instance.compartment.id = '${local.security_compartment_ocid}'}"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-compute-instances"
    Type = "dynamic-group"
  })
}

# Dynamic group for database instances
resource "oci_identity_dynamic_group" "database_instances" {
  count          = var.create_security_groups ? 1 : 0
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-database-instances"
  description    = "Dynamic group for database instances"
  
  matching_rule = "All {resource.type = 'autonomousdatabase', resource.compartment.id = '${local.security_compartment_ocid}'}"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-database-instances"
    Type = "dynamic-group"
  })
}

# ========================================
# IAM POLICIES
# ========================================

# Security administrators policy
resource "oci_identity_policy" "security_admins_policy" {
  count          = var.create_policies && var.create_security_groups ? 1 : 0
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-security-admins-policy"
  description    = "Policy for security administrators"
  
  statements = [
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage all-resources in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage policies in tenancy",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage groups in tenancy",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage dynamic-groups in tenancy",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to use cloud-guard-family in tenancy",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage vaults in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage keys in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage secret-family in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage bastion-family in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["security_admins"].name} to manage vulnerability-scanning-family in compartment ${local.compartment_name}"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-security-admins-policy"
    Type = "iam-policy"
  })
}

# Security analysts policy (read-only)
resource "oci_identity_policy" "security_analysts_policy" {
  count          = var.create_policies && var.create_security_groups ? 1 : 0
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-security-analysts-policy"
  description    = "Policy for security analysts (read-only access)"
  
  statements = [
    "Allow group ${oci_identity_group.security_groups["security_analysts"].name} to read all-resources in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["security_analysts"].name} to read cloud-guard-family in tenancy",
    "Allow group ${oci_identity_group.security_groups["security_analysts"].name} to read audit-events in tenancy",
    "Allow group ${oci_identity_group.security_groups["security_analysts"].name} to read vaults in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["security_analysts"].name} to read vulnerability-scanning-family in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["security_analysts"].name} to read logging-family in compartment ${local.compartment_name}"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-security-analysts-policy"
    Type = "iam-policy"
  })
}

# Developers policy (limited access)
resource "oci_identity_policy" "developers_policy" {
  count          = var.create_policies && var.create_security_groups ? 1 : 0
  provider       = oci.home
  compartment_id = local.security_compartment_ocid
  name           = "${var.environment}-developers-policy"
  description    = "Policy for developers (limited access to development resources)"
  
  statements = [
    "Allow group ${oci_identity_group.security_groups["developers"].name} to manage instances in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["developers"].name} to use virtual-network-family in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["developers"].name} to read autonomous-database-family in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["developers"].name} to use bastion-family in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["developers"].name} to read logging-family in compartment ${local.compartment_name}"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-developers-policy"
    Type = "iam-policy"
  })
}

# Auditors policy (read-only for compliance)
resource "oci_identity_policy" "auditors_policy" {
  count          = var.create_policies && var.create_security_groups ? 1 : 0
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "${var.environment}-auditors-policy"
  description    = "Policy for auditors (read-only access for compliance)"
  
  statements = [
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to inspect all-resources in compartment ${local.compartment_name}",
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read audit-events in tenancy",
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read cloud-guard-family in tenancy",
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read policies in tenancy",
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read groups in tenancy",
    "Allow group ${oci_identity_group.security_groups["auditors"].name} to read users in tenancy"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-auditors-policy"
    Type = "iam-policy"
  })
}

# Dynamic group policies for services
resource "oci_identity_policy" "compute_instances_policy" {
  count          = var.create_policies && var.create_security_groups ? 1 : 0
  provider       = oci.home
  compartment_id = local.security_compartment_ocid
  name           = "${var.environment}-compute-instances-policy"
  description    = "Policy for compute instances to access required services"
  
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.compute_instances[0].name} to use keys in compartment ${local.compartment_name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.compute_instances[0].name} to use secret-family in compartment ${local.compartment_name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.compute_instances[0].name} to read autonomous-database-family in compartment ${local.compartment_name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.compute_instances[0].name} to use logging-family in compartment ${local.compartment_name}"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-compute-instances-policy"
    Type = "iam-policy"
  })
}

resource "oci_identity_policy" "database_instances_policy" {
  count          = var.create_policies && var.create_security_groups ? 1 : 0
  provider       = oci.home
  compartment_id = local.security_compartment_ocid
  name           = "${var.environment}-database-instances-policy"
  description    = "Policy for database instances to access Vault and other services"
  
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.database_instances[0].name} to use keys in compartment ${local.compartment_name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.database_instances[0].name} to use secret-family in compartment ${local.compartment_name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.database_instances[0].name} to use logging-family in compartment ${local.compartment_name}"
  ]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-database-instances-policy"
    Type = "iam-policy"
  })
}

# ========================================
# LOCAL VALUES FOR OUTPUTS
# ========================================

locals {
  security_compartment_ocid = var.create_compartments ? oci_identity_compartment.security_compartment[0].id : var.tenancy_ocid
  security_compartment_name = var.create_compartments ? oci_identity_compartment.security_compartment[0].name : "root"
}