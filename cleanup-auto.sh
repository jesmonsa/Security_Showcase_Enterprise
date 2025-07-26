#!/bin/bash

# ========================================
# WAF SHOWCASE - CLEANUP AUTOMÁTICO
# ========================================

set -e

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

echo "🗑️  Iniciando cleanup automático de WAF Showcase..."

# Verificar si hay deployment activo
if [[ ! -f ".last_deployment" ]] && [[ -z "$(terraform state list 2>/dev/null)" ]]; then
    warning "No se encontró deployment activo para limpiar."
    exit 0
fi

# Obtener información del último deployment
if [[ -f ".last_deployment" ]]; then
    CLIENT_NAME=$(head -n1 .last_deployment)
    TFVARS_FILE=$(tail -n1 .last_deployment)
    log "Limpiando deployment: $CLIENT_NAME usando $TFVARS_FILE"
else
    TFVARS_FILE="terraform-CON-WAF.tfvars"
    warning "Usando archivo de configuración por defecto: $TFVARS_FILE"
fi

# Función para remover recursos problemáticos del state
cleanup_state() {
    log "Limpiando estado de Terraform de recursos problemáticos..."
    
    # Recursos que suelen causar problemas en el destroy
    PROBLEMATIC_RESOURCES=(
        "oci_core_subnet.private_db_subnet"
        "oci_core_network_security_group.nsg_database"
        "oci_core_route_table.private_rt"
        "oci_database_db_system.db_system"
    )
    
    for resource in "${PROBLEMATIC_RESOURCES[@]}"; do
        if terraform state show "$resource" >/dev/null 2>&1; then
            warning "Removiendo $resource del state..."
            terraform state rm "$resource" || true
        fi
    done
}

# Intentar destroy normal primero
log "Intentando destroy completo..."
if ! timeout 600 terraform destroy -var-file="$TFVARS_FILE" -auto-approve; then
    warning "Destroy normal falló o tomó demasiado tiempo. Procediendo con cleanup forzado..."
    
    # Cleanup de recursos problemáticos
    cleanup_state
    
    # Intentar destroy nuevamente
    log "Reintentando destroy después de cleanup de state..."
    terraform destroy -var-file="$TFVARS_FILE" -auto-approve || {
        warning "Destroy parcial completado. Algunos recursos pueden requerir limpieza manual."
    }
fi

# Limpiar archivos temporales
log "Limpiando archivos temporales..."
rm -f terraform-auto.tfvars
rm -f .last_deployment
rm -f tfplan
rm -f terraform.tfstate.backup

# Limpiar configuración DNS si existe
if [[ -f "/etc/hosts" ]]; then
    if grep -q "waf.*demo.*oracledemo.com" /etc/hosts 2>/dev/null; then
        warning "Configuración DNS detectada en /etc/hosts"
        echo "Para limpiar DNS, ejecutar:"
        echo "sudo sed -i '/.*waf.*demo.*oracledemo.com/d' /etc/hosts"
    fi
fi

# Verificar state final
REMAINING_RESOURCES=$(terraform state list 2>/dev/null | wc -l)
if [[ $REMAINING_RESOURCES -eq 0 ]]; then
    success "✅ Cleanup completado. Todos los recursos eliminados."
else
    warning "⚠️  $REMAINING_RESOURCES recursos restantes en el state:"
    terraform state list
    echo ""
    echo "Para limpieza manual, revisar en OCI Console:"
    echo "- Compartments que empiecen con 'cmp-wafshowcase' o 'cmp-vulndemo'"
    echo "- Recursos en tenancy root que no se puedan eliminar automáticamente"
fi

log "🎯 Cleanup automático completado"