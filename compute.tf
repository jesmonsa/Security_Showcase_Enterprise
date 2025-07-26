# Apache VM (VM.Standard.E5.Flex 2 OCPU / 16 GB, 100 GB boot volume)
resource "oci_core_instance" "apache_vm" {
  availability_domain = local.target_ad
  compartment_id      = oci_identity_compartment.compartment.id
  display_name        = "ocid::${var.cliente}::apache"
  shape               = "VM.Standard.E5.Flex"

  shape_config {
    ocpus                     = var.apache_shape_config.ocpus
    memory_in_gbs             = var.apache_shape_config.memory_in_gbs
    baseline_ocpu_utilization = "BASELINE_1_1"
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.public_app_subnet.id
    display_name              = "ocid::${var.cliente}::apache-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = "apache-${var.cliente}"
    nsg_ids                   = [oci_core_network_security_group.nsg_apache.id]
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ol9_images.images[0].id
    boot_volume_size_in_gbs = 100
  }

  metadata = {
    ssh_authorized_keys = coalesce(var.ssh_public_key, tls_private_key.ssh_key.public_key_openssh)
    user_data = base64encode(templatefile("${path.module}/cloud-init/apache-vulnerable.sh", {
      cliente = var.cliente
    }))
  }

  freeform_tags = merge(local.common_tags, {
    "Role"    = "WebServer"
    "Service" = "Apache"
  })

  lifecycle {
    ignore_changes = [defined_tags, source_details[0].source_id]
  }

  depends_on = [oci_core_subnet.public_app_subnet]
}

# Note: Boot volume encryption is configured at the instance level
# in the source_details block of oci_core_instance resources

# Tomcat VM (VM.Standard.E5.Flex 2 OCPU / 16 GB, 100 GB boot volume)
resource "oci_core_instance" "tomcat_vm" {
  availability_domain = local.target_ad
  compartment_id      = oci_identity_compartment.compartment.id
  display_name        = "ocid::${var.cliente}::tomcat"
  shape               = "VM.Standard.E5.Flex"

  shape_config {
    ocpus                     = var.tomcat_shape_config.ocpus
    memory_in_gbs             = var.tomcat_shape_config.memory_in_gbs
    baseline_ocpu_utilization = "BASELINE_1_1"
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.private_db_subnet.id
    display_name              = "ocid::${var.cliente}::tomcat-vnic"
    assign_public_ip          = false
    assign_private_dns_record = true
    hostname_label            = "tomcat-${var.cliente}"
    nsg_ids                   = [oci_core_network_security_group.nsg_tomcat.id]
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ol9_images.images[0].id
    boot_volume_size_in_gbs = 100
  }

  metadata = {
    ssh_authorized_keys = coalesce(var.ssh_public_key, tls_private_key.ssh_key.public_key_openssh)
    user_data = base64encode(templatefile("${path.module}/cloud-init/tomcat-userdata.sh", {
      cliente = var.cliente
    }))
  }

  freeform_tags = merge(local.common_tags, {
    "Role"    = "ApplicationServer"
    "Service" = "Tomcat"
  })

  lifecycle {
    ignore_changes = [defined_tags, source_details[0].source_id]
  }

  depends_on = [oci_core_subnet.private_db_subnet]
}

# Bastion VM (VM.Standard.A1.Flex 2 OCPU / 16 GB, 50 GB boot volume)
resource "oci_core_instance" "bastion_vm" {
  availability_domain = local.target_ad
  compartment_id      = oci_identity_compartment.compartment.id
  display_name        = "ocid::${var.cliente}::bastion"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus                     = var.bastion_shape_config.ocpus
    memory_in_gbs             = var.bastion_shape_config.memory_in_gbs
    baseline_ocpu_utilization = "BASELINE_1_1"
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.public_app_subnet.id
    display_name              = "ocid::${var.cliente}::bastion-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = "bastion-${var.cliente}"
    nsg_ids                   = [oci_core_network_security_group.nsg_bastion.id]
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ol9_arm_images.images[0].id
    boot_volume_size_in_gbs = 50
  }

  metadata = {
    ssh_authorized_keys = coalesce(var.ssh_public_key, tls_private_key.ssh_key.public_key_openssh)
    user_data = base64encode(templatefile("${path.module}/cloud-init/bastion-userdata.sh", {
      cliente = var.cliente
    }))
  }

  freeform_tags = merge(local.common_tags, {
    "Role"    = "BastionHost"
    "Service" = "SSH"
  })

  lifecycle {
    ignore_changes = [defined_tags, source_details[0].source_id]
  }

  depends_on = [oci_core_subnet.public_app_subnet]
}