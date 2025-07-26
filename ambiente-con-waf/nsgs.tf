# Network Security Group for Apache Server
resource "oci_core_network_security_group" "nsg_apache" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "nsg-apache"

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Apache NSG Rules - HTTP Ingress
resource "oci_core_network_security_group_security_rule" "nsg_apache_ingress_80" {
  network_security_group_id = oci_core_network_security_group.nsg_apache.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }

  description = "Allow HTTP traffic from Internet"
}

# Apache NSG Rules - HTTPS Ingress
resource "oci_core_network_security_group_security_rule" "nsg_apache_ingress_443" {
  network_security_group_id = oci_core_network_security_group.nsg_apache.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }

  description = "Allow HTTPS traffic from Internet"
}

# Apache NSG Rules - SSH Ingress
resource "oci_core_network_security_group_security_rule" "nsg_apache_ingress_22" {
  network_security_group_id = oci_core_network_security_group.nsg_apache.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }

  description = "Allow SSH from Internet"
}

# Apache NSG Rules - All Egress
resource "oci_core_network_security_group_security_rule" "nsg_apache_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_apache.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"

  description = "Allow all outbound traffic"
}

# Network Security Group for Tomcat Server
resource "oci_core_network_security_group" "nsg_tomcat" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "nsg-tomcat"

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Tomcat NSG Rules - Port 8080 from Apache NSG only
resource "oci_core_network_security_group_security_rule" "nsg_tomcat_ingress_8080" {
  network_security_group_id = oci_core_network_security_group.nsg_tomcat.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = oci_core_network_security_group.nsg_apache.id
  source_type               = "NETWORK_SECURITY_GROUP"

  tcp_options {
    destination_port_range {
      min = 8080
      max = 8080
    }
  }

  description = "Allow Tomcat traffic only from Apache NSG"
}

# Tomcat NSG Rules - SSH from Bastion NSG only
resource "oci_core_network_security_group_security_rule" "nsg_tomcat_ingress_22" {
  network_security_group_id = oci_core_network_security_group.nsg_tomcat.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = oci_core_network_security_group.nsg_bastion.id
  source_type               = "NETWORK_SECURITY_GROUP"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }

  description = "Allow SSH only from Bastion NSG"
}

# Tomcat NSG Rules - All Egress
resource "oci_core_network_security_group_security_rule" "nsg_tomcat_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_tomcat.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"

  description = "Allow all outbound traffic"
}

# Network Security Group for Bastion Server
resource "oci_core_network_security_group" "nsg_bastion" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "nsg-bastion"

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Bastion NSG Rules - SSH Ingress from Internet
resource "oci_core_network_security_group_security_rule" "nsg_bastion_ingress_22" {
  network_security_group_id = oci_core_network_security_group.nsg_bastion.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }

  description = "Allow SSH from Internet"
}

# Bastion NSG Rules - All Egress
resource "oci_core_network_security_group_security_rule" "nsg_bastion_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_bastion.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"

  description = "Allow all outbound traffic"
}

# Network Security Group for Database
resource "oci_core_network_security_group" "nsg_database" {
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "nsg-database"

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Database NSG Rules - Oracle DB Port from Tomcat NSG
resource "oci_core_network_security_group_security_rule" "nsg_database_ingress_1521" {
  network_security_group_id = oci_core_network_security_group.nsg_database.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = oci_core_network_security_group.nsg_tomcat.id
  source_type               = "NETWORK_SECURITY_GROUP"

  tcp_options {
    destination_port_range {
      min = 1521
      max = 1521
    }
  }

  description = "Allow Oracle DB connections only from Tomcat NSG"
}

# Database NSG Rules - SSH from Bastion NSG
resource "oci_core_network_security_group_security_rule" "nsg_database_ingress_22" {
  network_security_group_id = oci_core_network_security_group.nsg_database.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = oci_core_network_security_group.nsg_bastion.id
  source_type               = "NETWORK_SECURITY_GROUP"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }

  description = "Allow SSH only from Bastion NSG"
}

# Database NSG Rules - All Egress
resource "oci_core_network_security_group_security_rule" "nsg_database_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_database.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"

  description = "Allow all outbound traffic"
}