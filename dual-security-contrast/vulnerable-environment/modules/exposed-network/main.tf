# ========================================
# MÓDULO NETWORK EXPUESTA - "QUÉ NO HACER"
# Red completamente abierta e insegura
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
# VCN INSEGURA
# ========================================

resource "oci_core_vcn" "vulnerable_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.environment}-vulnerable-vcn"
  cidr_block     = var.vcn_cidr_block
  dns_label      = "vulnerable"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-vulnerable-vcn"
    Type = "insecure-vcn"
    Security = "NONE"
  })
}

# ========================================
# INTERNET GATEWAY - SIN RESTRICCIONES
# ========================================

resource "oci_core_internet_gateway" "vulnerable_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vulnerable_vcn.id
  display_name   = "${var.environment}-vulnerable-igw"
  enabled        = true
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-vulnerable-igw"
    Type = "insecure-gateway"
    Access = "UNRESTRICTED"
  })
}

# ========================================
# SUBNETS PÚBLICAS - TODO EXPUESTO
# ========================================

# Subnet pública para WEB - SIN protección
resource "oci_core_subnet" "vulnerable_public_web" {
  compartment_id      = var.compartment_ocid
  vcn_id             = oci_core_vcn.vulnerable_vcn.id
  display_name       = "${var.environment}-public-web-subnet"
  cidr_block         = cidrsubnet(var.vcn_cidr_block, 8, 1)
  dns_label          = "publicweb"
  
  # INSEGURO: Sin restricción de acceso público
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false
  
  # Route table con acceso directo a internet
  route_table_id = oci_core_route_table.vulnerable_public_rt.id
  
  # Security list permisiva
  security_list_ids = [oci_core_security_list.vulnerable_allow_all.id]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-public-web-subnet"
    Type = "insecure-subnet"
    Exposure = "FULL_INTERNET"
  })
}

# Subnet pública para BASE DE DATOS - EXTREMADAMENTE INSEGURO
resource "oci_core_subnet" "vulnerable_public_database" {
  compartment_id      = var.compartment_ocid
  vcn_id             = oci_core_vcn.vulnerable_vcn.id
  display_name       = "${var.environment}-public-database-subnet"
  cidr_block         = cidrsubnet(var.vcn_cidr_block, 8, 2)
  dns_label          = "publicdb"
  
  # CRÍTICO: Base de datos en subnet pública
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false
  
  route_table_id    = oci_core_route_table.vulnerable_public_rt.id
  security_list_ids = [oci_core_security_list.vulnerable_database_open.id]
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-public-database-subnet"
    Type = "insecure-db-subnet"
    Risk = "CRITICAL"
    Exposure = "DATABASE_INTERNET_EXPOSED"
  })
}

# ========================================
# ROUTE TABLES - ACCESO DIRECTO
# ========================================

resource "oci_core_route_table" "vulnerable_public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vulnerable_vcn.id
  display_name   = "${var.environment}-public-route-table"
  
  # Ruta directa a internet sin restricciones
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.vulnerable_igw.id
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-public-route-table"
    Type = "insecure-route-table"
  })
}

# ========================================
# SECURITY LISTS - COMPLETAMENTE ABIERTAS
# ========================================

# Security list que permite TODO
resource "oci_core_security_list" "vulnerable_allow_all" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vulnerable_vcn.id
  display_name   = "${var.environment}-allow-all-sl"
  
  # PELIGROSO: Ingress permite todo el tráfico
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
    description = "Allow all inbound traffic - EXTREMELY DANGEROUS"
  }
  
  # PELIGROSO: Egress permite todo el tráfico
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow all outbound traffic"
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-allow-all-sl"
    Type = "insecure-security-list"
    Risk = "MAXIMUM"
  })
}

# Security list específica para base de datos - ABIERTA
resource "oci_core_security_list" "vulnerable_database_open" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vulnerable_vcn.id
  display_name   = "${var.environment}-database-open-sl"
  
  # CRÍTICO: Puerto Oracle abierto a internet
  ingress_security_rules {
    protocol = "6"  # TCP
    source   = "0.0.0.0/0"
    
    tcp_options {
      min = 1521
      max = 1521
    }
    description = "Oracle database port open to internet - CRITICAL RISK"
  }
  
  # SSH abierto desde cualquier lugar
  ingress_security_rules {
    protocol = "6"  # TCP
    source   = "0.0.0.0/0"
    
    tcp_options {
      min = 22
      max = 22
    }
    description = "SSH open to world - HIGH RISK"
  }
  
  # HTTP/HTTPS abierto
  ingress_security_rules {
    protocol = "6"  # TCP
    source   = "0.0.0.0/0"
    
    tcp_options {
      min = 80
      max = 80
    }
    description = "HTTP open to world"
  }
  
  ingress_security_rules {
    protocol = "6"  # TCP
    source   = "0.0.0.0/0"
    
    tcp_options {
      min = 443
      max = 443
    }
    description = "HTTPS open to world"
  }
  
  # ICMP abierto (permite ping desde cualquier lugar)
  ingress_security_rules {
    protocol = "1"  # ICMP
    source   = "0.0.0.0/0"
    description = "ICMP open to world - info disclosure"
  }
  
  # Egress completamente abierto
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow all outbound traffic"
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-database-open-sl"
    Type = "insecure-database-security-list"
    Risk = "CRITICAL"
    Exposure = "DATABASE_PORTS_OPEN"
  })
}

# ========================================
# NETWORK SECURITY GROUPS - INSEGUROS (SI EXISTEN)
# ========================================

# NSG que permite todo (demuestra mal uso de NSGs)
resource "oci_core_network_security_group" "vulnerable_allow_all_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vulnerable_vcn.id
  display_name   = "${var.environment}-allow-all-nsg"
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-allow-all-nsg"
    Type = "insecure-nsg"
    Security = "NONE"
  })
}

# Reglas NSG permisivas
resource "oci_core_network_security_group_security_rule" "vulnerable_nsg_ingress_all" {
  network_security_group_id = oci_core_network_security_group.vulnerable_allow_all_nsg.id
  direction                 = "INGRESS"
  protocol                 = "all"
  source                   = "0.0.0.0/0"
  source_type              = "CIDR_BLOCK"
  description              = "NSG rule allowing all inbound traffic - DANGEROUS"
}

resource "oci_core_network_security_group_security_rule" "vulnerable_nsg_egress_all" {
  network_security_group_id = oci_core_network_security_group.vulnerable_allow_all_nsg.id
  direction                 = "EGRESS"
  protocol                 = "all"
  destination              = "0.0.0.0/0"
  destination_type         = "CIDR_BLOCK"
  description              = "NSG rule allowing all outbound traffic"
}

# ========================================
# SIN WAF - SIN PROTECCIÓN WEB
# ========================================
# Nota: Intencionalmente NO se despliega WAF para mostrar vulnerabilidades web

# ========================================
# SIN FLOW LOGS - SIN MONITOREO DE TRÁFICO
# ========================================
# Nota: Intencionalmente NO se configuran Flow Logs para mostrar falta de visibilidad

# ========================================
# SIN BASTIÓN - ACCESO DIRECTO INSEGURO
# ========================================
# Nota: Intencionalmente NO se despliega Bastion Service para mostrar acceso directo inseguro