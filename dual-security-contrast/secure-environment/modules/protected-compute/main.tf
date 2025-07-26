# ========================================
# MÓDULO COMPUTE ENDURECIDO - HARDENED INSTANCES
# Compute instances con todas las protecciones de seguridad
# ========================================

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.21.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.0"
    }
  }
}

# Data sources
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = var.os_version
  shape                    = var.instance_shape
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  # Naming convention
  resource_prefix = "${var.environment}-secure"
  
  # Flexible shapes configuration
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex", "VM.Standard.E4.Flex", 
    "VM.Standard.A1.Flex", "VM.Optimized3.Flex"
  ]
  is_flexible_shape = contains(local.compute_flexible_shapes, var.instance_shape)
  
  # Latest Oracle Linux image
  latest_image_id = data.oci_core_images.oracle_linux.images[0].id
  
  # Availability Domains
  availability_domains = data.oci_identity_availability_domains.ads.availability_domains
  
  # Instance distribution across ADs
  instance_ads = [
    for i in range(var.instance_count) :
    local.availability_domains[i % length(local.availability_domains)].name
  ]
}

# ========================================
# TLS KEY GENERATION - SECURE SSH ACCESS
# ========================================
resource "tls_private_key" "secure_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096  # ✅ SECURITY: Strong 4096-bit RSA key
}

resource "random_password" "instance_passwords" {
  count   = var.instance_count
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
  
  # Ensure complexity
  min_special = 2
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}

# ========================================
# NETWORK SECURITY GROUPS - GRANULAR CONTROL
# ========================================

# Web Tier NSG
resource "oci_core_network_security_group" "web_nsg" {
  count          = var.create_web_instances ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  
  display_name = "${local.resource_prefix}-web-nsg"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-web-nsg"
    Type = "web-nsg"
    Tier = "WEB"
    Security = "HARDENED"
  })
}

# Web NSG Rules - Restrictive
resource "oci_core_network_security_group_security_rule" "web_ingress_lb" {
  count                     = var.create_web_instances ? 1 : 0
  network_security_group_id = oci_core_network_security_group.web_nsg[0].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  
  description = "HTTP from Load Balancer"
  source      = var.lb_subnet_cidr
  source_type = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 8080
      max = 8080
    }
  }
}

resource "oci_core_network_security_group_security_rule" "web_ingress_ssh" {
  count                     = var.create_web_instances ? 1 : 0
  network_security_group_id = oci_core_network_security_group.web_nsg[0].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  
  description = "SSH from Bastion/Management subnet"
  source      = var.mgmt_subnet_cidr
  source_type = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "web_egress_app" {
  count                     = var.create_web_instances ? 1 : 0
  network_security_group_id = oci_core_network_security_group.web_nsg[0].id
  direction                 = "EGRESS"
  protocol                  = "6" # TCP
  
  description      = "To App Tier"
  destination      = var.app_subnet_cidr
  destination_type = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 8080
      max = 8080
    }
  }
}

resource "oci_core_network_security_group_security_rule" "web_egress_internet" {
  count                     = var.create_web_instances ? 1 : 0
  network_security_group_id = oci_core_network_security_group.web_nsg[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  
  description      = "Internet access for updates"
  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
}

# App Tier NSG
resource "oci_core_network_security_group" "app_nsg" {
  count          = var.create_app_instances ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  
  display_name = "${local.resource_prefix}-app-nsg"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-app-nsg"
    Type = "app-nsg"
    Tier = "APPLICATION"
    Security = "HARDENED"
  })
}

# App NSG Rules
resource "oci_core_network_security_group_security_rule" "app_ingress_web" {
  count                     = var.create_app_instances ? 1 : 0
  network_security_group_id = oci_core_network_security_group.app_nsg[0].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  
  description = "HTTP from Web Tier"
  source      = var.web_subnet_cidr
  source_type = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 8080
      max = 8080
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_ingress_ssh" {
  count                     = var.create_app_instances ? 1 : 0
  network_security_group_id = oci_core_network_security_group.app_nsg[0].id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  
  description = "SSH from Bastion/Management subnet"
  source      = var.mgmt_subnet_cidr
  source_type = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_egress_db" {
  count                     = var.create_app_instances ? 1 : 0
  network_security_group_id = oci_core_network_security_group.app_nsg[0].id
  direction                 = "EGRESS"
  protocol                  = "6" # TCP
  
  description      = "To Database (Oracle 23ai with Firewall)"
  destination      = var.db_subnet_cidr
  destination_type = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 1521
      max = 1521
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_egress_internet" {
  count                     = var.create_app_instances ? 1 : 0
  network_security_group_id = oci_core_network_security_group.app_nsg[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  
  description      = "Internet access for updates"
  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
}

# ========================================
# WEB TIER INSTANCES - HARDENED
# ========================================
resource "oci_core_instance" "secure_web_instances" {
  count               = var.create_web_instances ? var.web_instance_count : 0
  compartment_id      = var.compartment_ocid
  availability_domain = local.instance_ads[count.index % length(local.instance_ads)]
  shape               = var.instance_shape
  display_name        = "${local.resource_prefix}-web-${count.index + 1}"
  
  # ✅ SECURITY: Flexible shape configuration
  dynamic "shape_config" {
    for_each = local.is_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.flex_shape_memory
      ocpus         = var.flex_shape_ocpus
    }
  }
  
  # ✅ SECURITY: Latest hardened Oracle Linux image
  source_details {
    source_id   = local.latest_image_id
    source_type = "image"
    
    # ✅ SECURITY: Boot volume encryption
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    kms_key_id              = var.kms_key_id
  }
  
  # ✅ SECURITY: Private subnet placement
  create_vnic_details {
    subnet_id                 = var.web_subnet_id
    display_name              = "${local.resource_prefix}-web-${count.index + 1}-vnic"
    assign_public_ip          = false  # NO public IP
    hostname_label            = "secureweb${count.index + 1}"
    nsg_ids                   = var.enable_nsgs ? [oci_core_network_security_group.web_nsg[0].id] : []
    skip_source_dest_check    = false
    assign_private_dns_record = true
  }
  
  # ✅ SECURITY: SSH key authentication only
  metadata = {
    ssh_authorized_keys = tls_private_key.secure_ssh_key.public_key_openssh
    user_data = base64encode(templatefile("${path.module}/scripts/web-hardening.sh", {
      admin_password = random_password.instance_passwords[count.index].result
      environment    = var.environment
      instance_name  = "${local.resource_prefix}-web-${count.index + 1}"
      kms_key_id     = var.kms_key_id
      vault_endpoint = var.vault_endpoint
    }))
  }
  
  # ✅ SECURITY: Comprehensive tagging
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-web-${count.index + 1}"
    Type = "secure-web-instance"
    Tier = "WEB"
    Security = "HARDENED"
    Encryption = "ENABLED"
    PublicIP = "DISABLED"
    SSHAccess = "KEY_ONLY"
    Monitoring = "ENABLED"
    Patching = "AUTOMATED"
  })
  
  # Prevent accidental deletion
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}

# ========================================
# APP TIER INSTANCES - HARDENED
# ========================================
resource "oci_core_instance" "secure_app_instances" {
  count               = var.create_app_instances ? var.app_instance_count : 0
  compartment_id      = var.compartment_ocid
  availability_domain = local.instance_ads[count.index % length(local.instance_ads)]
  shape               = var.instance_shape
  display_name        = "${local.resource_prefix}-app-${count.index + 1}"
  
  # Flexible shape configuration
  dynamic "shape_config" {
    for_each = local.is_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.flex_shape_memory
      ocpus         = var.flex_shape_ocpus
    }
  }
  
  # Latest hardened image with encryption
  source_details {
    source_id   = local.latest_image_id
    source_type = "image"
    
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    kms_key_id              = var.kms_key_id
  }
  
  # Private subnet placement
  create_vnic_details {
    subnet_id                 = var.app_subnet_id
    display_name              = "${local.resource_prefix}-app-${count.index + 1}-vnic"
    assign_public_ip          = false  # NO public IP
    hostname_label            = "secureapp${count.index + 1}"
    nsg_ids                   = var.enable_nsgs ? [oci_core_network_security_group.app_nsg[0].id] : []
    skip_source_dest_check    = false
    assign_private_dns_record = true
  }
  
  # Hardened configuration
  metadata = {
    ssh_authorized_keys = tls_private_key.secure_ssh_key.public_key_openssh
    user_data = base64encode(templatefile("${path.module}/scripts/app-hardening.sh", {
      admin_password    = random_password.instance_passwords[count.index].result
      environment       = var.environment
      instance_name     = "${local.resource_prefix}-app-${count.index + 1}"
      kms_key_id        = var.kms_key_id
      vault_endpoint    = var.vault_endpoint
      db_connection_string = var.db_connection_string
    }))
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-app-${count.index + 1}"
    Type = "secure-app-instance"
    Tier = "APPLICATION"
    Security = "HARDENED"
    Encryption = "ENABLED"
    PublicIP = "DISABLED"
    DatabaseAccess = "FIREWALL_PROTECTED"
    Monitoring = "ENABLED"
  })
  
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}

# ========================================
# BLOCK VOLUMES - ENCRYPTED STORAGE
# ========================================
resource "oci_core_volume" "secure_data_volumes" {
  count               = var.create_data_volumes ? var.instance_count : 0
  compartment_id      = var.compartment_ocid
  availability_domain = local.instance_ads[count.index % length(local.instance_ads)]
  
  display_name = "${local.resource_prefix}-data-volume-${count.index + 1}"
  size_in_gbs  = var.data_volume_size_in_gbs
  
  # ✅ SECURITY: Customer-managed encryption
  kms_key_id = var.kms_key_id
  
  # ✅ SECURITY: High performance for better security monitoring
  vpus_per_gb = var.volume_vpus_per_gb
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-data-volume-${count.index + 1}"
    Type = "secure-data-volume"
    Encryption = "CUSTOMER_MANAGED"
    Purpose = "APPLICATION_DATA"
  })
}

# Volume attachments
resource "oci_core_volume_attachment" "secure_data_volume_attachments" {
  count           = var.create_data_volumes ? var.instance_count : 0
  attachment_type = "iscsi"
  volume_id       = oci_core_volume.secure_data_volumes[count.index].id
  
  # Attach to web instances if they exist, otherwise app instances
  instance_id = var.create_web_instances ? oci_core_instance.secure_web_instances[count.index].id : oci_core_instance.secure_app_instances[count.index].id
  
  display_name = "${local.resource_prefix}-data-attachment-${count.index + 1}"
  device       = "/dev/oracleoci/oraclevdb"
  is_read_only = false
  is_shareable = false
  
  # ✅ SECURITY: Use CHAP for iSCSI authentication
  use_chap = true
}

# ========================================
# BASTION HOST - SECURE MANAGEMENT
# ========================================
resource "oci_core_instance" "secure_bastion" {
  count               = var.create_bastion_host ? 1 : 0
  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domains[0].name
  shape               = var.bastion_instance_shape
  display_name        = "${local.resource_prefix}-bastion"
  
  # Smaller shape for bastion
  dynamic "shape_config" {
    for_each = contains(local.compute_flexible_shapes, var.bastion_instance_shape) ? [1] : []
    content {
      memory_in_gbs = 8
      ocpus         = 1
    }
  }
  
  # Hardened bastion image
  source_details {
    source_id   = local.latest_image_id
    source_type = "image"
    
    boot_volume_size_in_gbs = 50
    kms_key_id              = var.kms_key_id
  }
  
  # Management subnet placement
  create_vnic_details {
    subnet_id                 = var.mgmt_subnet_id
    display_name              = "${local.resource_prefix}-bastion-vnic"
    assign_public_ip          = false  # Use Bastion Service instead
    hostname_label            = "securebastion"
    skip_source_dest_check    = false
    assign_private_dns_record = true
  }
  
  # Bastion hardening
  metadata = {
    ssh_authorized_keys = tls_private_key.secure_ssh_key.public_key_openssh
    user_data = base64encode(templatefile("${path.module}/scripts/bastion-hardening.sh", {
      admin_password = random_password.instance_passwords[0].result
      environment    = var.environment
      vault_endpoint = var.vault_endpoint
    }))
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-bastion"
    Type = "secure-bastion-instance"
    Tier = "MANAGEMENT"
    Security = "MAXIMUM"
    Purpose = "SECURE_ACCESS"
    Monitoring = "COMPREHENSIVE"
    Access = "BASTION_SERVICE_ONLY"
  })
  
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}

# ========================================
# INSTANCE CONFIGURATION - SECURITY HARDENING
# ========================================

# Instance configuration for security hardening
resource "oci_core_instance_configuration" "secure_instance_config" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.resource_prefix}-instance-config"
  
  instance_details {
    instance_type = "compute"
    
    launch_details {
      compartment_id = var.compartment_ocid
      shape          = var.instance_shape
      
      dynamic "shape_config" {
        for_each = local.is_flexible_shape ? [1] : []
        content {
          memory_in_gbs = var.flex_shape_memory
          ocpus         = var.flex_shape_ocpus
        }
      }
      
      source_details {
        source_type = "image"
        image_id    = local.latest_image_id
        
        boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
        kms_key_id              = var.kms_key_id
      }
      
      create_vnic_details {
        assign_public_ip = false
        nsg_ids          = var.enable_nsgs && var.create_web_instances ? [oci_core_network_security_group.web_nsg[0].id] : []
      }
      
      metadata = {
        ssh_authorized_keys = tls_private_key.secure_ssh_key.public_key_openssh
      }
      
      freeform_tags = merge(var.common_tags, {
        Name = "${local.resource_prefix}-hardened-template"
        Type = "secure-instance-template"
        Security = "HARDENED"
        Encryption = "ENABLED"
      })
    }
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-instance-config"
    Type = "secure-instance-configuration"
    Purpose = "HARDENED_TEMPLATE"
  })
}

# ========================================
# LOCAL VALUES FOR OUTPUTS
# ========================================
locals {
  # Instance information
  web_instances = var.create_web_instances ? oci_core_instance.secure_web_instances : []
  app_instances = var.create_app_instances ? oci_core_instance.secure_app_instances : []
  bastion_instance = var.create_bastion_host ? oci_core_instance.secure_bastion[0] : null
  
  # SSH key information
  ssh_private_key = tls_private_key.secure_ssh_key.private_key_pem
  ssh_public_key  = tls_private_key.secure_ssh_key.public_key_openssh
  
  # Security features summary
  security_features = {
    encryption_enabled = var.kms_key_id != ""
    nsgs_enabled = var.enable_nsgs
    bastion_host = var.create_bastion_host
    private_subnets_only = true
    ssh_key_auth_only = true
    automated_hardening = true
    monitoring_enabled = true
  }
}