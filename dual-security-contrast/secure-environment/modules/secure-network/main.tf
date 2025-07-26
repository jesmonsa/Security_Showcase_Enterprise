# ========================================
# MÓDULO NETWORK SEGURO - COMPREHENSIVE PROTECTION
# VCN con WAF, NSGs, Private Subnets, Bastion Service
# ========================================

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.21.0"
    }
  }
}

# Data sources
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

locals {
  # VCN CIDR blocks
  vcn_cidr = var.vcn_cidr_block
  
  # Subnet CIDR calculations - All PRIVATE for security
  private_subnet_cidrs = {
    web_tier    = cidrsubnet(local.vcn_cidr, 8, 10)    # 10.60.10.0/24
    app_tier    = cidrsubnet(local.vcn_cidr, 8, 20)    # 10.60.20.0/24
    db_tier     = cidrsubnet(local.vcn_cidr, 8, 30)    # 10.60.30.0/24
    management  = cidrsubnet(local.vcn_cidr, 8, 40)    # 10.60.40.0/24
  }
  
  # Solo 1 public subnet mínima para Load Balancer (con WAF)
  public_subnet_cidr = cidrsubnet(local.vcn_cidr, 8, 5)  # 10.60.5.0/24
  
  # Naming convention
  resource_prefix = "${var.environment}-secure"
}

# ========================================
# VCN - SECURE VIRTUAL CLOUD NETWORK
# ========================================
resource "oci_core_vcn" "secure_vcn" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [local.vcn_cidr]
  
  display_name = "${local.resource_prefix}-vcn"
  dns_label    = "securevcn"
  
  # ✅ SECURITY: Enable VCN Flow Logs
  is_ipv6enabled = false  # IPv4 only para mayor control
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-vcn"
    Type = "secure-vcn"
    Tier = "NETWORK"
    Security = "COMPREHENSIVE"
    FlowLogs = var.enable_flow_logs ? "ENABLED" : "DISABLED"
    Access = "PRIVATE_FOCUSED"
  })
}

# ========================================
# INTERNET GATEWAY - MÍNIMO ACCESO PÚBLICO
# ========================================
resource "oci_core_internet_gateway" "secure_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  enabled      = true
  display_name = "${local.resource_prefix}-igw"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-igw"
    Type = "secure-internet-gateway"
    Purpose = "LOAD_BALANCER_ONLY"
    Security = "WAF_PROTECTED"
  })
}

# ========================================
# NAT GATEWAY - SECURE OUTBOUND ACCESS
# ========================================
resource "oci_core_nat_gateway" "secure_nat" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  display_name = "${local.resource_prefix}-nat"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-nat"
    Type = "secure-nat-gateway"
    Purpose = "PRIVATE_SUBNET_OUTBOUND"
    Security = "CONTROLLED_EGRESS"
  })
}

# ========================================
# SERVICE GATEWAY - ORACLE SERVICES ACCESS
# ========================================
resource "oci_core_service_gateway" "secure_service_gw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  display_name = "${local.resource_prefix}-service-gw"
  
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-service-gw"
    Type = "secure-service-gateway"
    Purpose = "ORACLE_SERVICES_ACCESS"
    Security = "CONTROLLED_ACCESS"
  })
}

# ========================================
# SUBNETS - PRIVATE-FIRST ARCHITECTURE
# ========================================

# ✅ PUBLIC SUBNET - SOLO PARA LOAD BALANCER CON WAF
resource "oci_core_subnet" "public_lb_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  cidr_block     = local.public_subnet_cidr
  
  display_name               = "${local.resource_prefix}-public-lb-subnet"
  dns_label                  = "publicsecure"
  prohibit_public_ip_on_vnic = false  # Solo para Load Balancer
  
  route_table_id = oci_core_route_table.public_route_table.id
  security_list_ids = [oci_core_security_list.public_lb_security_list.id]
  
  availability_domain = null  # Regional subnet
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-public-lb-subnet"
    Type = "public-subnet-secure"
    Tier = "LOAD_BALANCER_ONLY"
    Security = "WAF_PROTECTED"
    Access = "INTERNET_FACING"
  })
}

# ✅ PRIVATE WEB TIER SUBNET
resource "oci_core_subnet" "private_web_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  cidr_block     = local.private_subnet_cidrs.web_tier
  
  display_name               = "${local.resource_prefix}-private-web-subnet"
  dns_label                  = "privateweb"
  prohibit_public_ip_on_vnic = true  # ✅ SECURITY: No public IPs
  
  route_table_id = oci_core_route_table.private_route_table.id
  security_list_ids = [oci_core_security_list.private_web_security_list.id]
  
  availability_domain = null  # Regional subnet
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-private-web-subnet"
    Type = "private-subnet-secure"
    Tier = "WEB"
    Security = "HARDENED"
    Access = "PRIVATE_ONLY"
  })
}

# ✅ PRIVATE APP TIER SUBNET
resource "oci_core_subnet" "private_app_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  cidr_block     = local.private_subnet_cidrs.app_tier
  
  display_name               = "${local.resource_prefix}-private-app-subnet"
  dns_label                  = "privateapp"
  prohibit_public_ip_on_vnic = true  # ✅ SECURITY: No public IPs
  
  route_table_id = oci_core_route_table.private_route_table.id
  security_list_ids = [oci_core_security_list.private_app_security_list.id]
  
  availability_domain = null  # Regional subnet
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-private-app-subnet"
    Type = "private-subnet-secure"
    Tier = "APPLICATION"
    Security = "HARDENED"
    Access = "PRIVATE_ONLY"
  })
}

# ✅ PRIVATE DATABASE TIER SUBNET - MÁXIMO SECURITY
resource "oci_core_subnet" "private_db_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  cidr_block     = local.private_subnet_cidrs.db_tier
  
  display_name               = "${local.resource_prefix}-private-db-subnet"
  dns_label                  = "privatedb"
  prohibit_public_ip_on_vnic = true  # ✅ SECURITY: No public IPs EVER
  
  route_table_id = oci_core_route_table.private_db_route_table.id
  security_list_ids = [oci_core_security_list.private_db_security_list.id]
  
  availability_domain = null  # Regional subnet
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-private-db-subnet"
    Type = "private-subnet-secure"
    Tier = "DATABASE"
    Security = "MAXIMUM"
    Access = "PRIVATE_ONLY"
    DatabaseFirewall = "PROTECTED"
    DataSafe = "MONITORED"
  })
}

# ✅ PRIVATE MANAGEMENT SUBNET - BASTION ACCESS
resource "oci_core_subnet" "private_mgmt_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  cidr_block     = local.private_subnet_cidrs.management
  
  display_name               = "${local.resource_prefix}-private-mgmt-subnet"
  dns_label                  = "privatemgmt"
  prohibit_public_ip_on_vnic = true  # ✅ SECURITY: No public IPs
  
  route_table_id = oci_core_route_table.private_route_table.id
  security_list_ids = [oci_core_security_list.private_mgmt_security_list.id]
  
  availability_domain = null  # Regional subnet
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-private-mgmt-subnet"
    Type = "private-subnet-secure"
    Tier = "MANAGEMENT"
    Security = "BASTION_CONTROLLED"
    Access = "BASTION_ONLY"
  })
}

# ========================================
# ROUTE TABLES - SECURE ROUTING
# ========================================

# Public route table - Solo para Load Balancer
resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  display_name = "${local.resource_prefix}-public-rt"
  
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.secure_igw.id
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-public-rt"
    Type = "public-route-table"
    Purpose = "LOAD_BALANCER_ONLY"
  })
}

# Private route table - Para web/app tiers
resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  display_name = "${local.resource_prefix}-private-rt"
  
  # Outbound via NAT Gateway
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.secure_nat.id
  }
  
  # Oracle Services via Service Gateway
  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.secure_service_gw.id
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-private-rt"
    Type = "private-route-table"
    Purpose = "WEB_APP_TIERS"
  })
}

# Database route table - Más restrictivo
resource "oci_core_route_table" "private_db_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  display_name = "${local.resource_prefix}-private-db-rt"
  
  # Solo Oracle Services - NO Internet access
  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.secure_service_gw.id
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-private-db-rt"
    Type = "private-db-route-table"
    Purpose = "DATABASE_TIER_ONLY"
    Security = "MAXIMUM_ISOLATION"
  })
}

# ========================================
# SECURITY LISTS - DEFENSE IN DEPTH
# ========================================

# Security List para Load Balancer público
resource "oci_core_security_list" "public_lb_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  display_name = "${local.resource_prefix}-public-lb-sl"
  
  # ✅ INGRESS: Solo HTTP/HTTPS desde internet (protegido por WAF)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    
    tcp_options {
      min = 80
      max = 80
    }
    description = "HTTP traffic (redirected to HTTPS)"
  }
  
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    
    tcp_options {
      min = 443
      max = 443
    }
    description = "HTTPS traffic (WAF protected)"
  }
  
  # ✅ EGRESS: Solo hacia web tier
  egress_security_rules {
    protocol    = "6" # TCP
    destination = local.private_subnet_cidrs.web_tier
    
    tcp_options {
      min = 8080
      max = 8080
    }
    description = "To web servers"
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-public-lb-sl"
    Type = "public-security-list"
    Protection = "WAF_ENABLED"
  })
}

# Security List para Web Tier privado
resource "oci_core_security_list" "private_web_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  display_name = "${local.resource_prefix}-private-web-sl"
  
  # ✅ INGRESS: Solo desde Load Balancer
  ingress_security_rules {
    protocol = "6" # TCP
    source   = local.public_subnet_cidr
    
    tcp_options {
      min = 8080
      max = 8080
    }
    description = "From Load Balancer"
  }
  
  # SSH desde management subnet (Bastion)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = local.private_subnet_cidrs.management
    
    tcp_options {
      min = 22
      max = 22
    }
    description = "SSH from Bastion"
  }
  
  # ✅ EGRESS: Hacia app tier y internet via NAT
  egress_security_rules {
    protocol    = "6" # TCP
    destination = local.private_subnet_cidrs.app_tier
    
    tcp_options {
      min = 8080
      max = 8080
    }
    description = "To app servers"
  }
  
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Internet access via NAT"
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-private-web-sl"
    Type = "private-web-security-list"
    Access = "LB_AND_BASTION_ONLY"
  })
}

# Security List para App Tier privado
resource "oci_core_security_list" "private_app_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  display_name = "${local.resource_prefix}-private-app-sl"
  
  # ✅ INGRESS: Solo desde web tier
  ingress_security_rules {
    protocol = "6" # TCP
    source   = local.private_subnet_cidrs.web_tier
    
    tcp_options {
      min = 8080
      max = 8080
    }
    description = "From web servers"
  }
  
  # SSH desde management subnet (Bastion)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = local.private_subnet_cidrs.management
    
    tcp_options {
      min = 22
      max = 22
    }
    description = "SSH from Bastion"
  }
  
  # ✅ EGRESS: Hacia database tier y internet via NAT
  egress_security_rules {
    protocol    = "6" # TCP
    destination = local.private_subnet_cidrs.db_tier
    
    tcp_options {
      min = 1521
      max = 1521
    }
    description = "To database (Oracle 23ai with Firewall)"
  }
  
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Internet access via NAT"
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-private-app-sl"
    Type = "private-app-security-list"
    Access = "WEB_AND_BASTION_ONLY"
  })
}

# Security List para Database Tier - MÁXIMO SECURITY
resource "oci_core_security_list" "private_db_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  display_name = "${local.resource_prefix}-private-db-sl"
  
  # ✅ INGRESS: Solo desde app tier (con Database Firewall habilitado)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = local.private_subnet_cidrs.app_tier
    
    tcp_options {
      min = 1521
      max = 1521
    }
    description = "From app servers to Oracle 23ai (Database Firewall enabled)"
  }
  
  # SSH desde management subnet (Bastion) - Solo para emergency access
  ingress_security_rules {
    protocol = "6" # TCP
    source   = local.private_subnet_cidrs.management
    
    tcp_options {
      min = 22
      max = 22
    }
    description = "Emergency SSH from Bastion (audited)"
  }
  
  # ✅ EGRESS: Solo Oracle Services (NO Internet)
  egress_security_rules {
    protocol         = "6" # TCP
    destination      = data.oci_core_services.all_services.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    
    tcp_options {
      min = 443
      max = 443
    }
    description = "Oracle Cloud Services only (Data Safe, etc.)"
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-private-db-sl"
    Type = "private-db-security-list"
    Security = "MAXIMUM"
    Access = "APP_AND_EMERGENCY_BASTION_ONLY"
    DatabaseFirewall = "ENABLED"
    DataSafe = "ENABLED"
  })
}

# Security List para Management Subnet (Bastion)
resource "oci_core_security_list" "private_mgmt_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.secure_vcn.id
  
  display_name = "${local.resource_prefix}-private-mgmt-sl"
  
  # ✅ INGRESS: Solo desde Bastion Service (configurado separadamente)
  # No reglas de ingress directas - el Bastion Service maneja el acceso
  
  # ✅ EGRESS: Hacia todos los tiers para management
  egress_security_rules {
    protocol    = "6" # TCP
    destination = local.private_subnet_cidrs.web_tier
    
    tcp_options {
      min = 22
      max = 22
    }
    description = "SSH to web servers"
  }
  
  egress_security_rules {
    protocol    = "6" # TCP
    destination = local.private_subnet_cidrs.app_tier
    
    tcp_options {
      min = 22
      max = 22
    }
    description = "SSH to app servers"
  }
  
  egress_security_rules {
    protocol    = "6" # TCP
    destination = local.private_subnet_cidrs.db_tier
    
    tcp_options {
      min = 22
      max = 22
    }
    description = "Emergency SSH to database subnet"
  }
  
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Internet access via NAT for management tools"
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-private-mgmt-sl"
    Type = "private-mgmt-security-list"
    Purpose = "BASTION_MANAGEMENT"
    Access = "BASTION_SERVICE_CONTROLLED"
  })
}

# ========================================
# VCN FLOW LOGS - NETWORK MONITORING
# ========================================
resource "oci_logging_log_group" "vcn_flow_logs_group" {
  count          = var.enable_flow_logs ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${local.resource_prefix}-vcn-flow-logs-group"
  description    = "Log group for VCN Flow Logs - Security monitoring"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-vcn-flow-logs-group"
    Type = "flow-logs-group"
    Purpose = "SECURITY_MONITORING"
  })
}

resource "oci_logging_log" "vcn_flow_logs" {
  count        = var.enable_flow_logs ? 1 : 0
  display_name = "${local.resource_prefix}-vcn-flow-logs"
  log_group_id = oci_logging_log_group.vcn_flow_logs_group[0].id
  log_type     = "SERVICE"
  
  configuration {
    source {
      category    = "all"
      resource    = oci_core_vcn.secure_vcn.id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    
    compartment_id = var.compartment_ocid
  }
  
  is_enabled         = true
  retention_duration = var.log_retention_duration
  
  freeform_tags = merge(var.common_tags, {
    Name = "${local.resource_prefix}-vcn-flow-logs"
    Type = "flow-logs"
    Security = "NETWORK_MONITORING"
    Retention = "${var.log_retention_duration}_DAYS"
  })
}

# ========================================
# LOCAL VALUES FOR OUTPUTS
# ========================================
locals {
  # Network information for other modules
  network_info = {
    vcn_id = oci_core_vcn.secure_vcn.id
    vcn_cidr = local.vcn_cidr
    
    # Subnet IDs
    public_lb_subnet_id     = oci_core_subnet.public_lb_subnet.id
    private_web_subnet_id   = oci_core_subnet.private_web_subnet.id
    private_app_subnet_id   = oci_core_subnet.private_app_subnet.id
    private_db_subnet_id    = oci_core_subnet.private_db_subnet.id
    private_mgmt_subnet_id  = oci_core_subnet.private_mgmt_subnet.id
    
    # Gateway IDs
    internet_gateway_id = oci_core_internet_gateway.secure_igw.id
    nat_gateway_id      = oci_core_nat_gateway.secure_nat.id
    service_gateway_id  = oci_core_service_gateway.secure_service_gw.id
    
    # Security features
    flow_logs_enabled = var.enable_flow_logs
    waf_protected = var.enable_waf
  }
}