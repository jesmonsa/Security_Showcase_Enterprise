#!/bin/bash

# ========================================
# DEPLOYMENT AUTOMÁTICO - AMBIENTE SIN WAF
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
echo -e "${RED}"
echo "██╗   ██╗██╗   ██╗██╗     ███╗   ██╗███████╗██████╗  █████╗ ██████╗ ██╗     ███████╗"
echo "██║   ██║██║   ██║██║     ████╗  ██║██╔════╝██╔══██╗██╔══██╗██╔══██╗██║     ██╔════╝"
echo "██║   ██║██║   ██║██║     ██╔██╗ ██║█████╗  ██████╔╝███████║██████╔╝██║     █████╗  "
echo "╚██╗ ██╔╝██║   ██║██║     ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██╔══██╗██║     ██╔══╝  "
echo " ╚████╔╝ ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║██████╔╝███████╗███████╗"
echo "  ╚═══╝   ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝"
echo -e "${NC}"

echo -e "${RED}🔴 AMBIENTE VULNERABLE - SIN WAF${NC}"
echo -e "${YELLOW}⚠️  Este ambiente NO tiene protecciones de seguridad${NC}"
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
if [[ ! -d "ambiente-sin-waf" ]]; then
    error "Directorio ambiente-sin-waf no encontrado. Ejecutar desde directorio raíz del proyecto."
    exit 1
fi

# Cambiar al directorio de trabajo
cd ambiente-sin-waf

log "🚀 Iniciando deployment del ambiente SIN WAF..."

# Verificar archivos necesarios
if [[ ! -f "terraform.tfvars" ]]; then
    error "Archivo terraform.tfvars no encontrado en ambiente-sin-waf/"
    exit 1
fi

# Mostrar configuración
echo -e "${BLUE}📋 Configuración del deployment:${NC}"
echo -e "${BLUE}   Cliente: $(grep '^cliente' terraform.tfvars | cut -d'"' -f2)${NC}"
echo -e "${BLUE}   Octeto B: $(grep '^octetoB' terraform.tfvars | cut -d'"' -f2)${NC}"
echo -e "${BLUE}   WAF: $(grep '^enable_waf' terraform.tfvars | cut -d'=' -f2 | tr -d ' ')${NC}"
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
terraform plan -out=tfplan-sin-waf
success "Plan generado exitosamente"

# Aplicar configuración
log "🚀 Desplegando infraestructura SIN WAF..."
warning "Este proceso puede tomar 45-60 minutos debido a la base de datos..."
echo ""

# Mostrar progreso
echo -e "${BLUE}📊 Componentes a desplegar:${NC}"
echo -e "${BLUE}   • Compartment y VCN${NC}"
echo -e "${BLUE}   • Network Security Groups${NC}"
echo -e "${BLUE}   • Load Balancer${NC}"
echo -e "${BLUE}   • Servidores Apache y Tomcat${NC}"
echo -e "${BLUE}   • Bastion Host${NC}"
echo -e "${BLUE}   • Oracle Database System (45-50 min)${NC}"
echo ""

if terraform apply tfplan-sin-waf; then
    success "✅ Deployment completado exitosamente!"
    
    # Esperar a que los servicios estén listos
    log "Esperando que los servicios estén completamente listos (30 segundos)..."
    sleep 30
    
    echo ""
    echo -e "${GREEN}🎉 AMBIENTE SIN WAF DESPLEGADO EXITOSAMENTE${NC}"
    echo ""
    
    # Obtener información importante
    log "📊 Información de acceso:"
    echo ""
    
    # URLs de acceso
    LB_IP=$(terraform output -raw load_balancer_fqdn 2>/dev/null || echo "No disponible")
    APACHE_IP=$(terraform output -raw apache_public_ip 2>/dev/null || echo "No disponible")
    BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null || echo "No disponible")
    
    echo -e "${RED}🔴 AMBIENTE VULNERABLE (SIN WAF):${NC}"
    echo -e "${RED}   Load Balancer: http://${LB_IP}${NC}"
    echo -e "${RED}   Apache Directo: http://${APACHE_IP}${NC}"
    echo ""
    
    echo -e "${BLUE}🔑 Acceso SSH:${NC}"
    echo -e "${BLUE}   Bastion: ssh -i private_key opc@${BASTION_IP}${NC}"
    echo ""
    
    # Información de la base de datos
    DB_NAME=$(terraform output -raw database_name 2>/dev/null || echo "VULNDB01")
    echo -e "${BLUE}🗄️ Base de Datos:${NC}"
    echo -e "${BLUE}   Nombre: ${DB_NAME}${NC}"
    echo -e "${BLUE}   Estado: $(terraform output -raw database_ocid >/dev/null 2>&1 && echo 'Activa' || echo 'En proceso')${NC}"
    echo ""
    
    # Comandos de verificación
    echo -e "${YELLOW}🧪 Comandos de prueba (cuando esté listo):${NC}"
    echo -e "${YELLOW}   # Verificación básica${NC}"
    echo -e "${YELLOW}   curl -I http://${APACHE_IP}${NC}"
    echo ""
    echo -e "${YELLOW}   # SQL Injection${NC}"
    echo -e "${YELLOW}   curl \"http://${APACHE_IP}/?demo=sql&user_id=1'\"${NC}"
    echo ""
    echo -e "${YELLOW}   # XSS${NC}"
    echo -e "${YELLOW}   curl \"http://${APACHE_IP}/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E\"${NC}"
    echo ""
    
    # Guardar información para referencia
    cat > ../deployment-info-sin-waf.txt << EOF
# AMBIENTE SIN WAF - INFORMACIÓN DE DEPLOYMENT
Fecha: $(date)

## URLs de Acceso
Load Balancer: http://${LB_IP}
Apache Directo: http://${APACHE_IP}
Bastion SSH: ssh -i private_key opc@${BASTION_IP}

## Base de Datos
Nombre: ${DB_NAME}
OCID: $(terraform output -raw database_ocid 2>/dev/null || echo "Ver terraform output")

## Comandos de Prueba
curl -I http://${APACHE_IP}
curl "http://${APACHE_IP}/?demo=sql&user_id=1'"
curl "http://${APACHE_IP}/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"

## Información Completa
$(terraform output)
EOF
    
    success "Información guardada en deployment-info-sin-waf.txt"
    
    echo ""
    echo -e "${GREEN}🚀 Próximos pasos:${NC}"
    echo -e "${GREEN}   1. Verificar que la aplicación responde: curl -I http://${APACHE_IP}${NC}"
    echo -e "${GREEN}   2. Probar vulnerabilidades con los comandos mostrados${NC}"
    echo -e "${GREEN}   3. Ejecutar deployment del ambiente CON WAF para comparación${NC}"
    echo -e "${GREEN}   4. Usar ../demo-scripts/demo-comparativo.sh para demo completa${NC}"
    
else
    error "❌ Deployment falló"
    echo ""
    echo -e "${RED}🔍 Información para troubleshooting:${NC}"
    echo -e "${RED}   • Verificar credenciales OCI en terraform.tfvars${NC}"
    echo -e "${RED}   • Revisar límites de servicio en OCI${NC}"
    echo -e "${RED}   • Consultar logs de Terraform para detalles específicos${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📋 Deployment SIN WAF completado${NC}"
echo -e "${BLUE}   Directorio: $(pwd)${NC}"
echo -e "${BLUE}   Duración total: ~$(( SECONDS / 60 )) minutos${NC}"