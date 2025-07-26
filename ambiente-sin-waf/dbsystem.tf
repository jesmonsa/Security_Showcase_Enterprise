# Oracle Database System (VM.Standard.E5.Flex 2 OCPU / 32 GB, 712 GB total storage)
resource "oci_database_db_system" "db_system" {
  availability_domain = local.target_ad
  compartment_id      = oci_identity_compartment.compartment.id
  display_name        = "ocid::${var.cliente}::dbsystem"
  shape               = "VM.Standard.E5.Flex"

  cpu_core_count                  = var.db_shape_config.ocpus
  data_storage_size_in_gb         = var.db_storage_config.data_storage_size_in_gb
  storage_volume_performance_mode = local.db_storage_performance

  database_edition = "ENTERPRISE_EDITION_HIGH_PERFORMANCE"

  db_home {
    database {
      admin_password = var.db_password
      db_name        = local.db_name
      db_unique_name = local.db_name
      character_set  = var.db_character_set
      ncharacter_set = var.db_ncharacter_set
      db_workload    = var.db_workload
      pdb_name       = local.db_pdb_name

      freeform_tags = merge(local.common_tags, {
        "Role"    = "Database"
        "Service" = "Oracle"
      })
    }

    db_version   = var.db_version
    display_name = "ocid::${var.cliente}::dbhome"

    freeform_tags = merge(local.common_tags, {
      "Role"    = "DatabaseHome"
      "Service" = "Oracle"
    })
  }

  hostname        = "${var.db_node_hostname}${substr(var.cliente, 0, min(2, length(var.cliente)))}"
  ssh_public_keys = [coalesce(var.ssh_public_key, tls_private_key.ssh_key.public_key_openssh)]
  subnet_id       = oci_core_subnet.private_db_subnet.id
  disk_redundancy = "NORMAL"
  license_model   = "BRING_YOUR_OWN_LICENSE"
  node_count      = 1
  nsg_ids         = [oci_core_network_security_group.nsg_database.id]

  freeform_tags = merge(local.common_tags, {
    "Role"        = "DatabaseSystem"
    "Service"     = "Oracle"
    "Performance" = "HighPerformance"
  })

  lifecycle {
    ignore_changes = [defined_tags]
  }

  timeouts {
    create = "120m"
    update = "120m"
    delete = "60m"
  }

  depends_on = [oci_core_subnet.private_db_subnet, oci_core_network_security_group.nsg_database]
}