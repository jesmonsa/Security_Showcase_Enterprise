# ========================================
# COMPREHENSIVE SECURITY ARCHITECTURE
# Oracle Cloud Infrastructure (OCI)
# ========================================

terraform {
  required_version = ">= 1.4.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.21.0"
    }
  }
}

# Provider configuration
provider "oci" {
  alias            = "home"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region          = var.home_region
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region          = var.region
}

# Local values
locals {
  project_name = "comprehensive-security"
  environment  = var.environment
  
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    CreatedBy   = "terraform"
    Purpose     = "security-showcase"
  }
}

# ========================================
# ROOT COMPARTMENT STRUCTURE
# ========================================
module "iam" {
  source = "./modules/iam"
  
  tenancy_ocid = var.tenancy_ocid
  environment  = var.environment
  common_tags  = local.common_tags
  
  # IAM Configuration
  create_compartments     = var.create_compartments
  create_security_groups  = var.create_security_groups
  create_policies        = var.create_policies
  
  providers = {
    oci      = oci
    oci.home = oci.home
  }
}

# ========================================
# SECURE NETWORK INFRASTRUCTURE
# ========================================
module "network" {
  source = "./modules/network"
  
  compartment_ocid = module.iam.security_compartment_ocid
  environment     = var.environment
  common_tags     = local.common_tags
  
  # Network Configuration
  vcn_cidr_block = var.vcn_cidr_block
  enable_flow_logs = var.enable_flow_logs
  
  depends_on = [module.iam]
}

# ========================================
# VAULT AND KEY MANAGEMENT SERVICE
# ========================================
module "vault_kms" {
  source = "./modules/vault-kms"
  
  compartment_ocid = module.iam.security_compartment_ocid
  environment     = var.environment
  common_tags     = local.common_tags
  
  # Vault Configuration
  vault_display_name = "${local.project_name}-${local.environment}-vault"
  create_master_key  = var.create_master_key
  
  depends_on = [module.iam]
}

# ========================================
# COMPUTE WITH SECURITY HARDENING
# ========================================
module "compute" {
  source = "./modules/compute"
  
  compartment_ocid = module.iam.security_compartment_ocid
  vcn_id          = module.network.vcn_id
  subnet_ids      = module.network.private_subnet_ids
  security_group_ids = module.network.security_group_ids
  
  environment = var.environment
  common_tags = local.common_tags
  
  # Compute Configuration
  instance_shape     = var.instance_shape
  instance_count     = var.instance_count
  enable_os_hardening = var.enable_os_hardening
  
  # Encryption
  kms_key_id = module.vault_kms.master_key_id
  
  depends_on = [module.network, module.vault_kms]
}

# ========================================
# AUTONOMOUS DATABASE WITH DATA SAFE
# ========================================
module "database" {
  count  = var.enable_database ? 1 : 0
  source = "./modules/database"
  
  compartment_ocid = module.iam.security_compartment_ocid
  subnet_id       = module.network.database_subnet_id
  
  environment = var.environment
  common_tags = local.common_tags
  
  # Database Configuration
  db_display_name     = "${local.project_name}-${local.environment}-adb"
  enable_data_safe    = var.enable_data_safe
  enable_vault_integration = var.enable_vault_integration
  
  # Encryption
  vault_id   = module.vault_kms.vault_id
  kms_key_id = module.vault_kms.master_key_id
  
  depends_on = [module.network, module.vault_kms]
}

# ========================================
# WEB APPLICATION FIREWALL
# ========================================
module "waf" {
  count  = var.enable_waf ? 1 : 0
  source = "./modules/waf"
  
  compartment_ocid = module.iam.security_compartment_ocid
  environment     = var.environment
  common_tags     = local.common_tags
  
  # WAF Configuration
  waf_display_name = "${local.project_name}-${local.environment}-waf"
  domain_names     = var.waf_domain_names
  origin_servers   = var.waf_origin_servers
  
  depends_on = [module.compute]
}

# ========================================
# CLOUD GUARD FOR SECURITY MONITORING
# ========================================
module "monitoring" {
  source = "./modules/monitoring"
  
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = module.iam.security_compartment_ocid
  
  environment = var.environment
  common_tags = local.common_tags
  
  # Cloud Guard Configuration
  enable_cloud_guard = var.enable_cloud_guard
  cloud_guard_target_resource_id = module.iam.security_compartment_ocid
  
  # Logging Configuration
  enable_audit_logging = var.enable_audit_logging
  log_retention_duration = var.log_retention_duration
  
  providers = {
    oci      = oci
    oci.home = oci.home
  }
  
  depends_on = [module.iam, module.network, module.compute]
}

# ========================================
# SECURITY ZONES
# ========================================
module "security_zones" {
  count  = var.enable_security_zones ? 1 : 0
  source = "./modules/security-zones"
  
  compartment_ocid = module.iam.security_compartment_ocid
  environment     = var.environment
  common_tags     = local.common_tags
  
  # Security Zone Configuration
  security_zone_display_name = "${local.project_name}-${local.environment}-sz"
  security_zone_recipe_id    = var.security_zone_recipe_id
  
  depends_on = [module.iam]
}