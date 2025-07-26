# Dictionary Locals
locals {
  # Flexible shapes configuration
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.E5.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]

  # Shape validation
  is_flexible_apache_shape  = contains(local.compute_flexible_shapes, "VM.Standard.E5.Flex")
  is_flexible_tomcat_shape  = contains(local.compute_flexible_shapes, "VM.Standard.E5.Flex")
  is_flexible_bastion_shape = contains(local.compute_flexible_shapes, "VM.Standard.A1.Flex")

  # Network CIDRs calculation
  vcn_cidr        = "10.${var.octetoB}.0.0/16"
  private_db_cidr = "10.${var.octetoB}.0.0/24"
  public_app_cidr = "10.${var.octetoB}.1.0/24"
  public_lb_cidr  = "10.${var.octetoB}.2.0/24"

  # Resource naming
  compartment_name = "cmp-${var.cliente}"
  bucket_name      = "bkt-shared-${var.cliente}"

  # DNS Labels (max 15 chars) - shortened versions  
  vcn_dns_label = "vcn${substr(var.cliente, 0, min(12, length(var.cliente)))}"
  dns_db_label  = "privdb${substr(var.cliente, 0, min(8, length(var.cliente)))}"
  dns_app_label = "pubapp${substr(var.cliente, 0, min(8, length(var.cliente)))}"
  dns_lb_label  = "publb${substr(var.cliente, 0, min(9, length(var.cliente)))}"

  # Tags configuration
  common_tags = {
    "Environment"  = "production"
    "Project"      = "FSC-${var.cliente}"
    "Architecture" = "Arqu_Referencia_FSC"
    "Terraform"    = "true"
  }

  # Load balancer configuration
  is_flexible_lb = true

  # Database configuration (max 8 chars) - use variables if provided
  db_name     = var.db_name != "" ? var.db_name : "${upper(substr(var.cliente, 0, min(6, length(var.cliente))))}DB"
  db_pdb_name = var.db_pdb_name != "" ? var.db_pdb_name : "${upper(substr(var.cliente, 0, min(5, length(var.cliente))))}PDB"

  # WAF domain configuration - using public IP when WAF is enabled
  waf_domain = var.enable_waf ? "${var.cliente}-${var.waf_domain_suffix}" : "WAF deshabilitado"

  # Certificate name
  certificate_name = "Wildcard-${var.cliente}"

  # Availability Domain selection (always use first AD as specified)
  target_ad = data.oci_identity_availability_domains.ADs.availability_domains[0].name

  # Storage performance mode for DB System
  db_storage_performance = "HIGH_PERFORMANCE"

  # SSL Configuration
  ssl_protocols = ["TLS_V1_2", "TLS_V1_3"]

  # Boot volume encryption setting
  pv_encryption_in_transit = true
}