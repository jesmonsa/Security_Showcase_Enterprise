# OCI Authentication and Configuration Variables

variable "tenancy_ocid" {
  description = "The OCID (Oracle Cloud Identifier) of the tenancy where resources will be created."
}

variable "user_ocid" {
  description = "The OCID of the user executing the Terraform scripts for provisioning resources."
}

variable "fingerprint" {
  description = "The fingerprint of the API signing key used for authenticating with OCI."
}

variable "private_key_path" {
  description = "The file path to the private key used for OCI API authentication."
}

variable "compartment_ocid" {
  description = "The OCID of the compartment where resources will be created. This is the parent compartment for the deployment."
}

variable "region" {
  description = "The region where OCI resources will be deployed, such as 'us-ashburn-1' or 'eu-frankfurt-1'."
}

# Customer Variables

variable "cliente" {
  description = "Nombre del cliente para nombrado de recursos"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9]*$", var.cliente))
    error_message = "cliente must start with a letter and contain only lowercase letters and numbers."
  }
}

variable "octetoB" {
  description = "Segundo octeto para CIDR de VCN (10.octetoB.0.0/16)"
  type        = string
  validation {
    condition     = can(regex("^[0-9]{1,3}$", var.octetoB)) && tonumber(var.octetoB) >= 0 && tonumber(var.octetoB) <= 255
    error_message = "octetoB must be a valid octet number between 0 and 255."
  }
}

# SSH Key Configuration

variable "ssh_key_pair_name" {
  description = "Nombre del par de claves SSH (opcional)"
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "Clave pública SSH (si no se genera automáticamente)"
  type        = string
  default     = null
}

# Database Variables

variable "db_password" {
  description = "Contraseña del administrador de la base de datos"
  type        = string
  sensitive   = true

  validation {
    condition = (
      length(var.db_password) >= 9 &&
      length(var.db_password) <= 30 &&
      length(regexall("[A-Z]", var.db_password)) >= 2 &&
      length(regexall("[a-z]", var.db_password)) >= 2 &&
      length(regexall("[0-9]", var.db_password)) >= 2 &&
      length(regexall("[_#-]", var.db_password)) >= 2 &&
      !can(regex("oracle", lower(var.db_password))) &&
      !can(regex("sys", lower(var.db_password))) &&
      !can(regex("admin", lower(var.db_password)))
    )
    error_message = "Password must be 9-30 chars with ≥2 uppercase, ≥2 lowercase, ≥2 numbers, ≥2 special chars (only _#-), and cannot contain 'oracle', 'sys', or 'admin'."
  }
}

variable "db_name" {
  description = "Oracle database name (1-8 alphanumeric chars, must start with letter)"
  type        = string
  default     = "FSCDB02"

  validation {
    condition     = length(var.db_name) <= 8 && length(var.db_name) >= 1 && can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.db_name))
    error_message = "db_name must be 1-8 chars, alphanumeric plus underscore, and start with a letter."
  }
}

variable "db_pdb_name" {
  description = "Oracle pluggable database name (1-8 alphanumeric chars, must start with letter)"
  type        = string
  default     = "FSCPDB02"

  validation {
    condition     = length(var.db_pdb_name) <= 8 && length(var.db_pdb_name) >= 1 && can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.db_pdb_name))
    error_message = "db_pdb_name must be 1-8 chars, alphanumeric plus underscore, and start with a letter."
  }
}

variable "db_node_hostname" {
  description = "Hostname for the database node (max 8 chars, lowercase alphanumeric)"
  type        = string
  default     = "dbhost"

  validation {
    condition     = length(var.db_node_hostname) <= 8 && can(regex("^[a-z][a-z0-9]*$", var.db_node_hostname))
    error_message = "db_node_hostname must be 1-8 chars, start with a letter, and be lowercase alphanumeric."
  }
}

variable "db_version" {
  description = "Version of the Oracle database"
  type        = string
  default     = "19.0.0.0"
}

variable "db_character_set" {
  description = "Character set for the database"
  type        = string
  default     = "AL32UTF8"
}

variable "db_ncharacter_set" {
  description = "National character set for the database"
  type        = string
  default     = "AL16UTF16"
}

variable "db_workload" {
  description = "Database workload type (OLTP or DSS)"
  type        = string
  default     = "OLTP"

  validation {
    condition     = contains(["OLTP", "DSS"], var.db_workload)
    error_message = "db_workload must be either OLTP or DSS."
  }
}

# Certificate Variables (for HTTPS Load Balancer)

variable "ca_certificate" {
  description = "CA certificate for HTTPS load balancer"
  type        = string
  default     = ""
}

variable "certificate_passphrase" {
  description = "Passphrase for the certificate private key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "certificate_private_key" {
  description = "Private key for the certificate"
  type        = string
  default     = ""
  sensitive   = true
}

variable "public_certificate" {
  description = "Public certificate for HTTPS"
  type        = string
  default     = ""
}

# Network Configuration

variable "enable_drg_propagation" {
  description = "Enable DRG route propagation"
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Enable WAF policy (automatically deployed with proper dependencies)"
  type        = bool
  default     = true
}

# Cloud Guard Security Configuration

variable "enable_cloud_guard" {
  description = "Habilitar Oracle Cloud Guard para monitoreo y detección de amenazas"
  type        = bool
  default     = false
}

# Compute Shapes Configuration

variable "apache_shape_config" {
  description = "Configuration for Apache VM (VM.Standard.E5.Flex)"
  type = object({
    ocpus         = number
    memory_in_gbs = number
  })
  default = {
    ocpus         = 2
    memory_in_gbs = 16
  }
}

variable "tomcat_shape_config" {
  description = "Configuration for Tomcat VM (VM.Standard.E5.Flex)"
  type = object({
    ocpus         = number
    memory_in_gbs = number
  })
  default = {
    ocpus         = 2
    memory_in_gbs = 16
  }
}

variable "bastion_shape_config" {
  description = "Configuration for Bastion VM (VM.Standard.A1.Flex)"
  type = object({
    ocpus         = number
    memory_in_gbs = number
  })
  default = {
    ocpus         = 2
    memory_in_gbs = 16
  }
}

# Database System Configuration

variable "db_shape_config" {
  description = "Configuration for Database System (VM.Standard.E5.Flex)"
  type = object({
    ocpus         = number
    memory_in_gbs = number
  })
  default = {
    ocpus         = 2
    memory_in_gbs = 32
  }
}

variable "db_storage_config" {
  description = "Storage configuration for Database System"
  type = object({
    data_storage_size_in_gb  = number
    total_storage_size_in_gb = number
  })
  default = {
    data_storage_size_in_gb  = 256
    total_storage_size_in_gb = 712
  }
}

# Load Balancer Configuration

variable "lb_shape_config" {
  description = "Configuration for flexible load balancer"
  type = object({
    minimum_bandwidth_in_mbps = number
    maximum_bandwidth_in_mbps = number
  })
  default = {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }
}

# WAF Configuration

variable "waf_domain_suffix" {
  description = "Dominio que apuntará al WAF (≤80 chars total)"
  type        = string
  default     = "waf-demo.oracledemo.com"

  validation {
    condition     = length(var.waf_domain_suffix) <= 60 && can(regex("^[A-Za-z0-9.-]+$", var.waf_domain_suffix))
    error_message = "waf_domain_suffix inválido (≤60 chars, solo A-Z, a-z, 0-9, . y -)."
  }
}