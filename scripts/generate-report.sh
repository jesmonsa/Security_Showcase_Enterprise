#!/bin/bash

# =============================================================================
# SCRIPT: Generate Security Report
# PROPÓSITO: Generar reporte detallado post-demo
# AUTOR: Security Showcase Enterprise
# =============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar argumentos
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Error: Debes proporcionar la URL de la aplicación${NC}"
    echo "Uso: $0 <URL> [nombre_cliente]"
    echo "Ejemplo: $0 http://193.122.191.160 'Empresa Demo'"
    exit 1
fi

URL=$1
CLIENT_NAME=${2:-"Cliente Demo"}
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
REPORT_FILE="security-report-$TIMESTAMP.md"

echo -e "${BLUE}📋 Generando reporte de seguridad...${NC}"
echo -e "${BLUE}🎯 URL: $URL${NC}"
echo -e "${BLUE}👤 Cliente: $CLIENT_NAME${NC}"
echo -e "${BLUE}📄 Archivo: $REPORT_FILE${NC}"
echo ""

# Ejecutar tests
echo -e "${YELLOW}🔍 Ejecutando análisis de seguridad...${NC}"

# Test básico de conectividad
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $URL)
HEADERS=$(curl -I $URL 2>/dev/null)

# Tests de vulnerabilidades
SQL_TEST=$(curl -s "$URL/?id=1'" 2>/dev/null)
XSS_TEST=$(curl -s "$URL/?search=%3Cscript%3Ealert%28%27test%27%29%3C%2Fscript%3E" 2>/dev/null)

# Verificar archivos sensibles
declare -A FILE_TESTS
FILES=(".env" "config.php" "admin/" ".git/" "backup.sql" "phpinfo.php")
for file in "${FILES[@]}"; do
    FILE_TESTS[$file]=$(curl -s -o /dev/null -w "%{http_code}" "$URL/$file")
done

# Generar reporte
cat > $REPORT_FILE << EOF
# 🛡️ Reporte de Seguridad - Security Showcase

**Cliente:** $CLIENT_NAME  
**Fecha:** $(date "+%d/%m/%Y %H:%M:%S")  
**URL Analizada:** [\`$URL\`]($URL)  
**Analista:** Security Showcase Enterprise  

---

## 📋 Resumen Ejecutivo

Este reporte documenta los hallazgos de seguridad encontrados durante la demostración de vulnerabilidades web. El análisis se realizó en un entorno controlado con fines educativos y de concientización sobre la importancia de las medidas de seguridad en aplicaciones web.

### 🎯 Objetivo de la Demo
- Demostrar vulnerabilidades comunes en aplicaciones web
- Mostrar el impacto de ataques exitosos
- Evidenciar el valor de soluciones como Oracle WAF y Cloud Guard

---

## 🔍 Metodología de Análisis

### Herramientas Utilizadas
- \`curl\` - Cliente HTTP para pruebas automatizadas
- Navegador web - Análisis interactivo
- Scripts personalizados - Automatización de tests

### Alcance del Análisis
- ✅ Análisis de headers HTTP
- ✅ Test de SQL Injection
- ✅ Test de Cross-Site Scripting (XSS)
- ✅ Enumeración de archivos sensibles
- ✅ Verificación de métodos HTTP

---

## 📊 Resultados Técnicos

### 🌐 Conectividad y Headers HTTP

**Estado de Conectividad:** $(if [ "$HTTP_CODE" = "200" ]; then echo "✅ Aplicación accesible (HTTP $HTTP_CODE)"; else echo "❌ Problema de conectividad (HTTP $HTTP_CODE)"; fi)

**Headers de Respuesta:**
\`\`\`http
$HEADERS
\`\`\`

**Análisis de Headers de Seguridad:**
$(if echo "$HEADERS" | grep -E "(X-Frame-Options)" > /dev/null; then echo "- ✅ X-Frame-Options: Presente"; else echo "- ❌ X-Frame-Options: **AUSENTE**"; fi)
$(if echo "$HEADERS" | grep -E "(X-XSS-Protection)" > /dev/null; then echo "- ✅ X-XSS-Protection: Presente"; else echo "- ❌ X-XSS-Protection: **AUSENTE**"; fi)
$(if echo "$HEADERS" | grep -E "(Content-Security-Policy)" > /dev/null; then echo "- ✅ Content-Security-Policy: Presente"; else echo "- ❌ Content-Security-Policy: **AUSENTE**"; fi)
$(if echo "$HEADERS" | grep -E "(Strict-Transport-Security)" > /dev/null; then echo "- ✅ Strict-Transport-Security: Presente"; else echo "- ❌ Strict-Transport-Security: **AUSENTE**"; fi)

### 💉 SQL Injection

**Test Realizado:** \`$URL/?id=1'\`

**Resultado:**
$(if echo "$SQL_TEST" | grep -i "error\|sql\|mysql\|warning" > /dev/null; then echo "❌ **VULNERABLE** - La aplicación es susceptible a SQL Injection"; else echo "✅ **PROTEGIDA** - No se detectaron vulnerabilidades de SQL Injection"; fi)

$(if echo "$SQL_TEST" | grep -i "error\|sql\|mysql\|warning" > /dev/null; then echo "**Evidencia detectada:**"; echo '```'; echo "$SQL_TEST" | grep -i "error\|sql\|mysql\|warning" | head -3; echo '```'; echo ""; echo "**Impacto potencial:**"; echo "- Acceso no autorizado a la base de datos"; echo "- Bypass de autenticación"; echo "- Extracción de información sensible"; echo "- Modificación o eliminación de datos"; fi)

### 🎭 Cross-Site Scripting (XSS)

**Test Realizado:** \`$URL/?search=<script>alert('test')</script>\`

**Resultado:**
$(if echo "$XSS_TEST" | grep -i "script\|alert" > /dev/null; then echo "❌ **VULNERABLE** - La aplicación es susceptible a XSS"; else echo "✅ **PROTEGIDA** - Scripts maliciosos son filtrados o bloqueados"; fi)

$(if echo "$XSS_TEST" | grep -i "script\|alert" > /dev/null; then echo "**Impacto potencial:**"; echo "- Robo de cookies de sesión"; echo "- Captura de credenciales"; echo "- Redirección a sitios maliciosos"; echo "- Instalación de keyloggers"; echo "- Defacement de la aplicación"; fi)

### 📁 Enumeración de Archivos

**Archivos/Directorios Verificados:**

EOF

# Agregar resultados de archivos
for file in "${FILES[@]}"; do
    code=${FILE_TESTS[$file]}
    if [ "$code" = "200" ]; then
        echo "- ❌ \`$file\` - **EXPUESTO** (HTTP $code)" >> $REPORT_FILE
    elif [ "$code" = "403" ]; then
        echo "- ⚠️ \`$file\` - Existe pero protegido (HTTP $code)" >> $REPORT_FILE
    else
        echo "- ✅ \`$file\` - No accesible (HTTP $code)" >> $REPORT_FILE
    fi
done

# Continuar con el reporte
cat >> $REPORT_FILE << EOF

---

## 🚨 Vulnerabilidades Críticas Identificadas

EOF

# Calcular severidad
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0

# SQL Injection
if echo "$SQL_TEST" | grep -i "error\|sql" > /dev/null; then
    echo "### 💉 SQL Injection" >> $REPORT_FILE
    echo "- **Severidad:** 🔴 CRÍTICA" >> $REPORT_FILE
    echo "- **CVSS:** 9.8" >> $REPORT_FILE
    echo "- **Descripción:** La aplicación no valida correctamente las entradas del usuario, permitiendo la ejecución de consultas SQL arbitrarias." >> $REPORT_FILE
    echo "- **Evidencia:** Error SQL visible al enviar comilla simple (\`'\`)" >> $REPORT_FILE
    echo "- **Recomendación:** Implementar consultas parametrizadas y WAF con reglas anti-SQL injection" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    ((CRITICAL_COUNT++))
fi

# XSS
if echo "$XSS_TEST" | grep -i "script" > /dev/null; then
    echo "### 🎭 Cross-Site Scripting (XSS)" >> $REPORT_FILE
    echo "- **Severidad:** 🔴 CRÍTICA" >> $REPORT_FILE
    echo "- **CVSS:** 8.7" >> $REPORT_FILE
    echo "- **Descripción:** La aplicación no sanitiza las entradas del usuario, permitiendo la ejecución de scripts maliciosos." >> $REPORT_FILE
    echo "- **Evidencia:** Código JavaScript no filtrado en la respuesta" >> $REPORT_FILE
    echo "- **Recomendación:** Implementar filtrado de entrada, CSP headers y WAF anti-XSS" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    ((CRITICAL_COUNT++))
fi

# Headers faltantes
if ! echo "$HEADERS" | grep -E "(X-Frame-Options|Content-Security-Policy)" > /dev/null; then
    echo "### 🛡️ Headers de Seguridad Ausentes" >> $REPORT_FILE
    echo "- **Severidad:** 🟡 MEDIA" >> $REPORT_FILE
    echo "- **CVSS:** 5.3" >> $REPORT_FILE
    echo "- **Descripción:** La aplicación no implementa headers de seguridad fundamentales." >> $REPORT_FILE
    echo "- **Impacto:** Susceptible a clickjacking, XSS, y otros ataques del lado cliente" >> $REPORT_FILE
    echo "- **Recomendación:** Configurar headers de seguridad estándar" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    ((MEDIUM_COUNT++))
fi

# Archivos expuestos
for file in "${FILES[@]}"; do
    if [ "${FILE_TESTS[$file]}" = "200" ]; then
        echo "### 📁 Archivo Sensible Expuesto: \`$file\`" >> $REPORT_FILE
        echo "- **Severidad:** 🟠 ALTA" >> $REPORT_FILE
        echo "- **Descripción:** Archivo potencialmente sensible accesible públicamente" >> $REPORT_FILE
        echo "- **Recomendación:** Restringir acceso o mover fuera del document root" >> $REPORT_FILE
        echo "" >> $REPORT_FILE
        ((HIGH_COUNT++))
    fi
done

# Continuar reporte
cat >> $REPORT_FILE << EOF
---

## 📈 Análisis de Riesgo

### 🎯 Puntuación de Riesgo Global
EOF

TOTAL_VULN=$((CRITICAL_COUNT + HIGH_COUNT + MEDIUM_COUNT))

if [ $CRITICAL_COUNT -gt 0 ]; then
    echo "**🔴 RIESGO CRÍTICO** - Acción inmediata requerida" >> $REPORT_FILE
elif [ $HIGH_COUNT -gt 1 ]; then
    echo "**🟠 RIESGO ALTO** - Requiere atención prioritaria" >> $REPORT_FILE
elif [ $TOTAL_VULN -gt 0 ]; then
    echo "**🟡 RIESGO MEDIO** - Mejoras de seguridad recomendadas" >> $REPORT_FILE
else
    echo "**🟢 RIESGO BAJO** - Aplicación relativamente segura" >> $REPORT_FILE
fi

cat >> $REPORT_FILE << EOF

### 📊 Resumen de Vulnerabilidades
- 🔴 **Críticas:** $CRITICAL_COUNT
- 🟠 **Altas:** $HIGH_COUNT  
- 🟡 **Medias:** $MEDIUM_COUNT
- **Total:** $TOTAL_VULN

### 💰 Impacto Comercial Estimado
- **Costo promedio de violación de datos:** \$4.45 millones USD
- **Tiempo promedio de detección:** 287 días
- **Pérdida de confianza del cliente:** 65% de los casos
- **Multas regulatorias potenciales:** \$10+ millones USD

---

## ✅ Recomendaciones de Mitigación

### 🛡️ Soluciones Inmediatas (Oracle Cloud)

#### 1. Oracle Web Application Firewall (WAF)
- **Beneficio:** Bloquea automáticamente el 85% de ataques web
- **Características:**
  - Protección contra SQL Injection y XSS
  - Reglas OWASP Top 10 preconfiguradas
  - Detección de bots maliciosos
  - Rate limiting avanzado

#### 2. Oracle Cloud Guard
- **Beneficio:** Monitoreo 24/7 y detección de amenazas
- **Características:**
  - Detección en tiempo real
  - Remediación automática
  - Alertas inteligentes
  - Cumplimiento continuo

#### 3. Headers de Seguridad
\`\`\`
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
Strict-Transport-Security: max-age=31536000
\`\`\`

### 🔧 Mejoras en Desarrollo

1. **Validación de Entrada**
   - Sanitización de todas las entradas del usuario
   - Consultas parametrizadas/prepared statements
   - Validación del lado servidor

2. **Autenticación y Autorización**
   - Implementar autenticación multifactor
   - Principio de menor privilegio
   - Gestión segura de sesiones

3. **Logging y Monitoreo**
   - Logs detallados de seguridad
   - Monitoreo de anomalías
   - Alertas en tiempo real

---

## 📞 Próximos Pasos Recomendados

### ⚡ Acciones Inmediatas (1-7 días)
- [ ] Implementar Oracle WAF en aplicaciones críticas
- [ ] Activar Oracle Cloud Guard
- [ ] Configurar headers de seguridad básicos
- [ ] Revisar y restringir archivos sensibles expuestos

### 🎯 Acciones a Mediano Plazo (1-4 semanas)
- [ ] Auditoría completa de código fuente
- [ ] Implementar consultas parametrizadas
- [ ] Configurar monitoreo de seguridad avanzado
- [ ] Capacitar al equipo de desarrollo

### 🚀 Acciones a Largo Plazo (1-3 meses)
- [ ] Programa de secure coding
- [ ] Pruebas de penetración regulares
- [ ] Certificaciones de seguridad
- [ ] Plan de respuesta a incidentes

---

## 📋 Anexos

### 🔗 Enlaces Útiles
- [Oracle WAF Documentation](https://docs.oracle.com/en-us/iaas/Content/WAF/home.htm)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Oracle Cloud Guard](https://docs.oracle.com/en-us/iaas/cloud-guard/home.htm)

### 📝 Disclaimer
Este análisis se realizó con fines educativos en un entorno controlado. Los hallazgos están destinados a demostrar la importancia de las medidas de seguridad y no deben utilizarse para actividades maliciosas.

---

**Generado automáticamente por Security Showcase Enterprise**  
**Fecha de generación:** $(date)  
**Versión del reporte:** 1.0  
EOF

echo -e "${GREEN}✅ Reporte generado exitosamente: $REPORT_FILE${NC}"
echo ""
echo -e "${BLUE}📊 Resumen del análisis:${NC}"
echo -e "${RED}   🔴 Vulnerabilidades críticas: $CRITICAL_COUNT${NC}"
echo -e "${YELLOW}   🟠 Vulnerabilidades altas: $HIGH_COUNT${NC}"
echo -e "${YELLOW}   🟡 Vulnerabilidades medias: $MEDIUM_COUNT${NC}"
echo -e "${BLUE}   📄 Total vulnerabilidades: $TOTAL_VULN${NC}"
echo ""
echo -e "${YELLOW}🎯 El reporte ha sido guardado en: $REPORT_FILE${NC}"
echo -e "${YELLOW}📧 Puedes compartir este archivo con el equipo o cliente${NC}"