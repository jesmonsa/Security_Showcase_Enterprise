# ========================================
# CREDENCIALES OCI
# ========================================
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaat65hqrreghdbi2yitpss4otjwsnqt67wyx77chcwk4inw7xovyga"
user_ocid        = "ocid1.user.oc1..aaaaaaaam5ou5z2wn2imc3ft4723od5jwuau2lvylrg5czf5amthfcnamlva"
fingerprint      = "a6:a4:22:4d:c8:84:d7:3d:81:da:eb:d6:49:85:aa:f3"
private_key_path = "/home/jesmonsa/.oci/oci_api_key.pem"
region           = "us-ashburn-1"
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaat65hqrreghdbi2yitpss4otjwsnqt67wyx77chcwk4inw7xovyga"

# ========================================
# CONFIGURACIÓN DE SHOWCASE EMPRESARIAL
# CON SEGURIDAD COMPLETA (WAF + CLOUD GUARD)
# ========================================
# Esta configuración muestra la aplicación CON protección completa
# para demostrar las capacidades de seguridad de OCI

# Información del cliente
cliente = "wafshowcase"
octetoB = "25"

# IMPORTANTE: SEGURIDAD WAF HABILITADA (Cloud Guard deshabilitado por permisos)
enable_waf         = true
enable_cloud_guard = false

# Base de datos (requerida) - Nombres únicos con timestamp
db_password      = "DemoWAF2025_SecureP#ss-"
db_name          = "WAFDB01"
db_pdb_name      = "WAFPDB01"
db_node_hostname = "wafdb"

# Configuración de shapes (optimizada para demo)
apache_shape_config = {
  ocpus         = 1
  memory_in_gbs = 8
}

tomcat_shape_config = {
  ocpus         = 1
  memory_in_gbs = 8
}

bastion_shape_config = {
  ocpus         = 1
  memory_in_gbs = 8
}

db_shape_config = {
  ocpus         = 1
  memory_in_gbs = 16
}

# Load Balancer (configuración mínima para demo)
lb_shape_config = {
  minimum_bandwidth_in_mbps = 10
  maximum_bandwidth_in_mbps = 50
}

# Storage (configuración mínima)
db_storage_config = {
  data_storage_size_in_gb  = 256
  total_storage_size_in_gb = 512
}

# Configuración de red
enable_drg_propagation = true