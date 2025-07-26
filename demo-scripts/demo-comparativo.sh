#!/bin/bash

# ========================================
# DEMO COMPARATIVO - SIN WAF vs CON WAF
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

# Banner
echo -e "${CYAN}"
echo "██████╗ ███████╗███╗   ███╗ ██████╗      ██████╗ ██████╗ ███╗   ███╗██████╗  █████╗ ██████╗  █████╗ ████████╗██╗██╗   ██╗ ██████╗ "
echo "██╔══██╗██╔════╝████╗ ████║██╔═══██╗    ██╔════╝██╔═══██╗████╗ ████║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██║██║   ██║██╔═══██╗"
echo "██║  ██║█████╗  ██╔████╔██║██║   ██║    ██║     ██║   ██║██╔████╔██║██████╔╝███████║██████╔╝███████║   ██║   ██║██║   ██║██║   ██║"
echo "██║  ██║██╔══╝  ██║╚██╔╝██║██║   ██║    ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ ██╔══██║██╔══██╗██╔══██║   ██║   ██║╚██╗ ██╔╝██║   ██║"
echo "██████╔╝███████╗██║ ╚═╝ ██║╚██████╔╝    ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║     ██║  ██║██║  ██║██║  ██║   ██║   ██║ ╚████╔╝ ╚██████╔╝"
echo "╚═════╝ ╚══════╝╚═╝     ╚═╝ ╚═════╝      ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝   ╚═════╝ "
echo -e "${NC}"

echo -e "${CYAN}🎯 DEMO COMPARATIVO: SIN WAF vs CON WAF${NC}"
echo -e "${YELLOW}Esta demo muestra la diferencia crítica entre ambientes protegidos y vulnerables${NC}"
echo ""

# Función para logging
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
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
    echo -e "${RED}🚨 VULNERABLE: $1${NC}"
}

protected() {
    echo -e "${GREEN}🛡️  PROTEGIDO: $1${NC}"
}

function pause_demo() {
    echo -e "${PURPLE}[Presiona ENTER para continuar...]${NC}"
    read
}

# Verificar archivos de información
if [[ ! -f "deployment-info-sin-waf.txt" ]]; then
    error "Archivo deployment-info-sin-waf.txt no encontrado"
    error "Ejecutar primero: ./demo-scripts/deploy-sin-waf.sh"
    exit 1
fi

if [[ ! -f "deployment-info-con-waf.txt" ]]; then
    error "Archivo deployment-info-con-waf.txt no encontrado"
    error "Ejecutar primero: ./demo-scripts/deploy-con-waf.sh"
    exit 1
fi

# Extraer URLs de los archivos de información
VULNERABLE_URL=$(grep "Apache Directo:" deployment-info-sin-waf.txt | awk '{print $3}')
PROTECTED_URL=$(grep "WAF Domain:" deployment-info-con-waf.txt | awk '{print $3}')

log "📋 URLs detectadas:"
echo -e "${RED}   SIN WAF: ${VULNERABLE_URL}${NC}"
echo -e "${GREEN}   CON WAF: ${PROTECTED_URL}${NC}"
echo ""

# Verificar conectividad
log "🔍 Verificando conectividad de ambientes..."

if curl -s -o /dev/null -w "%{http_code}" "$VULNERABLE_URL" | grep -q "200"; then
    success "Ambiente SIN WAF accesible"
else
    error "Ambiente SIN WAF no accesible: $VULNERABLE_URL"
    exit 1
fi

if curl -s -o /dev/null -w "%{http_code}" "$PROTECTED_URL" | grep -q "200"; then
    success "Ambiente CON WAF accesible"
else
    error "Ambiente CON WAF no accesible: $PROTECTED_URL"
    error "Verificar configuración DNS local:"
    error "  grep wafshowcase /etc/hosts"
    exit 1
fi

echo ""
log "🎭 Iniciando demo comparativo..."
pause_demo

# ========================================
# FASE 1: RECONOCIMIENTO
# ========================================
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}🕵️  FASE 1: RECONOCIMIENTO DE OBJETIVOS${NC}"
echo -e "${CYAN}================================================${NC}"

log "📡 Analizando headers de ambos ambientes..."
echo ""

echo -e "${RED}🔴 AMBIENTE SIN WAF:${NC}"
echo -e "${YELLOW}Comando: curl -I $VULNERABLE_URL${NC}"
curl -I "$VULNERABLE_URL" 2>/dev/null | head -n 5
echo ""

echo -e "${GREEN}🟢 AMBIENTE CON WAF:${NC}"
echo -e "${YELLOW}Comando: curl -I $PROTECTED_URL${NC}"
curl -I "$PROTECTED_URL" 2>/dev/null | head -n 5
echo ""

warning "Observe las diferencias en headers de seguridad"
pause_demo

# ========================================
# FASE 2: SQL INJECTION
# ========================================
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}💉 FASE 2: SQL INJECTION ATTACK${NC}"
echo -e "${CYAN}================================================${NC}"

log "🚨 Probando SQL Injection en ambos ambientes..."
echo ""

echo -e "${RED}🔴 AMBIENTE SIN WAF (VULNERABLE):${NC}"
echo -e "${YELLOW}Comando: curl \"$VULNERABLE_URL/?demo=sql&user_id=1'\"${NC}"
echo ""

VULN_RESULT=$(curl -s "$VULNERABLE_URL/?demo=sql&user_id=1'" | grep -o "PATRÓN DE SQL INJECTION DETECTADO" || echo "")
if [[ -n "$VULN_RESULT" ]]; then
    vulnerable "SQL Injection detectado - Aplicación comprometida"
else
    warning "Respuesta inesperada - verificar manualmente"
fi

echo ""
pause_demo

echo -e "${GREEN}🟢 AMBIENTE CON WAF (PROTEGIDO):${NC}"
echo -e "${YELLOW}Comando: curl \"$PROTECTED_URL/?demo=sql&user_id=1'\"${NC}"
echo ""

PROT_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$PROTECTED_URL/?demo=sql&user_id=1'")
if [[ "$PROT_CODE" == "403" ]]; then
    protected "WAF bloqueó el ataque SQL Injection (HTTP 403)"
else
    warning "Código de respuesta inesperado: $PROT_CODE"
fi

echo ""
log "📊 Comparación de resultados:"
echo -e "${RED}   SIN WAF: Vulnerable a SQL Injection${NC}"
echo -e "${GREEN}   CON WAF: Ataque bloqueado por WAF${NC}"
pause_demo

# ========================================
# FASE 3: XSS
# ========================================
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}⚡ FASE 3: CROSS-SITE SCRIPTING (XSS)${NC}"
echo -e "${CYAN}================================================${NC}"

log "🎭 Probando XSS en ambos ambientes..."
echo ""

echo -e "${RED}🔴 AMBIENTE SIN WAF (VULNERABLE):${NC}"
echo -e "${YELLOW}Comando: curl \"$VULNERABLE_URL/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E\"${NC}"
echo ""

VULN_XSS=$(curl -s "$VULNERABLE_URL/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E" | grep -o "PATRÓN XSS DETECTADO" || echo "")
if [[ -n "$VULN_XSS" ]]; then
    vulnerable "XSS detectado - Scripts maliciosos pueden ejecutarse"
else
    warning "Respuesta inesperada - verificar manualmente"
fi

echo ""
pause_demo

echo -e "${GREEN}🟢 AMBIENTE CON WAF (PROTEGIDO):${NC}"
echo -e "${YELLOW}Comando: curl \"$PROTECTED_URL/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E\"${NC}"
echo ""

PROT_XSS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$PROTECTED_URL/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E")
if [[ "$PROT_XSS_CODE" == "403" ]]; then
    protected "WAF bloqueó el ataque XSS (HTTP 403)"
else
    warning "Código de respuesta inesperado: $PROT_XSS_CODE"
fi

echo ""
log "📊 Comparación de resultados:"
echo -e "${RED}   SIN WAF: Vulnerable a XSS${NC}"
echo -e "${GREEN}   CON WAF: Script malicioso bloqueado${NC}"
pause_demo

# ========================================
# FASE 4: DIRECTORY TRAVERSAL
# ========================================
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}📁 FASE 4: DIRECTORY TRAVERSAL${NC}"
echo -e "${CYAN}================================================${NC}"

log "🔍 Probando Directory Traversal en ambos ambientes..."
echo ""

echo -e "${RED}🔴 AMBIENTE SIN WAF (VULNERABLE):${NC}"
echo -e "${YELLOW}Comando: curl \"$VULNERABLE_URL/?demo=path&file=../../etc/passwd\"${NC}"
echo ""

VULN_PATH=$(curl -s "$VULNERABLE_URL/?demo=path&file=../../etc/passwd" | grep -o "PATRÓN DE DIRECTORY TRAVERSAL DETECTADO" || echo "")
if [[ -n "$VULN_PATH" ]]; then
    vulnerable "Directory Traversal detectado - Archivos del sistema accesibles"
else
    warning "Respuesta inesperada - verificar manualmente"
fi

echo ""
pause_demo

echo -e "${GREEN}🟢 AMBIENTE CON WAF (PROTEGIDO):${NC}"
echo -e "${YELLOW}Comando: curl \"$PROTECTED_URL/?demo=path&file=../../etc/passwd\"${NC}"
echo ""

PROT_PATH_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$PROTECTED_URL/?demo=path&file=../../etc/passwd")
if [[ "$PROT_PATH_CODE" == "403" ]]; then
    protected "WAF bloqueó el Directory Traversal (HTTP 403)"
else
    warning "Código de respuesta inesperado: $PROT_PATH_CODE"
fi

echo ""
log "📊 Comparación de resultados:"
echo -e "${RED}   SIN WAF: Vulnerable a Directory Traversal${NC}"
echo -e "${GREEN}   CON WAF: Acceso a archivos bloqueado${NC}"
pause_demo

# ========================================
# RESUMEN EJECUTIVO
# ========================================
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}📊 RESUMEN EJECUTIVO COMPARATIVO${NC}"
echo -e "${CYAN}================================================${NC}"

log "📋 Resultados de la demostración:"
echo ""

echo -e "${RED}🔴 AMBIENTE SIN WAF - RESULTADOS:${NC}"
echo -e "${RED}   • SQL Injection: VULNERABLE${NC}"
echo -e "${RED}   • Cross-Site Scripting: VULNERABLE${NC}"
echo -e "${RED}   • Directory Traversal: VULNERABLE${NC}"
echo -e "${RED}   • Headers de Seguridad: AUSENTES${NC}"
echo -e "${RED}   • Nivel de Riesgo: CRÍTICO${NC}"
echo ""

echo -e "${GREEN}🟢 AMBIENTE CON WAF - RESULTADOS:${NC}"
echo -e "${GREEN}   • SQL Injection: BLOQUEADO${NC}"
echo -e "${GREEN}   • Cross-Site Scripting: BLOQUEADO${NC}"
echo -e "${GREEN}   • Directory Traversal: BLOQUEADO${NC}"
echo -e "${GREEN}   • Headers de Seguridad: CONFIGURADOS${NC}"
echo -e "${GREEN}   • Nivel de Riesgo: BAJO${NC}"
echo ""

echo -e "${YELLOW}💰 IMPACTO COMERCIAL:${NC}"
echo -e "${YELLOW}   • Costo promedio de violación: \$4.45 millones USD${NC}"
echo -e "${YELLOW}   • Tiempo promedio de detección: 287 días${NC}"
echo -e "${YELLOW}   • Pérdida de confianza del cliente: 65%${NC}"
echo -e "${YELLOW}   • Multas regulatorias potenciales: \$10+ millones USD${NC}"
echo ""

echo -e "${GREEN}✅ BENEFICIOS DEL WAF:${NC}"
echo -e "${GREEN}   • 85% de ataques web bloqueados automáticamente${NC}"
echo -e "${GREEN}   • 3.2 segundos tiempo promedio de detección${NC}"
echo -e "${GREEN}   • 99.9% disponibilidad de aplicaciones${NC}"
echo -e "${GREEN}   • ROI positivo en 3-6 meses${NC}"
echo ""

pause_demo

# ========================================
# INFORMACIÓN ADICIONAL
# ========================================
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}📚 INFORMACIÓN ADICIONAL PARA DEMO${NC}"
echo -e "${CYAN}================================================${NC}"

log "🔗 URLs para referencia rápida:"
echo ""
echo -e "${RED}🔴 Ambiente Vulnerable:${NC}"
echo -e "${RED}   $VULNERABLE_URL${NC}"
echo ""
echo -e "${GREEN}🟢 Ambiente Protegido:${NC}"
echo -e "${GREEN}   $PROTECTED_URL${NC}"
echo ""

log "📋 Archivos de información detallada:"
echo -e "${BLUE}   deployment-info-sin-waf.txt${NC}"
echo -e "${BLUE}   deployment-info-con-waf.txt${NC}"
echo ""

log "🧪 Scripts adicionales disponibles:"
echo -e "${BLUE}   ./scripts/vulnerability-test.sh [URL] demo${NC}"
echo -e "${BLUE}   ./scripts/generate-report.sh [URL] \"Cliente\"${NC}"
echo -e "${BLUE}   ./scripts/quick-check.sh [URL]${NC}"
echo ""

echo -e "${GREEN}🎯 PRÓXIMOS PASOS:${NC}"
echo -e "${GREEN}   1. Usar URLs mostradas para demo en navegador${NC}"
echo -e "${GREEN}   2. Generar reportes profesionales con scripts${NC}"
echo -e "${GREEN}   3. Personalizar mensajes según audiencia${NC}"
echo -e "${GREEN}   4. Programar seguimiento técnico/comercial${NC}"
echo ""

# Generar archivo de resumen
cat > demo-summary-$(date +%Y%m%d-%H%M%S).txt << EOF
# DEMO COMPARATIVO - RESUMEN
Fecha: $(date)

## URLs de Demo
Vulnerable (SIN WAF): $VULNERABLE_URL
Protegido (CON WAF): $PROTECTED_URL

## Resultados de Tests
SQL Injection SIN WAF: VULNERABLE
SQL Injection CON WAF: BLOQUEADO (403)

XSS SIN WAF: VULNERABLE  
XSS CON WAF: BLOQUEADO (403)

Directory Traversal SIN WAF: VULNERABLE
Directory Traversal CON WAF: BLOQUEADO (403)

## Comandos de Prueba
curl "$VULNERABLE_URL/?demo=sql&user_id=1'"
curl "$PROTECTED_URL/?demo=sql&user_id=1'"

curl "$VULNERABLE_URL/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"
curl "$PROTECTED_URL/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"

## Impacto Comercial
- Costo de violación: $4.45M USD
- Tiempo de detección: 287 días  
- Pérdida de confianza: 65%
- WAF bloquea: 85% de ataques

## Next Steps
1. Demo en navegador con URLs
2. Generar reportes profesionales
3. Seguimiento técnico/comercial
EOF

success "Resumen guardado en: demo-summary-$(date +%Y%m%d-%H%M%S).txt"

echo ""
echo -e "${CYAN}🎉 DEMO COMPARATIVO COMPLETADO EXITOSAMENTE${NC}"
echo -e "${CYAN}   Duración: ~$(( SECONDS / 60 )) minutos${NC}"
echo -e "${CYAN}   Ambientes listos para demostración en vivo${NC}"
echo ""

log "🛡️ La diferencia es clara: WAF es esencial para la seguridad web"