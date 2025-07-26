# Home Region Subscription DataSource
data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

# ADs DataSource
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Oracle Linux Images DataSource for E5 Flex Shapes
data "oci_core_images" "ol9_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = "VM.Standard.E5.Flex"

  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-9.*$"]
    regex  = true
  }

  filter {
    name   = "state"
    values = ["AVAILABLE"]
  }
}

# Oracle Linux Images DataSource for A1 Flex Shapes (ARM-based)
data "oci_core_images" "ol9_arm_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = "VM.Standard.A1.Flex"

  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-9.*aarch64.*$"]
    regex  = true
  }

  filter {
    name   = "state"
    values = ["AVAILABLE"]
  }
}

# Object Storage Namespace DataSource
data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.tenancy_ocid
}

# All Services DataSource for Service Gateway
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# Apache VM VNIC Attachment DataSource
data "oci_core_vnic_attachments" "apache_vnic_attach" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
  compartment_id      = oci_identity_compartment.compartment.id
  instance_id         = oci_core_instance.apache_vm.id
  depends_on          = [oci_core_instance.apache_vm]
}

# Apache VM VNIC DataSource
data "oci_core_vnic" "apache_vnic" {
  vnic_id = data.oci_core_vnic_attachments.apache_vnic_attach.vnic_attachments.0.vnic_id
}

# Tomcat VM VNIC Attachment DataSource
data "oci_core_vnic_attachments" "tomcat_vnic_attach" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
  compartment_id      = oci_identity_compartment.compartment.id
  instance_id         = oci_core_instance.tomcat_vm.id
  depends_on          = [oci_core_instance.tomcat_vm]
}

# Tomcat VM VNIC DataSource
data "oci_core_vnic" "tomcat_vnic" {
  vnic_id = data.oci_core_vnic_attachments.tomcat_vnic_attach.vnic_attachments.0.vnic_id
}

# Bastion VM VNIC Attachment DataSource
data "oci_core_vnic_attachments" "bastion_vnic_attach" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
  compartment_id      = oci_identity_compartment.compartment.id
  instance_id         = oci_core_instance.bastion_vm.id
  depends_on          = [oci_core_instance.bastion_vm]
}

# Bastion VM VNIC DataSource
data "oci_core_vnic" "bastion_vnic" {
  vnic_id = data.oci_core_vnic_attachments.bastion_vnic_attach.vnic_attachments.0.vnic_id
}

# DB System DB Nodes DataSource
data "oci_database_db_nodes" "db_nodes" {
  compartment_id = oci_identity_compartment.compartment.id
  db_system_id   = oci_database_db_system.db_system.id
  depends_on     = [oci_database_db_system.db_system]
}

# DB Node Details DataSource
data "oci_database_db_node" "db_node_details" {
  db_node_id = data.oci_database_db_nodes.db_nodes.db_nodes[0].id
}

# DB System VNIC DataSource
data "oci_core_vnic" "db_vnic" {
  vnic_id = data.oci_database_db_node.db_node_details.vnic_id
}