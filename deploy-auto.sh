#!/bin/bash

# ========================================
# WAF SHOWCASE - DEPLOYMENT AUTOMÁTICO
# ========================================

set -e

echo "🚀 Iniciando deployment automático de WAF Showcase..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar que estamos en el directorio correcto
if [[ ! -f "terraform-CON-WAF.tfvars" ]]; then
    error "No se encuentra terraform-CON-WAF.tfvars. Ejecutar desde el directorio correcto."
    exit 1
fi

# Limpiar deployment anterior si existe
log "Limpiando estado anterior..."
if terraform state list > /dev/null 2>&1; then
    warning "Estado de Terraform existente detectado. Destruyendo recursos anteriores..."
    terraform destroy -var-file="terraform-CON-WAF.tfvars" -auto-approve || true
    
    # Limpiar estado problemático
    terraform state list | grep -E "(subnet|nsg)" | while read resource; do
        terraform state rm "$resource" || true
    done
fi

# Inicializar Terraform
log "Inicializando Terraform..."
terraform init
success "Terraform inicializado"

# Generar nombres únicos para esta ejecución
TIMESTAMP=$(date +%s)
CLIENT_NAME="wafshowcase${TIMESTAMP: -4}" # Últimos 4 dígitos del timestamp

log "Generando configuración única: cliente=$CLIENT_NAME"

# Crear archivo de configuración temporal
cat > terraform-auto.tfvars << EOF
# ========================================
# CONFIGURACIÓN AUTO-GENERADA
# ========================================
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaat65hqrreghdbi2yitpss4otjwsnqt67wyx77chcwk4inw7xovyga"
user_ocid        = "ocid1.user.oc1..aaaaaaaam5ou5z2wn2imc3ft4723od5jwuau2lvylrg5czf5amthfcnamlva"
fingerprint      = "a6:a4:22:4d:c8:84:d7:3d:81:da:eb:d6:49:85:aa:f3"
private_key_path = "/home/opc/.oci/oci_api_key.pem"
region           = "us-ashburn-1"
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaat65hqrreghdbi2yitpss4otjwsnqt67wyx77chcwk4inw7xovyga"

# Configuración única
cliente = "$CLIENT_NAME"
octetoB = "26"

# WAF habilitado
enable_waf         = true
enable_cloud_guard = false

# Base de datos con nombres únicos
db_password      = "DemoWAF2025_SecureP#ss-"
db_name          = "WAFDB${TIMESTAMP: -2}"
db_pdb_name      = "WAFPDB${TIMESTAMP: -2}"
db_node_hostname = "wafdb${TIMESTAMP: -2}"

# Configuración optimizada para demo
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

lb_shape_config = {
  minimum_bandwidth_in_mbps = 10
  maximum_bandwidth_in_mbps = 50
}

db_storage_config = {
  data_storage_size_in_gb  = 256
  total_storage_size_in_gb = 512
}

enable_drg_propagation = true
EOF

# Planear deployment
log "Planeando deployment..."
terraform plan -var-file="terraform-auto.tfvars" -out=tfplan

# Aplicar configuración
log "🚀 Desplegando infraestructura WAF Showcase..."
warning "Este proceso puede tomar 45-60 minutos debido a la base de datos..."

if terraform apply tfplan; then
    success "✅ Deployment completado exitosamente!"
    
    # Obtener outputs importantes
    log "📊 Información de acceso:"
    echo ""
    echo "🔴 SIN WAF (Vulnerable):"
    echo "   http://$(terraform output -raw load_balancer_fqdn 2>/dev/null || echo 'IP_LOAD_BALANCER')"
    echo ""
    echo "🟢 CON WAF (Protegido):"
    WAF_DOMAIN=$(terraform output -raw waf_domain 2>/dev/null || echo "${CLIENT_NAME}-waf-demo.oracledemo.com")
    LB_IP=$(terraform output -raw load_balancer_fqdn 2>/dev/null || echo 'IP_LOAD_BALANCER')
    echo "   http://$WAF_DOMAIN"
    echo ""
    echo "⚙️  Para acceder al dominio WAF, agregar a /etc/hosts:"
    echo "   echo \"$LB_IP $WAF_DOMAIN\" | sudo tee -a /etc/hosts"
    echo ""
    echo "🔑 Acceso SSH:"
    terraform output connection_info 2>/dev/null || echo "Ver terraform output connection_info"
    echo ""
    echo "📋 Compartment: cmp-$CLIENT_NAME"
    echo "📋 VCN CIDR: 10.26.0.0/16"
    
    # Guardar información para limpieza posterior
    echo "$CLIENT_NAME" > .last_deployment
    echo "terraform-auto.tfvars" >> .last_deployment
    
else
    error "❌ Deployment falló"
    exit 1
fi

log "🎯 Deployment automático completado"