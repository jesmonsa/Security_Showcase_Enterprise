#!/bin/bash

# ========================================
# DEPLOYMENT AUTOMÁTICO - AMBIENTE CON WAF
# ========================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Banner
echo -e "${GREEN}"
echo "██████╗ ██████╗  ██████╗ ████████╗███████╗ ██████╗ ██╗██████╗  ██████╗ "
echo "██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██╔════╝ ██║██╔══██╗██╔═══██╗"
echo "██████╔╝██████╔╝██║   ██║   ██║   █████╗  ██║  ███╗██║██║  ██║██║   ██║"
echo "██╔═══╝ ██╔══██╗██║   ██║   ██║   ██╔══╝  ██║   ██║██║██║  ██║██║   ██║"
echo "██║     ██║  ██║╚██████╔╝   ██║   ███████╗╚██████╔╝██║██████╔╝╚██████╔╝"
echo "╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚══════╝ ╚═════╝ ╚═╝╚═════╝  ╚═════╝ "
echo -e "${NC}"

echo -e "${GREEN}🟢 AMBIENTE PROTEGIDO - CON WAF${NC}"
echo -e "${GREEN}✅ Este ambiente TIENE protecciones completas de seguridad${NC}"
echo ""

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

# Verificar directorio
if [[ ! -d "ambiente-con-waf" ]]; then
    error "Directorio ambiente-con-waf no encontrado. Ejecutar desde directorio raíz del proyecto."
    exit 1
fi

# Cambiar al directorio de trabajo
cd ambiente-con-waf

log "🚀 Iniciando deployment del ambiente CON WAF..."

# Verificar archivos necesarios
if [[ ! -f "terraform.tfvars" ]]; then
    error "Archivo terraform.tfvars no encontrado en ambiente-con-waf/"
    exit 1
fi

# Mostrar configuración
echo -e "${BLUE}📋 Configuración del deployment:${NC}"
echo -e "${BLUE}   Cliente: $(grep '^cliente' terraform.tfvars | cut -d'"' -f2)${NC}"
echo -e "${BLUE}   Octeto B: $(grep '^octetoB' terraform.tfvars | cut -d'"' -f2)${NC}"
echo -e "${BLUE}   WAF: $(grep '^enable_waf' terraform.tfvars | cut -d'=' -f2 | tr -d ' ')${NC}"
echo -e "${BLUE}   Dominio WAF: $(grep '^waf_domain_suffix' terraform.tfvars | cut -d'"' -f2)${NC}"
echo ""

# Confirmación
read -p "$(echo -e ${PURPLE}"¿Continuar con el deployment? (y/N): "${NC}) -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelado."
    exit 0
fi

# Limpiar estado anterior si existe
if [[ -f "terraform.tfstate" ]]; then
    warning "Estado de Terraform existente detectado."
    read -p "$(echo -e ${PURPLE}"¿Destruir recursos existentes? (y/N): "${NC}) -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Destruyendo recursos anteriores..."
        terraform destroy -auto-approve || true
        success "Recursos anteriores destruidos"
    fi
fi

# Inicializar Terraform
log "Inicializando Terraform..."
terraform init
success "Terraform inicializado"

# Planear deployment
log "Generando plan de deployment..."
terraform plan -out=tfplan-con-waf
success "Plan generado exitosamente"

# Aplicar configuración
log "🚀 Desplegando infraestructura CON WAF..."
warning "Este proceso puede tomar 45-60 minutos debido a la base de datos..."
echo ""

# Mostrar progreso
echo -e "${BLUE}📊 Componentes a desplegar:${NC}"
echo -e "${BLUE}   • Compartment y VCN${NC}"
echo -e "${BLUE}   • Network Security Groups${NC}"
echo -e "${BLUE}   • Load Balancer${NC}"
echo -e "${BLUE}   • Oracle WAF con políticas de seguridad${NC}"
echo -e "${BLUE}   • Servidores Apache y Tomcat${NC}"
echo -e "${BLUE}   • Bastion Host${NC}"
echo -e "${BLUE}   • Oracle Database System (45-50 min)${NC}"
echo ""

if terraform apply tfplan-con-waf; then
    success "✅ Deployment completado exitosamente!"
    
    # Esperar a que los servicios estén listos
    log "Esperando que los servicios estén completamente listos (30 segundos)..."
    sleep 30
    
    echo ""
    echo -e "${GREEN}🎉 AMBIENTE CON WAF DESPLEGADO EXITOSAMENTE${NC}"
    echo ""
    
    # Obtener información importante
    log "📊 Información de acceso:"
    echo ""
    
    # URLs de acceso
    LB_IP=$(terraform output -raw load_balancer_fqdn 2>/dev/null || echo "No disponible")
    APACHE_IP=$(terraform output -raw apache_public_ip 2>/dev/null || echo "No disponible")
    BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null || echo "No disponible")
    WAF_DOMAIN=$(terraform output -raw waf_domain 2>/dev/null || echo "No disponible")
    WAF_OCID=$(terraform output -raw waf_ocid 2>/dev/null || echo "No disponible")
    CLIENTE=$(grep '^cliente' terraform.tfvars | cut -d'"' -f2)
    
    echo -e "${GREEN}🟢 AMBIENTE PROTEGIDO (CON WAF):${NC}"
    echo -e "${GREEN}   Dominio WAF: http://${WAF_DOMAIN}${NC}"
    echo -e "${GREEN}   Load Balancer: http://${LB_IP}${NC}"
    echo -e "${GREEN}   Apache Directo: http://${APACHE_IP} (bypass WAF)${NC}"
    echo ""
    
    echo -e "${BLUE}🔑 Acceso SSH:${NC}"
    echo -e "${BLUE}   Bastion: ssh -i private_key opc@${BASTION_IP}${NC}"
    echo ""
    
    # Información del WAF
    echo -e "${GREEN}🛡️ WAF Information:${NC}"
    echo -e "${GREEN}   OCID: ${WAF_OCID}${NC}"
    echo -e "${GREEN}   Status: $(terraform output -raw waf_status 2>/dev/null || echo 'Activo')${NC}"
    echo -e "${GREEN}   Protections: SQL Injection, XSS, Path Traversal${NC}"
    echo ""
    
    # Información de la base de datos
    DB_NAME=$(terraform output -raw database_name 2>/dev/null || echo "WAFDB01")
    echo -e "${BLUE}🗄️ Base de Datos:${NC}"
    echo -e "${BLUE}   Nombre: ${DB_NAME}${NC}"
    echo -e "${BLUE}   Estado: $(terraform output -raw database_ocid >/dev/null 2>&1 && echo 'Activa' || echo 'En proceso')${NC}"
    echo ""
    
    # Configuración DNS local
    echo -e "${YELLOW}🌐 Configuración DNS Local (Requerida):${NC}"
    echo -e "${YELLOW}   # Agregar al /etc/hosts para pruebas locales:${NC}"
    echo -e "${YELLOW}   echo \"${LB_IP} ${WAF_DOMAIN}\" | sudo tee -a /etc/hosts${NC}"
    echo ""
    
    # Comandos de prueba
    echo -e "${GREEN}🧪 Comandos de prueba (cuando esté listo):${NC}"
    echo -e "${GREEN}   # Verificación WAF${NC}"
    echo -e "${GREEN}   curl -I http://${WAF_DOMAIN}${NC}"
    echo ""
    echo -e "${GREEN}   # SQL Injection (debe retornar 403)${NC}"
    echo -e "${GREEN}   curl \"http://${WAF_DOMAIN}/?demo=sql&user_id=1'\"${NC}"
    echo ""
    echo -e "${GREEN}   # XSS (debe retornar 403)${NC}"
    echo -e "${GREEN}   curl \"http://${WAF_DOMAIN}/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E\"${NC}"
    echo ""
    echo -e "${YELLOW}   # Comparación directa con Apache (vulnerable)${NC}"
    echo -e "${YELLOW}   curl \"http://${APACHE_IP}/?demo=sql&user_id=1'\"${NC}"
    echo ""
    
    # Guardar información para referencia
    cat > ../deployment-info-con-waf.txt << EOF
# AMBIENTE CON WAF - INFORMACIÓN DE DEPLOYMENT
Fecha: $(date)

## URLs de Acceso
WAF Domain: http://${WAF_DOMAIN}
Load Balancer: http://${LB_IP}
Apache Directo: http://${APACHE_IP}
Bastion SSH: ssh -i private_key opc@${BASTION_IP}

## WAF Information
OCID: ${WAF_OCID}
Status: Activo
Protections: SQL Injection, XSS, Path Traversal

## Base de Datos
Nombre: ${DB_NAME}
OCID: $(terraform output -raw database_ocid 2>/dev/null || echo "Ver terraform output")

## Configuración DNS Local
echo "${LB_IP} ${WAF_DOMAIN}" | sudo tee -a /etc/hosts

## Comandos de Prueba
# WAF Protection (debe retornar 403)
curl "http://${WAF_DOMAIN}/?demo=sql&user_id=1'"
curl "http://${WAF_DOMAIN}/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"

# Direct Apache (vulnerable para comparación)
curl "http://${APACHE_IP}/?demo=sql&user_id=1'"

## Información Completa
$(terraform output)
EOF
    
    success "Información guardada en deployment-info-con-waf.txt"
    
    echo ""
    echo -e "${GREEN}🚀 Próximos pasos:${NC}"
    echo -e "${GREEN}   1. Configurar DNS local: echo \"${LB_IP} ${WAF_DOMAIN}\" | sudo tee -a /etc/hosts${NC}"
    echo -e "${GREEN}   2. Verificar WAF: curl -I http://${WAF_DOMAIN}${NC}"
    echo -e "${GREEN}   3. Probar protecciones con los comandos mostrados${NC}"
    echo -e "${GREEN}   4. Usar ../demo-scripts/demo-comparativo.sh para demo completa${NC}"
    
else
    error "❌ Deployment falló"
    echo ""
    echo -e "${RED}🔍 Información para troubleshooting:${NC}"
    echo -e "${RED}   • Verificar credenciales OCI en terraform.tfvars${NC}"
    echo -e "${RED}   • Revisar límites de servicio en OCI (especialmente WAF)${NC}"
    echo -e "${RED}   • Consultar logs de Terraform para detalles específicos${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📋 Deployment CON WAF completado${NC}"
echo -e "${BLUE}   Directorio: $(pwd)${NC}"
echo -e "${BLUE}   Duración total: ~$(( SECONDS / 60 )) minutos${NC}"