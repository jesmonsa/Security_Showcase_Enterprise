#!/bin/bash

# =============================================================================
# SCRIPT: WAF Validation - Verificación de Protección WAF
# PROPÓSITO: Validar que WAF está funcionando correctamente
# AUTOR: Security Showcase Enterprise
# =============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "🛡️ =================================================================="
echo "🛡️          WAF VALIDATION - Oracle Web Application Firewall"
echo "🛡️ =================================================================="
echo -e "${NC}"

# Verificar argumentos
if [ $# -lt 2 ]; then
    echo -e "${RED}❌ Error: Debes proporcionar URLs para la validación${NC}"
    echo "Uso: $0 <URL_WAF> <URL_DIRECTA>"
    echo "Ejemplo: $0 http://ejemplo-waf-demo.oracledemo.com http://193.122.191.160"
    exit 1
fi

WAF_URL=$1
DIRECT_URL=$2

echo -e "${BLUE}🎯 URL con WAF: ${YELLOW}$WAF_URL${NC}"
echo -e "${BLUE}🎯 URL directa: ${YELLOW}$DIRECT_URL${NC}"
echo ""

# Función para pause dramático
dramatic_pause() {
    echo -e "${PURPLE}[Presiona ENTER para continuar...]${NC}"
    read -r
}

# Función para mostrar paso
show_step() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

# FASE 1: VERIFICAR CONECTIVIDAD BÁSICA
show_step "🔍 FASE 1: VERIFICACIÓN DE CONECTIVIDAD"

echo -e "${BLUE}📡 Verificando acceso directo al Load Balancer...${NC}"
DIRECT_CODE=$(curl -s -o /dev/null -w "%{http_code}" $DIRECT_URL)
if [ "$DIRECT_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Load Balancer directo: HTTP $DIRECT_CODE (Accesible)${NC}"
else
    echo -e "${RED}❌ Load Balancer directo: HTTP $DIRECT_CODE (Problema)${NC}"
    exit 1
fi

echo -e "${BLUE}🛡️ Verificando acceso a través del WAF...${NC}"
WAF_CODE=$(curl -s -o /dev/null -w "%{http_code}" $WAF_URL)
if [ "$WAF_CODE" = "200" ]; then
    echo -e "${GREEN}✅ WAF: HTTP $WAF_CODE (Funcionando)${NC}"
    echo -e "${GREEN}🎯 WAF está interceptando y permitiendo tráfico legítimo${NC}"
elif [ "$WAF_CODE" = "403" ]; then
    echo -e "${YELLOW}⚠️ WAF: HTTP $WAF_CODE (Bloqueando por defecto - necesita configuración DNS)${NC}"
    echo -e "${YELLOW}ℹ️ El WAF está funcionando pero necesita configuración DNS adecuada${NC}"
else
    echo -e "${RED}❌ WAF: HTTP $WAF_CODE (Problema de configuración)${NC}"
fi

dramatic_pause

# FASE 2: COMPARAR HEADERS DE SEGURIDAD
show_step "🔒 FASE 2: COMPARACIÓN DE HEADERS DE SEGURIDAD"

echo -e "${BLUE}📋 Headers del Load Balancer directo:${NC}"
DIRECT_HEADERS=$(curl -I $DIRECT_URL 2>/dev/null)
echo "$DIRECT_HEADERS" | head -10

echo ""
echo -e "${BLUE}🛡️ Headers a través del WAF:${NC}"
WAF_HEADERS=$(curl -I $WAF_URL 2>/dev/null)
echo "$WAF_HEADERS" | head -10

echo ""
echo -e "${BLUE}🔍 Análisis de mejoras de seguridad del WAF:${NC}"

# Verificar headers específicos del WAF
if echo "$WAF_HEADERS" | grep -i "x-waf\|cloudflare\|oracle" > /dev/null; then
    echo -e "${GREEN}✅ Headers de WAF detectados${NC}"
else
    echo -e "${YELLOW}⚠️ Headers específicos de WAF no visibles${NC}"
fi

# Verificar headers de seguridad estándar
SECURITY_HEADERS=("X-Frame-Options" "X-Content-Type-Options" "X-XSS-Protection" "Content-Security-Policy")

for header in "${SECURITY_HEADERS[@]}"; do
    if echo "$WAF_HEADERS" | grep -i "$header" > /dev/null; then
        echo -e "${GREEN}✅ $header: Presente${NC}"
    else
        echo -e "${YELLOW}⚠️ $header: Ausente${NC}"
    fi
done

dramatic_pause

# FASE 3: PROBAR ATAQUES BLOQUEADOS POR WAF
show_step "🚨 FASE 3: VALIDACIÓN DE PROTECCIÓN CONTRA ATAQUES"

echo -e "${RED}⚠️ IMPORTANTE: Probando ataques solo en entorno de demo autorizado${NC}"
echo ""

# Array de payloads de ataque
declare -A ATTACKS
ATTACKS["SQL Injection 1"]="' OR '1'='1"
ATTACKS["SQL Injection 2"]="UNION SELECT"
ATTACKS["XSS Script"]="<script>alert('xss')</script>"
ATTACKS["XSS JavaScript"]="javascript:alert('xss')"
ATTACKS["Path Traversal"]="../../../etc/passwd"

echo -e "${BLUE}🔥 Probando ataques contra aplicación SIN WAF (directo):${NC}"
echo ""

for attack_name in "${!ATTACKS[@]}"; do
    payload="${ATTACKS[$attack_name]}"
    encoded_payload=$(printf '%s' "$payload" | jq -sRr @uri)
    
    echo -e "${YELLOW}Probando: $attack_name${NC}"
    echo -e "${YELLOW}Payload: $payload${NC}"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$DIRECT_URL/?test=$encoded_payload")
    
    if [ "$response" = "200" ]; then
        echo -e "${RED}❌ VULNERABLE: HTTP $response - Ataque no bloqueado${NC}"
    else
        echo -e "${GREEN}✅ PROTEGIDO: HTTP $response - Ataque bloqueado${NC}"
    fi
    echo ""
done

dramatic_pause

echo -e "${BLUE}🛡️ Probando mismos ataques contra aplicación CON WAF:${NC}"
echo ""

for attack_name in "${!ATTACKS[@]}"; do
    payload="${ATTACKS[$attack_name]}"
    encoded_payload=$(printf '%s' "$payload" | jq -sRr @uri)
    
    echo -e "${YELLOW}Probando: $attack_name${NC}"
    echo -e "${YELLOW}Payload: $payload${NC}"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$WAF_URL/?test=$encoded_payload")
    
    if [ "$response" = "403" ]; then
        echo -e "${GREEN}✅ BLOQUEADO: HTTP $response - WAF funcionando correctamente${NC}"
        
        # Obtener mensaje de bloqueo del WAF
        block_message=$(curl -s "$WAF_URL/?test=$encoded_payload" | grep -i "blocked\|waf\|firewall" | head -1)
        if [ ! -z "$block_message" ]; then
            echo -e "${GREEN}📝 Mensaje: $block_message${NC}"
        fi
    elif [ "$response" = "200" ]; then
        echo -e "${RED}❌ NO BLOQUEADO: HTTP $response - WAF no está funcionando${NC}"
    else
        echo -e "${YELLOW}⚠️ RESPUESTA: HTTP $response - Revisar configuración${NC}"
    fi
    echo ""
done

# FASE 4: RESUMEN Y RECOMENDACIONES
show_step "📊 FASE 4: RESUMEN DE VALIDACIÓN WAF"

echo -e "${BLUE}🎯 RESULTADOS DE LA VALIDACIÓN:${NC}"
echo ""

# Contar éxitos y fallos
SUCCESS_COUNT=0
TOTAL_TESTS=5

for attack_name in "${!ATTACKS[@]}"; do
    payload="${ATTACKS[$attack_name]}"
    encoded_payload=$(printf '%s' "$payload" | jq -sRr @uri)
    
    waf_response=$(curl -s -o /dev/null -w "%{http_code}" "$WAF_URL/?test=$encoded_payload")
    
    if [ "$waf_response" = "403" ]; then
        ((SUCCESS_COUNT++))
    fi
done

# Calcular efectividad
EFFECTIVENESS=$((SUCCESS_COUNT * 100 / TOTAL_TESTS))

echo -e "${BLUE}📈 MÉTRICAS DE PROTECCIÓN:${NC}"
echo -e "${BLUE}   • Tests realizados: $TOTAL_TESTS${NC}"
echo -e "${BLUE}   • Ataques bloqueados: $SUCCESS_COUNT${NC}"
echo -e "${BLUE}   • Efectividad del WAF: $EFFECTIVENESS%${NC}"

echo ""
if [ $EFFECTIVENESS -ge 80 ]; then
    echo -e "${GREEN}🏆 EXCELENTE: WAF está proporcionando protección robusta${NC}"
    echo -e "${GREEN}✅ Recomendación: Continuar con la configuración actual${NC}"
elif [ $EFFECTIVENESS -ge 60 ]; then
    echo -e "${YELLOW}⚠️ BUENO: WAF funciona pero necesita ajustes${NC}"
    echo -e "${YELLOW}🔧 Recomendación: Revisar reglas de acceso específicas${NC}"
else
    echo -e "${RED}🚨 CRÍTICO: WAF no está protegiendo adecuadamente${NC}"
    echo -e "${RED}⚠️ Recomendación: Revisar configuración completa del WAF${NC}"
fi

echo ""
echo -e "${BLUE}🎭 PREPARACIÓN PARA DEMO:${NC}"
if [ $EFFECTIVENESS -ge 80 ]; then
    echo -e "${GREEN}✅ Demo lista: Contraste claro entre protegido/vulnerable${NC}"
    echo -e "${GREEN}🎯 Usar $WAF_URL para mostrar protección${NC}"
    echo -e "${GREEN}🎯 Usar $DIRECT_URL para mostrar vulnerabilidades${NC}"
else
    echo -e "${YELLOW}⚠️ Necesita ajustes antes de la demo${NC}"
    echo -e "${YELLOW}🔧 Configurar DNS o reglas WAF según sea necesario${NC}"
fi

echo ""
echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}Validación WAF completada${NC}"
echo -e "${PURPLE}Efectividad: $EFFECTIVENESS% ($SUCCESS_COUNT/$TOTAL_TESTS)${NC}"
echo -e "${PURPLE}========================================${NC}"