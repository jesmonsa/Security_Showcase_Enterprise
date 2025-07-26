# ========================================
# MÓDULO DATABASE VULNERABLE - Oracle 23ai SIN protecciones
# Deliberadamente inseguro para demostración
# ========================================

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.21.0"
    }
  }
}

# ========================================
# AUTONOMOUS DATABASE 23ai - CONFIGURACIÓN INSEGURA
# ========================================

resource "oci_database_autonomous_database" "vulnerable_adb_23ai" {
  compartment_id = var.compartment_ocid
  
  # Oracle 23ai - la versión más reciente PERO sin protecciones
  db_version   = "23ai"
  db_name      = var.db_name
  display_name = "${var.environment}-vulnerable-oracle-23ai"
  
  # INSEGURO: CPU mínimo para demo pero sin protecciones
  cpu_core_count       = 1
  data_storage_size_in_tbs = 1
  
  # CRÍTICO: Password débil y predecible
  admin_password = var.use_weak_passwords ? "Welcome123!" : "StrongP@ssw0rd123!"
  
  # PELIGROSO: En subnet pública
  subnet_id = var.subnet_id
  
  # INSEGURO: Acceso desde internet permitido
  is_access_control_enabled = false  # Sin whitelist de IPs
  whitelisted_ips          = []      # Sin restricción de IPs
  
  # CRÍTICO: Sin cifrado con customer-managed keys
  # Se usa encryption por defecto de Oracle (menos seguro que customer keys)
  
  # INSEGURO: Backup automático SIN cifrado adicional
  is_auto_scaling_enabled = false
  
  # PELIGROSO: Data Safe DESHABILITADO
  is_data_guard_enabled = false
  
  # Database workload - OLTP para aplicación web vulnerable
  db_workload = "OLTP"
  
  # INSEGURO: Sin private endpoint
  # is_dedicated = false significa que usa infraestructura compartida
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-vulnerable-oracle-23ai"
    Type = "vulnerable-database"
    Version = "23ai"
    Security = "DISABLED"
    Risk = "CRITICAL"
    DatabaseFirewall = "DISABLED"
    DataSafe = "DISABLED"
    Encryption = "DEFAULT_ONLY"
  })
}

# ========================================
# DATABASE FIREWALL - DELIBERADAMENTE DESHABILITADO
# ========================================
# Nota: En Oracle 23ai, Database Firewall se configura a nivel de database
# Aquí intencionalmente NO se configura para mostrar vulnerabilidades

# Para demostrar lo que NO se debe hacer, se podría configurar así:
# resource "oci_database_autonomous_database_wallet" "vulnerable_wallet" {
#   autonomous_database_id = oci_database_autonomous_database.vulnerable_adb_23ai.id
#   password              = "WeakWalletPassword123"  # INSEGURO
#   generate_type         = "SINGLE"
# }

# ========================================
# DATA SAFE - DESHABILITADO
# ========================================
# Data Safe NO se registra para esta base de datos vulnerable
# Esto significa: Sin assessment de vulnerabilidades, sin monitoring, sin auditoría avanzada

# ========================================
# CONFIGURACIÓN DE RED INSEGURA
# ========================================

# Database Security List - Ya configurada en el módulo de network como ABIERTA
# Puerto 1521 abierto a 0.0.0.0/0

# ========================================
# BACKUP CONFIGURATION - SIN CIFRADO ADICIONAL
# ========================================
# El backup automático está habilitado por defecto PERO:
# - Sin cifrado con customer-managed keys
# - Sin cross-region backup
# - Sin configuración de retención extendida

# ========================================
# DATABASE USERS - CONFIGURACIÓN INSEGURA
# ========================================

# Nota: En Autonomous Database, la creación de usuarios se hace vía SQL
# Aquí documentamos las prácticas inseguras que se implementarían:

# 1. Usuario ADMIN con password débil (ya configurado arriba)
# 2. Usuarios adicionales sin privilegios restringidos
# 3. Service accounts sin rotación de passwords
# 4. Conexiones sin cifrado enforcement

# ========================================
# CONNECTION STRINGS - SIN CIFRADO ENFORCEMENT
# ========================================

# La connection string permitirá conexiones HTTP (sin cifrado)
# Autonomous Database por defecto require SSL, pero puede ser bypasseado

# ========================================
# AUDIT LOGGING - MÍNIMO
# ========================================
# Solo audit logging básico habilitado, sin configuración comprehensiva

# ========================================
# VULNERABILITY ASSESSMENT - DESHABILITADO
# ========================================
# Sin Data Safe, no hay vulnerability assessment automático

# ========================================
# PERFORMANCE MONITORING - BÁSICO
# ========================================
# Sin monitoreo avanzado de seguridad, solo performance básico

# ========================================
# SQL INJECTION PROTECTION - DESHABILITADO
# ========================================
# Sin Database Firewall, no hay protección contra SQL injection a nivel de DB

# ========================================
# OUTPUTS PARA CONEXIÓN INSEGURA
# ========================================

# Connection details expuestos para uso por aplicación vulnerable
locals {
  # Connection string básico (menos seguro)
  connection_string_basic = "${oci_database_autonomous_database.vulnerable_adb_23ai.connection_urls[0].profiles[0].host_format}"
  
  # Service name para conexiones directas
  service_name = oci_database_autonomous_database.vulnerable_adb_23ai.service_console_url
}

# ========================================
# DOCUMENTACIÓN DE VULNERABILIDADES
# ========================================

# Este módulo implementa deliberadamente las siguientes vulnerabilidades:

# 1. ORACLE 23ai SIN Database Firewall
#    - No hay filtrado de SQL queries maliciosas
#    - SQL injection puede pasar directo a la base de datos
#    - No hay detección de patrones de ataque

# 2. Data Safe DESHABILITADO
#    - Sin vulnerability assessment
#    - Sin data discovery y classification
#    - Sin activity auditing avanzado
#    - Sin user risk assessment

# 3. Configuración de Red Insegura
#    - Base de datos en subnet pública
#    - Puerto 1521 abierto a internet
#    - Sin private endpoint

# 4. Cifrado Básico
#    - Solo encryption at rest por defecto
#    - Sin customer-managed keys
#    - Sin TDE (Transparent Data Encryption) avanzado

# 5. Backup Inseguro
#    - Backups sin cifrado adicional
#    - Sin cross-region replication
#    - Sin retention extendida

# 6. Access Control Débil
#    - Passwords débiles
#    - Sin MFA para admin
#    - Sin IP whitelisting
#    - Acceso desde cualquier IP

# 7. Monitoring Limitado
#    - Sin Cloud Guard integration
#    - Sin security alerts
#    - Audit logging mínimo

# 8. Compliance
#    - No cumple PCI DSS
#    - No cumple SOX requirements
#    - No cumple GDPR data protection