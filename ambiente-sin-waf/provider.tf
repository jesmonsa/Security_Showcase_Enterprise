terraform {
  required_version = ">= 1.4.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.21.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}

# Configure the OCI provider with the default region
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region

  # Mejora resiliencia frente a 429 y timeouts
  disable_auto_retries = false
}

# Home Region Provider - Used for IAM operations that must be performed in the home region
provider "oci" {
  alias                = "homeregion"
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  region               = data.oci_identity_region_subscriptions.home_region_subscriptions.region_subscriptions[0].region_name
  disable_auto_retries = true
}