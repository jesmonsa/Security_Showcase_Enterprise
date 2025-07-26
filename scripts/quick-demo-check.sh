#!/bin/bash

# ========================================
# SCRIPT DE VERIFICACIÓN RÁPIDA PARA DEMO
# ========================================
# Este script verifica rápidamente que todo esté listo para la demo

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

echo "🛡️ VERIFICACIÓN RÁPIDA PARA DEMO SIN WAF"
echo "=========================================="

# Paso 1: Verificar estado de Terraform
print_status "1. Verificando estado de Terraform..."
if terraform state list | grep -q "load_balancer"; then
    print_success "✅ Load Balancer desplegado"
else
    print_error "❌ Load Balancer no encontrado"
    exit 1
fi

# Paso 2: Obtener IP del Load Balancer
print_status "2. Obteniendo IP del Load Balancer..."
LB_IP=$(terraform output -raw load_balancer_fqdn 2>/dev/null || echo "")
if [ -n "$LB_IP" ]; then
    print_success "✅ IP del Load Balancer: $LB_IP"
else
    print_error "❌ No se pudo obtener la IP del Load Balancer"
    exit 1
fi

# Paso 3: Verificar conectividad
print_status "3. Verificando conectividad..."
if curl -s -o /dev/null -w "%{http_code}" "http://$LB_IP" | grep -q "200"; then
    print_success "✅ Aplicación responde correctamente"
else
    print_warning "⚠️ La aplicación no responde aún (puede estar iniciando)"
fi

# Paso 4: Verificar vulnerabilidades
print_status "4. Verificando vulnerabilidades..."
echo "   Probando SQL Injection..."
sql_response=$(curl -s "http://$LB_IP/?demo=sql&user_id=1'" | grep -i "vulnerabilidad" || echo "")
if [ -n "$sql_response" ]; then
    print_success "✅ SQL Injection funcionando"
else
    print_warning "⚠️ SQL Injection no detectada"
fi

echo "   Probando XSS..."
xss_response=$(curl -s "http://$LB_IP/?demo=xss&comment=<script>alert(1)</script>" | grep -i "vulnerabilidad" || echo "")
if [ -n "$xss_response" ]; then
    print_success "✅ XSS funcionando"
else
    print_warning "⚠️ XSS no detectada"
fi

# Paso 5: Mostrar información para la demo
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
print_success "✅ Verificación completada - Listo para la demo!" 