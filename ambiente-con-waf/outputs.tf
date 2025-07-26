# Infrastructure Outputs

# Compartment and Networking
output "compartment_ocid" {
  description = "OCID del compartment creado"
  value       = oci_identity_compartment.compartment.id
}

output "vcn_ocid" {
  description = "OCID de la VCN"
  value       = oci_core_vcn.vcn.id
}

output "vcn_cidr" {
  description = "CIDR de la VCN"
  value       = oci_core_vcn.vcn.cidr_block
}

# Load Balancer Information
output "load_balancer_fqdn" {
  description = "FQDN del Load Balancer"
  value       = length(oci_load_balancer_load_balancer.public_lb.ip_address_details) > 0 ? [for ip in oci_load_balancer_load_balancer.public_lb.ip_address_details : ip.ip_address if ip.is_public][0] : "N/A"
}

output "load_balancer_ocid" {
  description = "OCID del Load Balancer"
  value       = oci_load_balancer_load_balancer.public_lb.id
}

output "waf_domain" {
  description = "Dominio configurado en WAF"
  value       = var.enable_waf ? oci_waas_waas_policy.waf_policy[0].domain : "WAF deshabilitado"
}

output "waf_ocid" {
  description = "OCID de la política WAF"
  value       = var.enable_waf ? oci_waas_waas_policy.waf_policy[0].id : "WAF deshabilitado"
}

output "waf_cname_target" {
  description = "CNAME target para configurar DNS hacia el WAF"
  value       = var.enable_waf ? oci_waas_waas_policy.waf_policy[0].cname : "WAF deshabilitado"
}

output "waf_status" {
  description = "Estado del WAF"
  value       = var.enable_waf ? "HABILITADO - Protección activa" : "DESHABILITADO"
}

# Cloud Guard Security Information
output "cloud_guard_status" {
  description = "Estado de Cloud Guard"
  value       = var.enable_cloud_guard ? "HABILITADO" : "DESHABILITADO"
}

output "cloud_guard_target_ocid" {
  description = "OCID del target de Cloud Guard"
  value       = var.enable_cloud_guard ? oci_cloud_guard_target.security_target[0].id : "CloudGuard deshabilitado"
}

output "cloudguard_log_group_ocid" {
  description = "OCID del Log Group de Cloud Guard"
  value       = var.enable_cloud_guard ? oci_logging_log_group.cloudguard_log_group[0].id : "CloudGuard logging deshabilitado"
}

# Apache Server Information
output "apache_public_ip" {
  description = "IP pública de Apache Server"
  value       = data.oci_core_vnic.apache_vnic.public_ip_address
}

output "apache_private_ip" {
  description = "IP privada de Apache Server"
  value       = data.oci_core_vnic.apache_vnic.private_ip_address
}

output "apache_ocid" {
  description = "OCID de la instancia Apache"
  value       = oci_core_instance.apache_vm.id
}

# Tomcat Server Information
output "tomcat_private_ip" {
  description = "IP privada de Tomcat Server"
  value       = data.oci_core_vnic.tomcat_vnic.private_ip_address
}

output "tomcat_ocid" {
  description = "OCID de la instancia Tomcat"
  value       = oci_core_instance.tomcat_vm.id
}

# Bastion Server Information
output "bastion_public_ip" {
  description = "IP pública del Bastion Host"
  value       = data.oci_core_vnic.bastion_vnic.public_ip_address
}

output "bastion_private_ip" {
  description = "IP privada del Bastion Host"
  value       = data.oci_core_vnic.bastion_vnic.private_ip_address
}

output "bastion_ocid" {
  description = "OCID de la instancia Bastion"
  value       = oci_core_instance.bastion_vm.id
}

# Database Information
output "database_private_ip" {
  description = "IP privada del Database System"
  value       = data.oci_core_vnic.db_vnic.private_ip_address
}

output "database_ocid" {
  description = "OCID del Database System"
  value       = oci_database_db_system.db_system.id
}

output "database_name" {
  description = "Nombre de la base de datos"
  value       = local.db_name
}

output "database_pdb_name" {
  description = "Nombre de la PDB"
  value       = local.db_pdb_name
}

# Storage Information
output "bucket_name" {
  description = "Nombre del bucket de Object Storage"
  value       = oci_objectstorage_bucket.shared_bucket.name
}

output "bucket_ocid" {
  description = "OCID del bucket de Object Storage"
  value       = oci_objectstorage_bucket.shared_bucket.id
}

# SSH Keys Information
output "ssh_public_key" {
  description = "Clave pública SSH generada"
  value       = tls_private_key.ssh_key.public_key_openssh
}

output "ssh_private_key_pem" {
  description = "Clave privada SSH en formato PEM (sensible)"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

# Network Security Groups
output "nsg_apache_ocid" {
  description = "OCID del NSG de Apache"
  value       = oci_core_network_security_group.nsg_apache.id
}

output "nsg_tomcat_ocid" {
  description = "OCID del NSG de Tomcat"
  value       = oci_core_network_security_group.nsg_tomcat.id
}

output "nsg_bastion_ocid" {
  description = "OCID del NSG de Bastion"
  value       = oci_core_network_security_group.nsg_bastion.id
}

output "nsg_database_ocid" {
  description = "OCID del NSG de Database"
  value       = oci_core_network_security_group.nsg_database.id
}

# Subnet Information
output "private_db_subnet_ocid" {
  description = "OCID de la subred privada de base de datos"
  value       = oci_core_subnet.private_db_subnet.id
}

output "public_app_subnet_ocid" {
  description = "OCID de la subred pública de aplicación"
  value       = oci_core_subnet.public_app_subnet.id
}

output "public_lb_subnet_ad1_ocid" {
  description = "OCID de la subred pública del load balancer AD-1"
  value       = oci_core_subnet.public_lb_subnet_ad1.id
}

output "public_lb_subnet_ad2_ocid" {
  description = "OCID de la subred pública del load balancer AD-2"
  value       = oci_core_subnet.public_lb_subnet_ad2.id
}

# Access Information
output "architecture_summary" {
  description = "Resumen de la arquitectura desplegada"
  value = {
    cliente           = var.cliente
    vcn_cidr          = local.vcn_cidr
    load_balancer_ip  = length(oci_load_balancer_load_balancer.public_lb.ip_address_details) > 0 ? [for ip in oci_load_balancer_load_balancer.public_lb.ip_address_details : ip.ip_address if ip.is_public][0] : "N/A"
    apache_public_ip  = data.oci_core_vnic.apache_vnic.public_ip_address
    bastion_public_ip = data.oci_core_vnic.bastion_vnic.public_ip_address
    waf_domain        = var.enable_waf ? oci_waas_waas_policy.waf_policy[0].domain : "WAF deshabilitado"
    database_name     = local.db_name
  }
}

# Connection Information
output "connection_info" {
  description = "Información de conexión"
  value = {
    ssh_apache             = "ssh -i <private_key> opc@${data.oci_core_vnic.apache_vnic.public_ip_address}"
    ssh_bastion            = "ssh -i <private_key> opc@${data.oci_core_vnic.bastion_vnic.public_ip_address}"
    ssh_tomcat_via_bastion = "ssh -i <private_key> -J opc@${data.oci_core_vnic.bastion_vnic.public_ip_address} opc@${data.oci_core_vnic.tomcat_vnic.private_ip_address}"
    http_access            = "http://${length(oci_load_balancer_load_balancer.public_lb.ip_address_details) > 0 ? [for ip in oci_load_balancer_load_balancer.public_lb.ip_address_details : ip.ip_address if ip.is_public][0] : "N/A"}"
    https_access           = var.public_certificate != "" ? "https://${local.waf_domain}" : "HTTPS not configured - provide certificate variables"
  }
}