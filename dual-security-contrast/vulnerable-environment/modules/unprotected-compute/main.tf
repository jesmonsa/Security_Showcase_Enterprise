# ========================================
# MÓDULO COMPUTE DESPROTEGIDO - "QUÉ NO HACER"
# Instancias sin hardening ni protecciones
# ========================================

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.21.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

# Data sources
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "ol8_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order              = "DESC"
}

# ========================================
# SSH KEY GENERATION - SIN PROTECCIÓN
# ========================================

# Generar SSH key INSEGURO para demo
resource "tls_private_key" "vulnerable_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048  # Tamaño mínimo - menos seguro que 4096
}

# INSEGURO: Guardar private key en archivo local sin cifrado
resource "local_file" "vulnerable_private_key" {
  content         = tls_private_key.vulnerable_ssh_key.private_key_pem
  filename        = "${path.module}/vulnerable_private_key.pem"
  file_permission = "0600"
}

# INSEGURO: Exponer public key
resource "local_file" "vulnerable_public_key" {
  content         = tls_private_key.vulnerable_ssh_key.public_key_openssh
  filename        = "${path.module}/vulnerable_public_key.pub"
  file_permission = "0644"
}

# ========================================
# CLOUD-INIT SCRIPT - CONFIGURACIÓN INSEGURA
# ========================================

locals {
  # Script de inicialización DELIBERADAMENTE INSEGURO
  vulnerable_cloud_init = base64encode(templatefile("${path.module}/cloud-init-vulnerable.yaml", {
    enable_password_auth     = var.enable_password_auth
    install_vulnerable_apps  = var.install_vulnerable_apps
    disable_os_hardening    = var.disable_os_hardening
    database_connection     = var.database_connection
  }))
}

# ========================================
# COMPUTE INSTANCES - SIN PROTECCIONES
# ========================================

resource "oci_core_instance" "vulnerable_instances" {
  count               = var.instance_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.environment}-vulnerable-instance-${count.index + 1}"
  
  shape = var.instance_shape
  
  # Shape configuration para flexible shapes
  dynamic "shape_config" {
    for_each = length(regexall("Flex", var.instance_shape)) > 0 ? [1] : []
    content {
      ocpus         = 1    # Mínimo para reducir costos
      memory_in_gbs = 8    # Mínimo para reducir costos
    }
  }
  
  # INSEGURO: Usar imagen base sin hardening
  create_vnic_details {
    subnet_id              = var.subnet_id
    display_name          = "${var.environment}-vulnerable-vnic-${count.index + 1}"
    assign_public_ip      = true  # INSEGURO: IP pública directa
    hostname_label        = "vuln-host-${count.index + 1}"
    
    # PELIGROSO: Sin NSG restrictivo
    nsg_ids = []  # Sin Network Security Groups
    
    # INSEGURO: Skip source/dest check (permite routing)
    skip_source_dest_check = true
  }
  
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ol8_images.images[0].id
  }
  
  metadata = {
    ssh_authorized_keys = tls_private_key.vulnerable_ssh_key.public_key_openssh
    user_data          = local.vulnerable_cloud_init
  }
  
  # CRÍTICO: Sin cifrado de boot volume
  # is_pv_encryption_in_transit_enabled = false  # Comentado porque puede causar errores
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-vulnerable-instance-${count.index + 1}"
    Type = "vulnerable-compute"
    Security = "NONE"
    Hardening = "DISABLED"
    Encryption = "NONE"
    OS = "unpatched"
  })
}

# ========================================
# BLOCK VOLUMES - SIN CIFRADO
# ========================================

resource "oci_core_volume" "vulnerable_volumes" {
  count               = var.instance_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.environment}-vulnerable-volume-${count.index + 1}"
  
  size_in_gbs = 50  # Tamaño mínimo para demo
  
  # INSEGURO: Sin cifrado con customer-managed keys
  # kms_key_id = null  # Sin cifrado adicional
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-vulnerable-volume-${count.index + 1}"
    Type = "vulnerable-storage"
    Encryption = "DEFAULT_ONLY"
  })
}

# Attachment de volúmenes SIN cifrado en tránsito
resource "oci_core_volume_attachment" "vulnerable_volume_attachments" {
  count           = var.instance_count
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.vulnerable_instances[count.index].id
  volume_id       = oci_core_volume.vulnerable_volumes[count.index].id
  
  # INSEGURO: Sin cifrado en tránsito
  is_pv_encryption_in_transit_enabled = false
  
  display_name = "${var.environment}-vulnerable-attachment-${count.index + 1}"
}

# ========================================
# SIN VULNERABILITY SCANNING SERVICE
# ========================================
# Nota: Intencionalmente NO se configura Vulnerability Scanning Service
# para mostrar la falta de detección de vulnerabilidades

# ========================================
# SIN BASTION SERVICE
# ========================================
# Nota: Intencionalmente NO se despliega Bastion Service
# para mostrar acceso SSH directo inseguro

# ========================================
# SIN OS MANAGEMENT SERVICE
# ========================================
# Nota: Intencionalmente NO se configura OS Management
# para mostrar falta de patch management

# ========================================
# OUTPUTS PARA OTROS MÓDULOS
# ========================================

output "instance_ids" {
  description = "OCIDs of vulnerable compute instances"
  value       = oci_core_instance.vulnerable_instances[*].id
}

output "instance_names" {
  description = "Names of vulnerable compute instances"
  value       = oci_core_instance.vulnerable_instances[*].display_name
}

output "instance_public_ips" {
  description = "Public IP addresses of vulnerable instances (EXPOSED)"
  value       = oci_core_instance.vulnerable_instances[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of vulnerable instances"
  value       = oci_core_instance.vulnerable_instances[*].private_ip
}

output "ssh_private_key_path" {
  description = "Path to SSH private key (INSECURE STORAGE)"
  value       = local_file.vulnerable_private_key.filename
}

output "ssh_connection_commands" {
  description = "SSH connection commands to vulnerable instances"
  value = [
    for i, ip in oci_core_instance.vulnerable_instances[*].public_ip :
    "ssh -i ${local_file.vulnerable_private_key.filename} -o StrictHostKeyChecking=no opc@${ip}"
  ]
}

# Resumen de vulnerabilidades de compute
output "compute_vulnerabilities_summary" {
  description = "Summary of compute layer vulnerabilities"
  value = {
    instance_security = {
      public_ip_exposure = "HIGH - All instances have public IPs"
      ssh_configuration = "INSECURE - Password auth enabled, weak keys"
      os_hardening = "NONE - No security hardening applied"
      patch_management = "DISABLED - No automatic updates"
      vulnerability_scanning = "DISABLED - No scanning service"
    }
    
    storage_security = {
      boot_volume_encryption = "DEFAULT_ONLY - No customer-managed keys"
      block_volume_encryption = "DEFAULT_ONLY - No additional encryption"
      transit_encryption = "DISABLED - No encryption in transit"
      backup_encryption = "NONE - No encrypted backups"
    }
    
    network_security = {
      security_groups = "NONE - No NSGs configured"
      firewall_rules = "PERMISSIVE - Relies on subnet security lists"
      bastion_service = "NOT_DEPLOYED - Direct SSH access"
      private_connectivity = "NONE - All public access"
    }
    
    access_control = {
      ssh_keys = "WEAK - 2048-bit RSA, stored locally unencrypted"
      password_auth = var.enable_password_auth ? "ENABLED - Allows password login" : "DISABLED"
      privilege_escalation = "UNRESTRICTED - Full sudo access"
      session_management = "BASIC - No advanced controls"
    }
    
    monitoring = {
      os_management = "DISABLED - No centralized management"
      security_monitoring = "NONE - No security agent"
      log_forwarding = "DISABLED - No centralized logging"
      performance_monitoring = "BASIC - Default only"
    }
    
    compliance_issues = {
      pci_dss = "NON_COMPLIANT - Inadequate access controls"
      sox = "NON_COMPLIANT - No change management"
      iso27001 = "NON_COMPLIANT - Missing security controls"
      cis_benchmark = "NON_COMPLIANT - No hardening applied"
    }
    
    attack_vectors = {
      ssh_brute_force = "HIGH - Public SSH access"
      privilege_escalation = "MEDIUM - Unrestricted sudo"
      lateral_movement = "HIGH - No network segmentation"
      data_exfiltration = "HIGH - No DLP controls"
      malware_infection = "HIGH - No antivirus or scanning"
    }
    
    remediation_priority = "CRITICAL"
    estimated_risk_score = "8.7/10"
  }
}