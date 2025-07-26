# 🛠️ Scripts de Demo - Security Showcase Enterprise

## 📋 Descripción

Esta carpeta contiene scripts automatizados para facilitar la ejecución de demos de vulnerabilidades de forma profesional, consistente y visualmente impactante.

## 📂 Scripts Incluidos

### 1. 🔍 `quick-check.sh` - Verificación Pre-Demo
**Propósito:** Verificar que la aplicación está lista para la demo

```bash
./scripts/quick-check.sh http://193.122.191.160
```

**Qué hace:**
- ✅ Verifica conectividad básica
- 🛡️ Analiza headers de seguridad
- 🎭 Confirma que las vulnerabilidades están activas
- 💉 Test rápido de SQL Injection
- 🎭 Test rápido de XSS
- 📊 Genera resumen de preparación

**Tiempo de ejecución:** ~30 segundos

### 2. 🚨 `vulnerability-test.sh` - Demo Automatizada
**Propósito:** Ejecutar la demo completa de vulnerabilidades

```bash
./scripts/vulnerability-test.sh http://193.122.191.160
```

**Qué hace:**
- 🕵️ **Fase 1:** Reconocimiento y fingerprinting
- 💉 **Fase 2:** Ataques de SQL Injection
- 🎭 **Fase 3:** Ataques de Cross-Site Scripting
- 🔍 **Fase 4:** Análisis avanzado de seguridad
- 📊 **Fase 5:** Resumen ejecutivo con métricas

**Tiempo de ejecución:** ~5-8 minutos

**Modos disponibles:**
```bash
# Modo demo (con pausas para presentación)
./scripts/vulnerability-test.sh http://url demo

# Modo rápido (sin pausas)
./scripts/vulnerability-test.sh http://url quick

# Modo completo (análisis exhaustivo)
./scripts/vulnerability-test.sh http://url full
```

### 3. 📄 `generate-report.sh` - Generador de Reportes
**Propósito:** Crear reporte profesional post-demo

```bash
./scripts/generate-report.sh http://193.122.191.160 "Nombre Cliente"
```

**Qué hace:**
- 📋 Ejecuta análisis completo automatizado
- 📊 Calcula métricas de riesgo (CVSS)
- 💰 Estima impacto comercial
- ✅ Genera recomendaciones específicas
- 📄 Crea reporte en Markdown profesional

**Salida:** `security-report-YYYY-MM-DD_HH-MM-SS.md`

## 🚀 Uso Rápido para Demos

### Preparación (2 minutos antes)
```bash
# 1. Verificar que todo está listo
./scripts/quick-check.sh http://TU_URL

# 2. Hacer los scripts ejecutables
chmod +x scripts/*.sh
```

### Durante la Demo (5-8 minutos)
```bash
# Ejecutar demo interactiva
./scripts/vulnerability-test.sh http://TU_URL demo
```

### Post-Demo (1 minuto)
```bash
# Generar reporte para el cliente
./scripts/generate-report.sh http://TU_URL "Nombre Cliente"
```

## 🎭 Características Visuales

### 🌈 Colores y Formato
- 🔴 **Rojo:** Vulnerabilidades críticas
- 🟡 **Amarillo:** Advertencias y comandos
- 🟢 **Verde:** Estados seguros
- 🔵 **Azul:** Información y pasos
- 🟣 **Púrpura:** Pausas interactivas

### 📊 Elementos Dramáticos
- Banner ASCII art para impacto visual
- Pausas interactivas en modo demo
- Contadores de vulnerabilidades en tiempo real
- Métricas financieras reales
- Emojis para fácil identificación visual

## 🔧 Personalización

### Variables de Entorno
```bash
# Personalizar cliente
export DEMO_CLIENT="Nombre Empresa"

# Personalizar colores (opcional)
export DEMO_COLORS=true

# Timing de pausas (segundos)
export DEMO_PAUSE_TIME=3
```

### Modificar Scripts
Los scripts están diseñados para ser fácilmente modificables:

```bash
# Editar payloads de prueba
vim scripts/vulnerability-test.sh
# Buscar las secciones FASE 2 y FASE 3

# Personalizar reporte
vim scripts/generate-report.sh
# Modificar plantilla de reporte
```

## 📋 Casos de Uso Específicos

### 🎯 Para Demos Ejecutivas (C-Level)
```bash
# Usar modo rápido sin detalles técnicos
./scripts/vulnerability-test.sh http://url quick
./scripts/generate-report.sh http://url "Enterprise Corp"
# Enfocarse en impacto comercial del reporte
```

### 🔧 Para Equipos Técnicos
```bash
# Usar modo completo con todos los detalles
./scripts/vulnerability-test.sh http://url full
# Mostrar comandos curl individuales
# Explicar cada payload en detalle
```

### 📊 Para Ventas/Preventa
```bash
# Usar modo demo con pausas dramáticas
./scripts/vulnerability-test.sh http://url demo
# Enfatizar el ROI de las soluciones OCI
```

## 🛠️ Troubleshooting

### Problema: Scripts no ejecutan
```bash
# Dar permisos de ejecución
chmod +x scripts/*.sh

# Verificar que bash está disponible
which bash
```

### Problema: curl no funciona
```bash
# Instalar curl si es necesario
# Ubuntu/Debian:
sudo apt-get install curl

# RHEL/CentOS:
sudo yum install curl
```

### Problema: Aplicación no responde
```bash
# Verificar estado con terraform
terraform output load_balancer_fqdn

# Verificar manualmente
curl -I http://TU_URL
```

### Problema: Vulnerabilidades no detectadas
```bash
# Verificar que usas la URL correcta del Load Balancer
terraform output architecture_summary

# Probar directamente en navegador
# Debe mostrar "Demo 1: SQL Injection", etc.
```

## 📚 Ejemplos de Comandos

### Verificación Rápida
```bash
# Verificar antes de demo importante
./scripts/quick-check.sh http://193.122.191.160

# Output esperado:
# ✅ Aplicación responde correctamente (HTTP 200)
# ❌ Headers de seguridad ausentes (entorno vulnerable)
# ✅ Aplicación de demo detectada correctamente
# ✅ SQL Injection vulnerable (perfecto para demo)
```

### Demo Completa
```bash
# Demo interactiva con cliente
./scripts/vulnerability-test.sh http://193.122.191.160 demo

# El script pausará en cada fase:
# [Presiona ENTER para continuar...]
```

### Reporte Profesional
```bash
# Generar reporte para "ACME Corporation"
./scripts/generate-report.sh http://193.122.191.160 "ACME Corporation"

# Output:
# 📋 Generando reporte de seguridad...
# ✅ Reporte generado exitosamente: security-report-2024-01-15_14-30-25.md
```

## 🎯 Best Practices

### ✅ Antes de Usar los Scripts
- Probar todos los scripts 24 horas antes de la demo
- Verificar conectividad de red
- Tener screenshots de respaldo por si falla la conectividad

### 🎭 Durante la Demo
- Usar modo `demo` para demos en vivo
- Explicar cada comando mientras se ejecuta
- Tener el reporte listo para enviar inmediatamente después

### 📊 Después de la Demo
- Generar reporte inmediatamente
- Compartir el reporte con todos los asistentes
- Programar follow-up basado en los hallazgos

## 📞 Soporte

Si encuentras problemas con los scripts:

1. **Verificar prerrequisitos:** bash, curl, terraform
2. **Revisar permisos:** `chmod +x scripts/*.sh`
3. **Verificar conectividad:** `curl -I http://TU_URL`
4. **Consultar logs:** Los scripts muestran información detallada de debug

---

**🚀 ¡Los scripts están listos para crear demos impactantes y profesionales!**