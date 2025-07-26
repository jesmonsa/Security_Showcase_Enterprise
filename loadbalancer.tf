# Load Balancer (Flexible Shape 10-100 Mbps)
resource "oci_load_balancer_load_balancer" "public_lb" {
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "ocid::${var.cliente}::lb"
  shape          = "flexible"

  shape_details {
    minimum_bandwidth_in_mbps = var.lb_shape_config.minimum_bandwidth_in_mbps
    maximum_bandwidth_in_mbps = var.lb_shape_config.maximum_bandwidth_in_mbps
  }

  subnet_ids = [
    oci_core_subnet.public_lb_subnet_ad1.id,
    oci_core_subnet.public_lb_subnet_ad2.id
  ]
  is_private = false

  freeform_tags = merge(local.common_tags, {
    "Role"    = "LoadBalancer"
    "Service" = "HTTP/HTTPS"
  })

  lifecycle {
    ignore_changes = [defined_tags]
  }

  depends_on = [oci_core_subnet.public_lb_subnet_ad1, oci_core_subnet.public_lb_subnet_ad2]
}

# Load Balancer Backend Set
resource "oci_load_balancer_backend_set" "apache_backend_set" {
  name             = "apache-backend-set"
  load_balancer_id = oci_load_balancer_load_balancer.public_lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/health"
    return_code         = 200
    interval_ms         = 10000
    timeout_in_millis   = 3000
    retries             = 3
  }
}

# Load Balancer Backend (Apache Server)
resource "oci_load_balancer_backend" "apache_backend" {
  backendset_name  = oci_load_balancer_backend_set.apache_backend_set.name
  ip_address       = data.oci_core_vnic.apache_vnic.private_ip_address
  load_balancer_id = oci_load_balancer_load_balancer.public_lb.id
  port             = 80

  depends_on = [data.oci_core_vnic.apache_vnic]
}

# Self-signed certificate for HTTPS (for demo purposes)
resource "oci_load_balancer_certificate" "wildcard_cert" {
  count              = var.public_certificate != "" ? 1 : 0
  certificate_name   = local.certificate_name
  load_balancer_id   = oci_load_balancer_load_balancer.public_lb.id
  ca_certificate     = var.ca_certificate
  passphrase         = var.certificate_passphrase
  private_key        = var.certificate_private_key
  public_certificate = var.public_certificate

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [passphrase]
  }
}

# Load Balancer HTTPS Listener (if certificate is provided)
resource "oci_load_balancer_listener" "https_listener" {
  count                    = var.public_certificate != "" ? 1 : 0
  default_backend_set_name = oci_load_balancer_backend_set.apache_backend_set.name
  load_balancer_id         = oci_load_balancer_load_balancer.public_lb.id
  name                     = "https-listener"
  port                     = 443
  protocol                 = "HTTP"

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.wildcard_cert[0].certificate_name
    verify_peer_certificate = false
    protocols               = local.ssl_protocols
  }

  depends_on = [oci_load_balancer_certificate.wildcard_cert]
}

# Load Balancer HTTP Listener (always created)
resource "oci_load_balancer_listener" "http_listener" {
  default_backend_set_name = oci_load_balancer_backend_set.apache_backend_set.name
  load_balancer_id         = oci_load_balancer_load_balancer.public_lb.id
  name                     = "http-listener"
  port                     = 80
  protocol                 = "HTTP"
}

# WAF Edge Policy (Web Application Firewall) - Simplified Configuration
resource "oci_waas_waas_policy" "waf_policy" {
  count          = var.enable_waf ? 1 : 0
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "waf-${var.cliente}-demo"
  domain         = local.waf_domain

  origins {
    label = "primary-origin"
    uri   = "http://${oci_load_balancer_load_balancer.public_lb.ip_address_details[0].ip_address}"
  }

  policy_config {
    is_https_enabled = false
    is_https_forced  = false
  }

  waf_config {
    # Regla principal: Bloquear SQL Injection
    access_rules {
      name   = "block_sql_injection"
      action = "BLOCK"
      criteria {
        condition = "URL_PART_CONTAINS"
        value     = "' OR '"
      }
      block_action        = "SHOW_ERROR_PAGE"
      block_response_code = 403
    }

    # Bloquear XSS básico
    access_rules {
      name   = "block_xss_script"
      action = "BLOCK"
      criteria {
        condition = "URL_PART_CONTAINS"
        value     = "<script"
      }
      block_action        = "SHOW_ERROR_PAGE"
      block_response_code = 403
    }

    # Permitir tráfico legítimo
    access_rules {
      name   = "allow_legitimate"
      action = "ALLOW"
      criteria {
        condition = "URL_STARTS_WITH"
        value     = "/"
      }
    }
  }

  freeform_tags = merge(local.common_tags, {
    "Role"    = "WAF"
    "Service" = "WebSecurity"
  })

  depends_on = [
    oci_load_balancer_load_balancer.public_lb,
    oci_load_balancer_listener.http_listener
  ]
}