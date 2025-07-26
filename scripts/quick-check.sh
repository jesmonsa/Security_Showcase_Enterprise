#!/bin/bash

# =============================================================================
# SCRIPT: Quick Check para Demo de Vulnerabilidades
# PROPÓSITO: Verificación rápida antes de iniciar la demo
# AUTOR: Security Showcase Enterprise
# =============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "=================================================================="
echo "🔍 QUICK CHECK - Verificación Pre-Demo"
echo "=================================================================="
echo -e "${NC}"

# Verificar argumentos
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Error: Debes proporcionar la URL de la aplicación${NC}"
    echo "Uso: $0 <URL>"
    echo "Ejemplo: $0 http://193.122.191.160"
    exit 1
fi

URL=$1
echo -e "${BLUE}🎯 Verificando aplicación: ${YELLOW}$URL${NC}"
echo ""

# Test 1: Conectividad básica
echo -e "${BLUE}1. 📡 Verificando conectividad...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}   ✅ Aplicación responde correctamente (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}   ❌ Problema de conectividad (HTTP $HTTP_CODE)${NC}"
    exit 1
fi

# Test 2: Headers de seguridad
echo -e "${BLUE}2. 🛡️ Verificando headers de seguridad...${NC}"
HEADERS=$(curl -I $URL 2>/dev/null)

if echo "$HEADERS" | grep -E "(X-Frame-Options|X-XSS-Protection|Content-Security-Policy)" > /dev/null; then
    echo -e "${YELLOW}   ⚠️ Headers de seguridad encontrados (entorno protegido)${NC}"
else
    echo -e "${RED}   ❌ Headers de seguridad ausentes (entorno vulnerable - perfecto para demo)${NC}"
fi

# Test 3: Verificar que es la aplicación vulnerable
echo -e "${BLUE}3. 🎭 Verificando aplicación de demo...${NC}"
CONTENT=$(curl -s $URL)

if echo "$CONTENT" | grep -i "vulnerabilidad\|demo" > /dev/null; then
    echo -e "${GREEN}   ✅ Aplicación de demo detectada correctamente${NC}"
    
    # Contar vulnerabilidades
    VULN_COUNT=$(echo "$CONTENT" | grep -i "demo.*:" | wc -l)
    echo -e "${GREEN}   📊 Demos de vulnerabilidad encontradas: $VULN_COUNT${NC}"
else
    echo -e "${YELLOW}   ⚠️ No se detectó contenido de demo (verificar manualmente)${NC}"
fi

# Test 4: Verificar SQL Injection está funcionando
echo -e "${BLUE}4. 💉 Probando SQL Injection...${NC}"
SQL_TEST=$(curl -s "$URL/?id=1'" 2>/dev/null)

if echo "$SQL_TEST" | grep -i "error\|sql\|mysql\|warning" > /dev/null; then
    echo -e "${GREEN}   ✅ SQL Injection vulnerable (perfecto para demo)${NC}"
else
    echo -e "${YELLOW}   ⚠️ SQL Injection no detectada (verificar parámetros)${NC}"
fi

# Test 5: Verificar XSS está funcionando
echo -e "${BLUE}5. 🎭 Probando XSS...${NC}"
XSS_TEST=$(curl -s "$URL/?search=<script>test</script>" 2>/dev/null)

if echo "$XSS_TEST" | grep -i "script\|alert" > /dev/null; then
    echo -e "${GREEN}   ✅ XSS vulnerable (perfecto para demo)${NC}"
else
    echo -e "${YELLOW}   ⚠️ XSS no detectada (verificar parámetros)${NC}"
fi

# Resumen final
echo ""
echo -e "${BLUE}=================================================================="
echo "📋 RESUMEN PRE-DEMO"
echo "=================================================================="
echo -e "${NC}"

echo -e "${GREEN}✅ Aplicación accesible: $URL${NC}"
echo -e "${GREEN}✅ Lista para demostración de vulnerabilidades${NC}"

echo ""
echo -e "${YELLOW}🎯 PRÓXIMOS PASOS:${NC}"
echo "   1. Abrir navegador en: $URL"
echo "   2. Preparar terminal con comandos curl"
echo "   3. Iniciar demo con vulnerability-test.sh"

echo ""
echo -e "${BLUE}🎭 COMANDOS RÁPIDOS PARA LA DEMO:${NC}"
echo "   SQL Injection: curl \"$URL/?id=1'\""
echo "   XSS: curl \"$URL/?search=<script>alert('XSS')</script>\""
echo "   Headers: curl -I $URL"

echo ""
echo -e "${GREEN}🚀 ¡Demo lista para ejecutar!${NC}"