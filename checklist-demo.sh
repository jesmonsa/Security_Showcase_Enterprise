#!/bin/bash

# ========================================
# CHECKLIST COMPLETO PARA LA DEMO
# ========================================
# Este script verifica que todo esté listo para la demo

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🎯 CHECKLIST COMPLETO PARA LA DEMO SIN WAF"
echo "=========================================="

# Contador de verificaciones
TOTAL_CHECKS=0
PASSED_CHECKS=0

# Función para verificar
check_item() {
    local description="$1"
    local command="$2"
    local expected="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if eval "$command" 2>/dev/null | grep -q "$expected"; then
        print_success "✅ $description"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        print_error "❌ $description"
    fi
}

# Verificación 1: Archivos necesarios
print_status "1. Verificando archivos necesarios..."
check_item "terraform.tfvars existe" "test -f terraform.tfvars" ""
check_item "terraform-SIN-WAF.tfvars existe" "test -f terraform-SIN-WAF.tfvars" ""
check_item "Scripts de validación existen" "test -f scripts/validate-vulnerabilities.sh" ""

# Verificación 2: Estado de Terraform
print_status "2. Verificando estado de Terraform..."
if terraform state list | grep -q "load_balancer"; then
    print_success "✅ Load Balancer desplegado"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    print_error "❌ Load Balancer no encontrado"
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Verificación 3: Obtener IP del Load Balancer
print_status "3. Obteniendo IP del Load Balancer..."
LB_IP=$(terraform output -raw load_balancer_fqdn 2>/dev/null || echo "")
if [ -n "$LB_IP" ]; then
    print_success "✅ IP del Load Balancer: $LB_IP"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    print_error "❌ No se pudo obtener la IP del Load Balancer"
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Verificación 4: Conectividad
print_status "4. Verificando conectividad..."
if [ -n "$LB_IP" ]; then
    if curl -s -o /dev/null -w "%{http_code}" "http://$LB_IP" | grep -q "200"; then
        print_success "✅ Aplicación responde correctamente"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        print_warning "⚠️ La aplicación no responde aún (puede estar iniciando)"
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
fi

# Verificación 5: Vulnerabilidades
print_status "5. Verificando vulnerabilidades..."
if [ -n "$LB_IP" ]; then
    # SQL Injection
    sql_response=$(curl -s "http://$LB_IP/?demo=sql&user_id=1'" | grep -i "vulnerabilidad" || echo "")
    if [ -n "$sql_response" ]; then
        print_success "✅ SQL Injection funcionando"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        print_warning "⚠️ SQL Injection no detectada"
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # XSS
    xss_response=$(curl -s "http://$LB_IP/?demo=xss&comment=<script>alert(1)</script>" | grep -i "vulnerabilidad" || echo "")
    if [ -n "$xss_response" ]; then
        print_success "✅ XSS funcionando"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        print_warning "⚠️ XSS no detectada"
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
fi

# Verificación 6: Headers de seguridad
print_status "6. Verificando headers de seguridad..."
if [ -n "$LB_IP" ]; then
    headers=$(curl -I "$LB_IP" 2>/dev/null)
    if echo "$headers" | grep -E "(X-Frame|X-XSS|Content-Security)" > /dev/null; then
        print_warning "⚠️ Headers de seguridad presentes (no esperado para demo SIN WAF)"
    else
        print_success "✅ Headers de seguridad ausentes (correcto para demo SIN WAF)"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
fi

# Resumen
echo ""
echo "📊 RESUMEN DE VERIFICACIONES"
echo "============================"
echo "Verificaciones pasadas: $PASSED_CHECKS/$TOTAL_CHECKS"

if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    print_success "🎉 ¡Todo listo para la demo!"
else
    print_warning "⚠️ Algunas verificaciones fallaron. Revisa los errores arriba."
fi

# Mostrar información para la demo
if [ -n "$LB_IP" ]; then
    echo ""
    echo "🎯 INFORMACIÓN PARA LA DEMO"
    echo "==========================="
    echo "URL de la aplicación: http://$LB_IP"
    echo "Estado: SIN PROTECCIONES WAF"
    echo ""
    echo "📋 COMANDOS PARA LA DEMO:"
    echo "curl -I http://$LB_IP"
    echo "curl -s http://$LB_IP | grep -i 'powered\|server'"
    echo "curl -s 'http://$LB_IP/?demo=sql&user_id=1\\''"
    echo "curl -s 'http://$LB_IP/?demo=xss&comment=<script>alert(1)</script>'"
    echo "curl -s 'http://$LB_IP/?demo=path&file=../../etc/passwd'"
    echo ""
    echo "🌐 Abrir en navegador: http://$LB_IP"
    echo ""
    echo "📖 Guías disponibles:"
    echo "- GUIA-PRESENTACION-SIN-WAF.md"
    echo "- COMANDOS-DEMO.md"
    echo "- RESUMEN-DESPLIEGUE-DEMO.md"
    echo ""
    echo "🔍 Scripts disponibles:"
    echo "- ./scripts/validate-vulnerabilities.sh http://$LB_IP"
    echo "- ./scripts/quick-demo-check.sh"
    echo ""
fi

echo "🎭 ¡Buena suerte con tu demo!" 