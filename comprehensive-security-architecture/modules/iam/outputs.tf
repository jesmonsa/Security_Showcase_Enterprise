# ========================================
# IAM MODULE - OUTPUTS
# ========================================

output "security_compartment_ocid" {
  description = "OCID of the main security compartment"
  value       = local.security_compartment_ocid
}

output "security_compartment_name" {
  description = "Name of the main security compartment"
  value       = local.security_compartment_name
}

output "network_compartment_ocid" {
  description = "OCID of the network compartment"
  value       = var.create_compartments ? oci_identity_compartment.network_compartment[0].id : local.security_compartment_ocid
}

output "compute_compartment_ocid" {
  description = "OCID of the compute compartment"
  value       = var.create_compartments ? oci_identity_compartment.compute_compartment[0].id : local.security_compartment_ocid
}

output "database_compartment_ocid" {
  description = "OCID of the database compartment"
  value       = var.create_compartments ? oci_identity_compartment.database_compartment[0].id : local.security_compartment_ocid
}

output "security_services_compartment_ocid" {
  description = "OCID of the security services compartment"
  value       = var.create_compartments ? oci_identity_compartment.security_services_compartment[0].id : local.security_compartment_ocid
}

output "user_groups" {
  description = "Map of created user groups"
  value = var.create_security_groups ? {
    for key, group in oci_identity_group.security_groups : key => {
      id   = group.id
      name = group.name
    }
  } : {}
}

output "dynamic_groups" {
  description = "Map of created dynamic groups"
  value = var.create_security_groups ? {
    compute_instances = {
      id   = oci_identity_dynamic_group.compute_instances[0].id
      name = oci_identity_dynamic_group.compute_instances[0].name
    }
    database_instances = {
      id   = oci_identity_dynamic_group.database_instances[0].id
      name = oci_identity_dynamic_group.database_instances[0].name
    }
  } : {}
}

output "policies" {
  description = "Map of created policies"
  value = var.create_policies && var.create_security_groups ? {
    security_admins_policy   = oci_identity_policy.security_admins_policy[0].id
    security_analysts_policy = oci_identity_policy.security_analysts_policy[0].id
    developers_policy       = oci_identity_policy.developers_policy[0].id
    auditors_policy         = oci_identity_policy.auditors_policy[0].id
    compute_instances_policy = oci_identity_policy.compute_instances_policy[0].id
    database_instances_policy = oci_identity_policy.database_instances_policy[0].id
  } : {}
}

output "compartment_structure" {
  description = "Complete compartment structure"
  value = {
    main_compartment = {
      ocid = local.security_compartment_ocid
      name = local.security_compartment_name
    }
    sub_compartments = var.create_compartments ? {
      network = {
        ocid = oci_identity_compartment.network_compartment[0].id
        name = oci_identity_compartment.network_compartment[0].name
      }
      compute = {
        ocid = oci_identity_compartment.compute_compartment[0].id
        name = oci_identity_compartment.compute_compartment[0].name
      }
      database = {
        ocid = oci_identity_compartment.database_compartment[0].id
        name = oci_identity_compartment.database_compartment[0].name
      }
      security_services = {
        ocid = oci_identity_compartment.security_services_compartment[0].id
        name = oci_identity_compartment.security_services_compartment[0].name
      }
    } : {}
  }
}