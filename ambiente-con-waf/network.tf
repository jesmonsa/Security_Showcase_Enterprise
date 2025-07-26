# Virtual Cloud Network (VCN)
resource "oci_core_vcn" "vcn" {
  compartment_id = oci_identity_compartment.compartment.id
  cidr_block     = local.vcn_cidr
  display_name   = "ocid::${var.cliente}::vcn"
  dns_label      = local.vcn_dns_label

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "igw" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "ocid::${var.cliente}::igw"
  vcn_id         = oci_core_vcn.vcn.id
  enabled        = true

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# NAT Gateway
resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "ocid::${var.cliente}::nat"
  vcn_id         = oci_core_vcn.vcn.id

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Service Gateway
resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "ocid::${var.cliente}::sgw"
  vcn_id         = oci_core_vcn.vcn.id

  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Dynamic Routing Gateway (DRG)
resource "oci_core_drg" "drg" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "ocid::${var.cliente}::drg"

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# DRG Attachment to VCN
resource "oci_core_drg_attachment" "drg_attachment" {
  drg_id = oci_core_drg.drg.id

  network_details {
    id   = oci_core_vcn.vcn.id
    type = "VCN"
  }

  display_name = "ocid::${var.cliente}::drg-attachment"

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Public Route Table (for Load Balancer and App subnets)
resource "oci_core_route_table" "public_rt" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "ocid::${var.cliente}::rt-public"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }

  dynamic "route_rules" {
    for_each = var.enable_drg_propagation ? [1] : []
    content {
      destination       = "10.0.0.0/8"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.drg.id
    }
  }

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Private Route Table (for Database subnet)
resource "oci_core_route_table" "private_rt" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "ocid::${var.cliente}::rt-private"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }

  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.service_gateway.id
  }

  dynamic "route_rules" {
    for_each = var.enable_drg_propagation ? [1] : []
    content {
      destination       = "10.0.0.0/8"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.drg.id
    }
  }

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Default Security List for VCN (minimal rules)
resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id
  display_name               = "ocid::${var.cliente}::sl-default"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Security List for Load Balancer subnet
resource "oci_core_security_list" "lb_security_list" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "ocid::${var.cliente}::sl-lb"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Private Database Subnet (/24)
resource "oci_core_subnet" "private_db_subnet" {
  availability_domain        = local.target_ad
  cidr_block                 = local.private_db_cidr
  compartment_id             = oci_identity_compartment.compartment.id
  vcn_id                     = oci_core_vcn.vcn.id
  display_name               = "ocid::${var.cliente}::subnet-private-db"
  dns_label                  = local.dns_db_label
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private_rt.id

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Public App Subnet (/24)
resource "oci_core_subnet" "public_app_subnet" {
  availability_domain = local.target_ad
  cidr_block          = local.public_app_cidr
  compartment_id      = oci_identity_compartment.compartment.id
  vcn_id              = oci_core_vcn.vcn.id
  display_name        = "ocid::${var.cliente}::subnet-public-app"
  dns_label           = local.dns_app_label
  route_table_id      = oci_core_route_table.public_rt.id

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Public Load Balancer Subnet AD-1 (/24) - Required for regional LB
resource "oci_core_subnet" "public_lb_subnet_ad1" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
  cidr_block          = "10.${var.octetoB}.2.0/24"
  compartment_id      = oci_identity_compartment.compartment.id
  vcn_id              = oci_core_vcn.vcn.id
  display_name        = "ocid::${var.cliente}::subnet-public-lb-ad1"
  dns_label           = "publbad1${substr(var.cliente, 0, min(6, length(var.cliente)))}"
  route_table_id      = oci_core_route_table.public_rt.id
  security_list_ids   = [oci_core_security_list.lb_security_list.id]

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Public Load Balancer Subnet AD-2 (/24) - Required for regional LB  
resource "oci_core_subnet" "public_lb_subnet_ad2" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[1].name
  cidr_block          = "10.${var.octetoB}.3.0/24"
  compartment_id      = oci_identity_compartment.compartment.id
  vcn_id              = oci_core_vcn.vcn.id
  display_name        = "ocid::${var.cliente}::subnet-public-lb-ad2"
  dns_label           = "publbad2${substr(var.cliente, 0, min(6, length(var.cliente)))}"
  route_table_id      = oci_core_route_table.public_rt.id
  security_list_ids   = [oci_core_security_list.lb_security_list.id]

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}