# Simple WAF Test Configuration
# This file is for testing WAF deployment in isolation

resource "oci_waas_waas_policy" "simple_waf_test" {
  count          = var.enable_waf ? 1 : 0
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "simple-waf-test-${var.cliente}"
  domain         = local.waf_domain

  origins {
    label = "primary-origin"
    uri   = "httpbin.org" # Using httpbin.org as test origin without protocol
  }

  policy_config {
    is_https_enabled = false
    is_https_forced  = false
  }

  waf_config {
    origin = "primary-origin" # Must reference the origin label defined above

    # Single rule to test WAF functionality
    access_rules {
      name   = "block_test_sql"
      action = "BLOCK"
      criteria {
        condition = "URL_PART_CONTAINS"
        value     = "' OR '"
      }
      block_action        = "SHOW_ERROR_PAGE"
      block_response_code = 403
    }

    # Allow legitimate traffic
    access_rules {
      name   = "allow_all"
      action = "ALLOW"
      criteria {
        condition = "URL_STARTS_WITH"
        value     = "/"
      }
    }
  }

  freeform_tags = {
    "Type" = "WAF-Test"
    "Demo" = "SecurityShowcase"
  }
}

# Output for testing
output "simple_waf_cname" {
  value = var.enable_waf ? oci_waas_waas_policy.simple_waf_test[0].cname : "WAF disabled"
}