# Compartment for FSC Reference Architecture
resource "oci_identity_compartment" "compartment" {
  provider       = oci.homeregion
  compartment_id = var.compartment_ocid
  description    = "Landing zone para app Apache-Tomcat-DB"
  name           = local.compartment_name
  enable_delete  = true

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Object Storage Bucket
resource "oci_objectstorage_bucket" "shared_bucket" {
  compartment_id = oci_identity_compartment.compartment.id
  name           = local.bucket_name
  namespace      = data.oci_objectstorage_namespace.namespace.namespace
  storage_tier   = "Standard"
  versioning     = "Disabled"

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}