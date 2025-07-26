#!/bin/bash

# ========================================
# SCRIPT DE DESPLIEGUE SIMPLIFICADO SIN WAF
# ========================================
# Este script despliega la infraestructura SIN WAF para la demo

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

echo "🛡️ DESPLIEGUE DE INFRAESTRUCTURA SIN WAF"
echo "=========================================="

# Paso 1: Verificar credenciales
print_status "1. Verificando credenciales OCI..."
if [ ! -f "terraform.tfvars" ]; then
    print_error "❌ Archivo terraform.tfvars no encontrado"
    print_status "Copiando template..."
    cp terraform.tfvars.example terraform.tfvars
    print_warning "⚠️ Por favor, edita terraform.tfvars con tus credenciales OCI"
    exit 1
fi

# Paso 2: Verificar configuración SIN WAF
print_status "2. Verificando configuración SIN WAF..."
if [ ! -f "terraform-SIN-WAF.tfvars" ]; then
    print_error "❌ Archivo terraform-SIN-WAF.tfvars no encontrado"
    exit 1
fi

# Paso 3: Inicializar Terraform
print_status "3. Inicializando Terraform..."
terraform init

# Paso 4: Planear despliegue
print_status "4. Planificando despliegue..."
terraform plan -var-file="terraform-SIN-WAF.tfvars" -out=tfplan-sin-waf

# Paso 5: Aplicar despliegue
print_status "5. Aplicando despliegue (esto puede tomar 45-60 minutos)..."
print_warning "⚠️ El despliegue incluye una base de datos Oracle que puede tardar mucho tiempo"
print_status "⏱️ Tiempo estimado: 45-60 minutos"

terraform apply tfplan-sin-waf

# Paso 6: Verificar despliegue
print_status "6. Verificando despliegue..."
sleep 30  # Esperar a que los servicios se estabilicen

# Paso 7: Obtener información
print_status "7. Obteniendo información de la infraestructura..."
LB_IP=$(terraform output -raw load_balancer_fqdn 2>/dev/null || echo "N/A")

if [ "$LB_IP" != "N/A" ]; then
    print_success "✅ Despliegue completado exitosamente!"
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
    echo "📖 Guía de presentación: GUIA-PRESENTACION-SIN-WAF.md"
    echo "🔍 Script de validación: ./scripts/validate-vulnerabilities.sh http://$LB_IP"
    echo ""
    print_success "✅ ¡Listo para la demo!"
else
    print_error "❌ No se pudo obtener la IP del Load Balancer"
    print_status "Verificando estado de los recursos..."
    terraform state list
fi 