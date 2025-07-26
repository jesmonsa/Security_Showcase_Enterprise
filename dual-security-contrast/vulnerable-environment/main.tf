# ========================================
# AMBIENTE VULNERABLE - "QUÉ NO HACER"
# Deliberadamente inseguro para demostración
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

# Provider configuration - Sin mejores prácticas
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region          = var.region
}

# Local values
locals {
  project_name = "vulnerable-security-demo"
  environment  = var.environment
  
  # Tags básicos sin información de seguridad
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    Purpose     = "vulnerability-demonstration"
    Warning     = "DELIBERATELY_INSECURE"
  }
}

# ========================================
# IAM INSEGURO - Permisos excesivos
# ========================================
module "insecure_iam" {
  source = "./modules/insecure-iam"
  
  tenancy_ocid = var.tenancy_ocid
  environment  = var.environment
  common_tags  = local.common_tags
  
  # Configuración intencionalmente insegura
  create_admin_for_everyone = true
  skip_compartment_separation = true
  allow_root_access = true
}

# ========================================
# RED EXPUESTA - Sin protecciones
# ========================================
module "exposed_network" {
  source = "./modules/exposed-network"
  
  compartment_ocid = module.insecure_iam.root_compartment_ocid
  environment     = var.environment
  common_tags     = local.common_tags
  
  # Red completamente abierta
  vcn_cidr_block = var.vcn_cidr_block
  allow_all_traffic = true
  disable_waf = true
  public_database_access = true
  
  depends_on = [module.insecure_iam]
}

# ========================================
# COMPUTE DESPROTEGIDO - Sin hardening
# ========================================
module "unprotected_compute" {
  source = "./modules/unprotected-compute"
  
  compartment_ocid = module.insecure_iam.root_compartment_ocid
  vcn_id          = module.exposed_network.vcn_id
  subnet_id       = module.exposed_network.public_subnet_id
  
  environment = var.environment
  common_tags = local.common_tags
  
  # Configuración insegura
  instance_shape = var.instance_shape
  instance_count = var.instance_count
  disable_os_hardening = true
  enable_password_auth = true
  install_vulnerable_apps = true
  skip_vulnerability_scanning = true
  
  depends_on = [module.exposed_network]
}

# ========================================
# BASE DE DATOS VULNERABLE - Oracle 23ai SIN protecciones
# ========================================
module "vulnerable_database" {
  source = "./modules/vulnerable-database"
  
  compartment_ocid = module.insecure_iam.root_compartment_ocid
  subnet_id       = module.exposed_network.public_subnet_id  # En subnet PÚBLICA
  
  environment = var.environment
  common_tags = local.common_tags
  
  # Oracle 23ai configuración INSEGURA
  db_version = "23ai"
  db_name    = "VULNDB23"
  disable_database_firewall = true      # SIN Database Firewall
  disable_data_safe = true             # SIN Data Safe
  use_weak_passwords = true            # Passwords débiles
  disable_encryption = true            # SIN cifrado
  allow_public_access = true           # Acceso público
  skip_backup_encryption = true        # Backups sin cifrar
  disable_audit_logging = true         # SIN auditoría
  
  depends_on = [module.exposed_network]
}

# ========================================
# APLICACIÓN WEB VULNERABLE - Con vulnerabilidades OWASP
# ========================================
module "vulnerable_application" {
  source = "./modules/vulnerable-application"
  
  compartment_ocid     = module.insecure_iam.root_compartment_ocid
  compute_instance_ids = module.unprotected_compute.instance_ids
  instance_public_ips  = module.unprotected_compute.instance_public_ips
  database_connection  = module.vulnerable_database.connection_string
  
  environment = var.environment
  common_tags = local.common_tags
  
  # Aplicación con vulnerabilidades intencionadas
  enable_sql_injection = true
  enable_xss_vulnerabilities = true
  enable_path_traversal = true
  hardcode_secrets = true
  disable_input_validation = true
  enable_verbose_errors = true
  disable_https_enforcement = true
  
  depends_on = [module.unprotected_compute, module.vulnerable_database]
}

# ========================================
# MONITOREO DESHABILITADO - Sin observabilidad
# ========================================
module "monitoring_disabled" {
  source = "./modules/monitoring-disabled"
  
  compartment_ocid = module.insecure_iam.root_compartment_ocid
  environment     = var.environment
  common_tags     = local.common_tags
  
  # Monitoreo mínimo o deshabilitado
  disable_cloud_guard = true
  disable_audit_logging = true
  disable_flow_logs = true
  disable_vulnerability_scanning = true
  skip_security_alerts = true
  
  depends_on = [module.insecure_iam]
}

# ========================================
# LOAD BALANCER INSEGURO - Sin WAF
# ========================================
resource "oci_load_balancer_load_balancer" "vulnerable_lb" {
  compartment_id = module.insecure_iam.root_compartment_ocid
  display_name   = "${local.project_name}-${local.environment}-lb"
  shape          = "flexible"
  
  subnet_ids = [module.exposed_network.public_subnet_id]
  
  # Sin WAF, sin protecciones
  is_private = false
  
  shape_details {
    maximum_bandwidth_in_mbps = 100
    minimum_bandwidth_in_mbps = 10
  }
  
  freeform_tags = merge(local.common_tags, {
    Name = "${local.project_name}-${local.environment}-lb-vulnerable"
    Security = "NONE"
  })
}

# Backend set sin health checks robustos
resource "oci_load_balancer_backend_set" "vulnerable_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.vulnerable_lb.id
  name            = "vulnerable-backend-set"
  policy          = "ROUND_ROBIN"
  
  health_checker {
    protocol = "HTTP"
    port     = 80
    url_path = "/"
    # Health check básico, sin validaciones de seguridad
  }
}

# Backends conectados a instancias vulnerables
resource "oci_load_balancer_backend" "vulnerable_backends" {
  count            = length(module.unprotected_compute.instance_private_ips)
  backendset_name  = oci_load_balancer_backend_set.vulnerable_backend_set.name
  load_balancer_id = oci_load_balancer_load_balancer.vulnerable_lb.id
  ip_address      = module.unprotected_compute.instance_private_ips[count.index]
  port            = 80
  backup          = false
  drain           = false
  offline         = false
  weight          = 1
}

# Listener HTTP - SIN HTTPS enforcement
resource "oci_load_balancer_listener" "vulnerable_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.vulnerable_lb.id
  name                    = "vulnerable-http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.vulnerable_backend_set.name
  port                    = 80
  protocol                = "HTTP"  # SIN cifrado
  
  # Sin restricciones de seguridad
  connection_configuration {
    idle_timeout_in_seconds = 300
  }
}