#!/bin/bash

# ========================================
# DEPLOYMENT AUTOMATIZADO - AMBIENTE VULNERABLE
# ⚠️  ESTE AMBIENTE ES DELIBERADAMENTE INSEGURO
# ========================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner de advertencia
echo -e "${RED}"
echo "██╗   ██╗██╗   ██╗██╗     ███╗   ██╗███████╗██████╗  █████╗ ██████╗ ██╗     ███████╗"
echo "██║   ██║██║   ██║██║     ████╗  ██║██╔════╝██╔══██╗██╔══██╗██╔══██╗██║     ██╔════╝"
echo "██║   ██║██║   ██║██║     ██╔██╗ ██║█████╗  ██████╔╝███████║██████╔╝██║     █████╗  "
echo "╚██╗ ██╔╝██║   ██║██║     ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██╔══██╗██║     ██╔══╝  "
echo " ╚████╔╝ ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║██████╔╝███████╗███████╗"
echo "  ╚═══╝   ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝"
echo "                                                                                      "
echo "███████╗███╗   ██╗██╗   ██╗██╗██████╗  ██████╗ ███╗   ██╗███╗   ███╗███████╗███╗   ██╗████████╗"
echo "██╔════╝████╗  ██║██║   ██║██║██╔══██╗██╔═══██╗████╗  ██║████╗ ████║██╔════╝████╗  ██║╚══██╔══╝"
echo "█████╗  ██╔██╗ ██║██║   ██║██║██████╔╝██║   ██║██╔██╗ ██║██╔████╔██║█████╗  ██╔██╗ ██║   ██║   "
echo "██╔══╝  ██║╚██╗██║╚██╗ ██╔╝██║██╔══██╗██║   ██║██║╚██╗██║██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   "
echo "███████╗██║ ╚████║ ╚████╔╝ ██║██║  ██║╚██████╔╝██║ ╚████║██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   "
echo "╚══════╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   "
echo -e "${NC}"

echo -e "${RED}🚨🚨🚨 CRITICAL SECURITY WARNING 🚨🚨🚨${NC}"
echo -e "${RED}Este ambiente es DELIBERADAMENTE INSEGURO para demostración${NC}"
echo -e "${RED}NUNCA debe ser usado en producción o con datos reales${NC}"
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

vulnerable() {
    echo -e "${RED}🚨 VULNERABILIDAD: $1${NC}"
}

# Verificar prerequisitos
log "🔍 Verificando prerequisitos..."

# Verificar Terraform
if ! command -v terraform &> /dev/null; then
    error "Terraform no está instalado. Por favor instalar Terraform >= 1.4.0"
    exit 1
fi

TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
log "Terraform version: $TERRAFORM_VERSION"

# Verificar OCI CLI (opcional pero recomendado)
if command -v oci &> /dev/null; then
    success "OCI CLI detectado"
else
    warning "OCI CLI no detectado (opcional para validación)"
fi

# Verificar archivo de variables
if [[ ! -f "terraform.tfvars" ]]; then
    error "Archivo terraform.tfvars no encontrado"
    error "Copiar terraform.tfvars.example y configurar con credenciales OCI"
    exit 1
fi

# Verificar acknowledgment de seguridad
if ! grep -q "acknowledge_insecure_deployment = true" terraform.tfvars; then
    error "Debe confirmar que entiende que este ambiente es inseguro"
    error "Establecer acknowledge_insecure_deployment = true en terraform.tfvars"
    exit 1
fi

if ! grep -q "demo_disclaimer_accepted = true" terraform.tfvars; then
    error "Debe aceptar el disclaimer de demo"
    error "Establecer demo_disclaimer_accepted = true en terraform.tfvars"
    exit 1
fi

success "Prerequisitos verificados"

# Mostrar configuración
echo ""
log "📋 Configuración del deployment vulnerable:"
echo -e "${RED}   Ambiente: $(grep '^environment' terraform.tfvars | cut -d'=' -f2 | tr -d ' "')${NC}"
echo -e "${RED}   Región: $(grep '^region' terraform.tfvars | cut -d'=' -f2 | tr -d ' "')${NC}"
echo -e "${RED}   Instancias: $(grep '^instance_count' terraform.tfvars | cut -d'=' -f2 | tr -d ' ')${NC}"
echo -e "${RED}   Red: $(grep '^vcn_cidr_block' terraform.tfvars | cut -d'=' -f2 | tr -d ' "')${NC}"
echo ""

# Confirmación final
echo -e "${YELLOW}🚨 ADVERTENCIAS CRÍTICAS:${NC}"
vulnerable "IAM con permisos excesivos para todos los usuarios"
vulnerable "Red completamente expuesta con base de datos en subnet pública"
vulnerable "Oracle 23ai SIN Database Firewall - vulnerable a SQL injection"
vulnerable "Aplicación web con vulnerabilidades OWASP Top 10 activas"
vulnerable "Compute sin hardening, SSH con password habilitado"
vulnerable "Monitoreo deshabilitado - sin Cloud Guard, sin alertas"
vulnerable "Credenciales débiles hardcodeadas en código"
vulnerable "Sin cifrado con customer-managed keys"

echo ""
echo -e "${PURPLE}⏱️  TIEMPO ESTIMADO DE DEPLOYMENT: 60-90 minutos${NC}"
echo -e "${PURPLE}💰 COSTO ESTIMADO: ~$300-400 USD/mes${NC}"
echo -e "${PURPLE}🎯 PROPÓSITO: Demostración de vulnerabilidades únicamente${NC}"
echo ""

read -p "$(echo -e ${RED}\"¿Confirma que entiende los riesgos y desea continuar? (y/N): \"${NC}) -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "Deployment cancelado por el usuario"
    exit 0
fi

# Limpiar estado anterior si existe
if [[ -f "terraform.tfstate" ]]; then
    warning "Estado de Terraform existente detectado"
    read -p "$(echo -e ${YELLOW}\"¿Destruir recursos existentes primero? (y/N): \"${NC}) -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "🗑️ Destruyendo recursos anteriores..."
        terraform destroy -auto-approve || true
        success "Recursos anteriores destruidos"
    fi
fi

# Inicializar Terraform
log "🚀 Inicializando Terraform..."
terraform init
success "Terraform inicializado"

# Generar plan
log "📋 Generando plan de deployment vulnerable..."
terraform plan -out=tfplan-vulnerable
success "Plan generado exitosamente"

# Aplicar configuración
log "⚠️  Iniciando deployment del ambiente VULNERABLE..."
warning "Este proceso creará un ambiente EXTREMADAMENTE INSEGURO"
echo ""

# Mostrar progreso detallado
echo -e "${BLUE}📊 Componentes a desplegar (TODOS INSEGUROS):${NC}"
echo -e "${RED}   • IAM: Permisos excesivos, sin separación de compartimentos${NC}"
echo -e "${RED}   • Red: VCN expuesta, base de datos en subnet pública${NC}"
echo -e "${RED}   • Compute: Sin hardening, SSH con password${NC}"
echo -e "${RED}   • Oracle 23ai: SIN Database Firewall (45-60 min)${NC}"
echo -e "${RED}   • Aplicación: Vulnerabilidades OWASP Top 10 activas${NC}"
echo -e "${RED}   • Load Balancer: Sin WAF, sin protecciones${NC}"
echo -e "${RED}   • Monitoreo: Cloud Guard deshabilitado${NC}"
echo ""

if terraform apply tfplan-vulnerable; then
    success "✅ AMBIENTE VULNERABLE DESPLEGADO EXITOSAMENTE"
    
    # Esperar servicios
    log "⏳ Esperando que los servicios estén completamente listos (60 segundos)..."
    sleep 60
    
    echo ""
    echo -e "${RED}🚨 AMBIENTE VULNERABLE ACTIVO 🚨${NC}"
    echo ""
    
    # Obtener información crítica
    log "📊 Extrayendo información de acceso vulnerable..."
    
    # URLs de aplicaciones
    WEB_APPS=$(terraform output -json vulnerable_architecture_summary 2>/dev/null || echo '{}')
    VULN_ENDPOINTS=$(terraform output -json vulnerability_test_endpoints 2>/dev/null || echo '{}')
    ACCESS_INFO=$(terraform output -json access_information 2>/dev/null || echo '{}')
    
    # Información específica para demo
    LB_IPS=$(terraform output -json deployment_info_for_demo | jq -r '.load_balancer_ips[]?' 2>/dev/null || echo "")
    WEB_URLS=$(terraform output -json deployment_info_for_demo | jq -r '.web_application_urls[]?' 2>/dev/null || echo "")
    COMPUTE_IPS=$(terraform output -json deployment_info_for_demo | jq -r '.compute_instance_ips[]?' 2>/dev/null || echo "")
    
    echo -e "${RED}🔴 INFORMACIÓN DE ACCESO VULNERABLE:${NC}"
    echo ""
    
    if [[ -n "$WEB_URLS" ]]; then
        echo -e "${RED}🌐 Aplicaciones Web Vulnerables:${NC}"
        for url in $WEB_URLS; do
            echo -e "${RED}   $url${NC}"
        done
        echo ""
    fi
    
    if [[ -n "$LB_IPS" ]]; then
        echo -e "${RED}⚖️ Load Balancer (Sin WAF):${NC}"
        for ip in $LB_IPS; do
            echo -e "${RED}   http://$ip${NC}"
        done
        echo ""
    fi
    
    if [[ -n "$COMPUTE_IPS" ]]; then
        echo -e "${RED}💻 Servidores Compute (SSH Directo):${NC}"
        for ip in $COMPUTE_IPS; do
            echo -e "${RED}   ssh -i modules/unprotected-compute/vulnerable_private_key.pem opc@$ip${NC}"
        done
        echo ""
    fi
    
    # Información de Oracle 23ai
    echo -e "${RED}🗄️ Oracle 23ai Database (SIN Database Firewall):${NC}"
    echo -e "${RED}   Versión: Oracle 23ai${NC}"
    echo -e "${RED}   Database Firewall: DESHABILITADO${NC}"
    echo -e "${RED}   Data Safe: DESHABILITADO${NC}"
    echo -e "${RED}   Acceso: PÚBLICO (Puerto 1521 abierto)${NC}"
    echo -e "${RED}   Password: Welcome123! (DÉBIL)${NC}"
    echo ""
    
    # Tests de vulnerabilidad inmediatos
    echo -e "${YELLOW}🧪 TESTS DE VULNERABILIDAD LISTOS:${NC}"
    if [[ -n "$WEB_URLS" ]]; then
        FIRST_URL=$(echo $WEB_URLS | head -n1)
        echo -e "${YELLOW}   SQL Injection: curl \"$FIRST_URL/?demo=sql&user_id=1'\"${NC}"
        echo -e "${YELLOW}   XSS: curl \"$FIRST_URL/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E\"${NC}"
        echo -e "${YELLOW}   Path Traversal: curl \"$FIRST_URL/?demo=path&file=../../etc/passwd\"${NC}"
        echo -e "${YELLOW}   Info Disclosure: curl \"$FIRST_URL/health.php\"${NC}"
    fi
    echo ""
    
    # Generar archivo de información para scripts de comparación
    cat > ../vulnerable-environment-info.txt << EOF
# VULNERABLE ENVIRONMENT - DEPLOYMENT INFORMATION
Deployment Date: $(date)
Environment Type: VULNERABLE (Deliberately Insecure)

## Web Applications
$(for url in $WEB_URLS; do echo "Web Application URL: $url"; done)

## Infrastructure
$(for ip in $LB_IPS; do echo "Load Balancer IP: $ip"; done)
$(for ip in $COMPUTE_IPS; do echo "Compute Instance IP: $ip"; done)

## Database
Database Version: Oracle 23ai
Database Firewall: DISABLED
Data Safe: DISABLED
Database Access: PUBLIC

## Security Status
WAF: DISABLED
Cloud Guard: DISABLED
Vulnerability Scanning: DISABLED
Encryption: DEFAULT_ONLY
Monitoring: MINIMAL

## Vulnerability Test Commands
$(if [[ -n "$WEB_URLS" ]]; then
    FIRST_URL=$(echo $WEB_URLS | head -n1)
    echo "SQL Injection Test: curl \"$FIRST_URL/?demo=sql&user_id=1'\""
    echo "XSS Test: curl \"$FIRST_URL/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E\""
    echo "Path Traversal Test: curl \"$FIRST_URL/?demo=path&file=../../etc/passwd\""
fi)

## Complete Terraform Output
$(terraform output)
EOF
    
    success "Información guardada en vulnerable-environment-info.txt"
    
    echo ""
    echo -e "${GREEN}🎯 PRÓXIMOS PASOS PARA DEMO:${NC}"
    echo -e "${GREEN}   1. Probar vulnerabilidades con los comandos mostrados${NC}"
    echo -e "${GREEN}   2. Desplegar ambiente seguro para comparación${NC}"
    echo -e "${GREEN}   3. Ejecutar script de comparación automatizada${NC}"
    echo -e "${GREEN}   4. Usar archivo vulnerable-environment-info.txt para demo${NC}"
    echo ""
    
    echo -e "${YELLOW}⚠️ RECORDATORIOS CRÍTICOS:${NC}"
    echo -e "${YELLOW}   • Este ambiente es EXTREMADAMENTE vulnerable${NC}"
    echo -e "${YELLOW}   • Destruir inmediatamente después de la demo${NC}"
    echo -e "${YELLOW}   • NUNCA usar con datos reales${NC}"
    echo -e "${YELLOW}   • Monitorear costos - puede ser caro si se olvida${NC}"
    echo ""
    
    echo -e "${RED}🔥 COMANDO DE DESTRUCCIÓN:${NC}"
    echo -e "${RED}   terraform destroy -auto-approve${NC}"
    echo ""
    
    # Resumen final de vulnerabilidades
    echo -e "${CYAN}📋 RESUMEN DE VULNERABILIDADES ACTIVAS:${NC}"
    echo -e "${RED}   ✗ IAM: Permisos excesivos, sin MFA${NC}"
    echo -e "${RED}   ✗ Network: Puerto 1521 abierto, sin WAF${NC}"
    echo -e "${RED}   ✗ Compute: SSH inseguro, sin hardening${NC}"
    echo -e "${RED}   ✗ Database: Oracle 23ai SIN Database Firewall${NC}"
    echo -e "${RED}   ✗ Application: OWASP Top 10 vulnerabilidades${NC}"
    echo -e "${RED}   ✗ Monitoring: Sin Cloud Guard, sin alertas${NC}"
    echo ""
    
    success "🎭 Ambiente vulnerable listo para demostración impactante!"
    
else
    error "❌ Deployment del ambiente vulnerable falló"
    echo ""
    echo -e "${RED}🔍 Troubleshooting:${NC}"
    echo -e "${RED}   • Verificar credenciales OCI en terraform.tfvars${NC}"
    echo -e "${RED}   • Revisar límites de servicio en la región${NC}"
    echo -e "${RED}   • Consultar logs de Terraform para detalles${NC}"
    echo -e "${RED}   • Verificar conectividad de red${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}🎉 DEPLOYMENT VULNERABLE COMPLETADO${NC}"
echo -e "${CYAN}   Directorio: $(pwd)${NC}"
echo -e "${CYAN}   Duración total: ~$(( SECONDS / 60 )) minutos${NC}"
echo -e "${CYAN}   Costo estimado: ~$300-400 USD/mes${NC}"
echo ""

log "🛡️ Contraste dramático garantizado cuando se compare con ambiente seguro!"

# Advertencia final
echo -e "${RED}🚨🚨🚨 ADVERTENCIA FINAL 🚨🚨🚨${NC}"
echo -e "${RED}Este ambiente SERÁ COMPROMETIDO si se expone a atacantes reales${NC}"
echo -e "${RED}¡Destruir inmediatamente después de la demo!${NC}"