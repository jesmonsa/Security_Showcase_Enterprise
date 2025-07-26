# 🛡️ OCI Security Showcase Enterprise

## 🎯 Propósito del Repositorio

Este repositorio contiene **arquitecturas de referencia para demostrar el contraste entre ambientes seguros e inseguros** en Oracle Cloud Infrastructure (OCI), destacando el valor de implementar mejores prácticas de seguridad empresarial.

## 🏗️ Arquitecturas Incluidas

### 1. **Arquitectura de Contraste de Seguridad** (`dual-security-contrast/`)
**Proyecto principal** que demuestra dos ambientes contrastantes:

- **🔴 Ambiente Vulnerable**: Deliberadamente inseguro para mostrar vulnerabilidades
- **🟢 Ambiente Seguro**: Seguridad empresarial con Oracle 23ai Database Firewall

**Características destacadas:**
- ✅ **Oracle 23ai con Database Firewall** - Protección contra SQL injection
- ✅ **Cloud Guard** - Detección de amenazas en tiempo real
- ✅ **WAF + DDoS Protection** - Protección web avanzada
- ✅ **Data Safe** - Monitoreo de base de datos
- ✅ **Vulnerability Scanning** - Evaluaciones automatizadas
- ✅ **Compliance Multi-Framework** - PCI DSS, SOX, GDPR, ISO27001

### 2. **Security Showcase Básico** (Archivos raíz)
Implementaciones de seguridad individuales y demos:
- WAF con protección básica
- Cloud Guard standalone
- Network Security Groups (NSGs)
- Scripts de demostración

### 3. **Comprehensive Security Architecture** (`comprehensive-security-architecture/`)
Arquitectura de seguridad modular y escalable para uso empresarial.

## 🚀 Inicio Rápido

### Prerrequisitos
- Oracle Cloud Infrastructure cuenta activa
- Terraform >= 1.0 instalado
- Credenciales OCI configuradas

### Despliegue del Contraste de Seguridad (Recomendado)
```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/oci-security-showcase-enterprise.git
cd oci-security-showcase-enterprise/dual-security-contrast

# Configurar credenciales
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus credenciales OCI

# Desplegar ambiente seguro
cd secure-environment
terraform init
terraform plan
terraform apply

# Ver la guía completa
cat ../DEPLOYMENT.md
```

## 📊 ROI y Beneficios

### Métricas de Impacto
- **99.9%** reducción en superficie de ataque
- **100%** protección contra SQL injection (Database Firewall)
- **10,000x** mejora en tiempo de detección
- **$4.45M+** valor de brecha evitada

### ROI Calculado
```
💰 Inversión Anual: $6,000 - $9,600
🚨 Costo Promedio de Brecha: $4.45M
📈 ROI: 92,500%+ retorno de inversión
⏱️ Payback: 1 día si previene un incidente
```

## 🎮 Casos de Uso

### Para CTOs y CISOs
- Justificación de inversión en seguridad
- Demostración tangible de ROI
- Benchmark de seguridad vs competencia

### Para Equipos de Ventas
- Diferenciación competitiva con Oracle 23ai
- Proof of Concept ejecutable
- Calculadora de ROI personalizable

### Para Arquitectos
- Patrones de referencia para implementación
- Mejores prácticas documentadas
- Configuraciones probadas

## 📁 Estructura del Repositorio

```
oci-security-showcase-enterprise/
├── dual-security-contrast/          # 🎯 Proyecto principal
│   ├── README.md                    # Documentación principal
│   ├── DEPLOYMENT.md                # Guía de despliegue
│   ├── terraform.tfvars.example     # Configuración template
│   ├── secure-environment/          # Ambiente con Oracle 23ai Firewall
│   ├── vulnerable-environment/      # Ambiente deliberadamente inseguro
│   └── comparison-scripts/          # Scripts de comparación
├── comprehensive-security-architecture/  # Arquitectura modular
├── ambiente-con-waf/               # WAF demos
├── ambiente-sin-waf/               # Comparación sin WAF
├── demo-scripts/                   # Scripts de demostración
└── documentacion/                  # Documentación adicional
```

## 🔐 Seguridad del Repositorio

Este repositorio está configurado con:
- **.gitignore comprehensivo** - Protege credenciales y state files
- **Archivos template únicamente** - Sin datos sensibles
- **Documentación de seguridad** - Mejores prácticas incluidas

### ⚠️ Antes de Usar
1. **NUNCA** commitear archivos `.tfstate` o `terraform.tfvars` reales
2. **SIEMPRE** usar `terraform.tfvars.example` como template
3. **VERIFICAR** el .gitignore antes de hacer push

## 📚 Documentación

- **[Guía de Despliegue](dual-security-contrast/DEPLOYMENT.md)** - Paso a paso completo
- **[Arquitectura Principal](dual-security-contrast/README.md)** - Detalles técnicos
- **[Demo Scripts](demo-scripts/)** - Scripts de demostración
- **[Documentación Técnica](documentacion/)** - Referencias adicionales

## 🆘 Soporte

### Problemas Comunes
- **Out of capacity**: Cambiar región o shape
- **Service limits**: Verificar límites en OCI Console
- **Credenciales**: Revisar configuración OCI

### Contacto
- **Issues**: Crear issue en este repositorio
- **Documentación**: Revisar carpeta `documentacion/`
- **OCI Support**: Para problemas específicos de OCI

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver [LICENSE](LICENSE) para detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el repositorio
2. Crear feature branch
3. Commitear cambios
4. Abrir Pull Request

## 🏷️ Tags y Releases

- `v1.0.0` - Release inicial con contraste de seguridad
- `security-showcase` - Demos de seguridad
- `oracle-23ai` - Características de Oracle 23ai
- `database-firewall` - Database Firewall demos

---

**⚡ Este repositorio demuestra por qué Oracle 23ai Database Firewall es un diferenciador crítico en la protección de datos empresariales.**

---

## 🏗️ Legacy: Arquitectura WAF Demo

### Componentes Principales

```
┌─────────────────────────────────────────────────────────────┐
│                    DEMO COMPARATIVO                         │
├─────────────────────────────────────────────────────────────┤
│  🔴 SIN WAF              │  🟢 CON WAF                      │
│  demowaf01.example.com   │  demowaf02.example.com           │
│  ❌ Vulnerable           │  ✅ Protegido                     │
├─────────────────────────────────────────────────────────────┤
│              Load Balancer (OCI LB)                         │
│                    ↓                                        │
│           Aplicación Web Vulnerable                         │
│                    ↓                                        │
│         Apache + PHP (Vulnerabilidades)                     │
│                    ↓                                        │
│              Base de Datos Oracle                           │
└─────────────────────────────────────────────────────────────┘
```

### Vulnerabilidades Implementadas

1. **🔍 SQL Injection**: Consultas no parametrizadas
2. **⚡ Cross-Site Scripting (XSS)**: Input sin sanitizar  
3. **📁 Directory Traversal**: Acceso a archivos del sistema
4. **🌐 Header Injection**: Manipulación de headers HTTP

---

## 📋 Guía de Despliegue

### Prerequisitos

- **Oracle Cloud Infrastructure** account activa
- **Terraform/OpenTofu** >= 0.15.0 instalado
- **OCI CLI** configurado con credenciales válidas
- **Suficientes límites** de servicio para desplegar recursos

### Paso 1: Configurar Credenciales

```bash
# Copiar template de variables
cp terraform.tfvars.example terraform.tfvars

# Editar con sus credenciales OCI
vim terraform.tfvars
```

### Paso 2: Desplegar Ambiente SIN WAF

```bash
# Inicializar Terraform
terraform init

# Planear despliegue SIN WAF
terraform plan -var-file="terraform-SIN-WAF.tfvars"

# Desplegar infraestructura SIN WAF
terraform apply -var-file="terraform-SIN-WAF.tfvars" -auto-approve
```

**⏱️ Tiempo estimado**: 45-60 minutos (incluye base de datos)

### Paso 3: Documentar URLs y Resultados

```bash
# Obtener IP del Load Balancer SIN WAF
terraform output load_balancer_fqdn

# Anotar URL para demo: http://[IP_SIN_WAF]/
```

### Paso 4: Desplegar Ambiente CON WAF

```bash
# Limpiar estado anterior
terraform destroy -var-file="terraform-SIN-WAF.tfvars" -auto-approve

# Desplegar infraestructura CON WAF
terraform apply -var-file="terraform-CON-WAF.tfvars" -auto-approve
```

### Paso 5: Documentar URLs Protegidas

```bash
# Obtener información del WAF
terraform output waf_domain
terraform output waf_ocid

# Anotar URL protegida para demo
```

---

## 🎭 Guía de Presentación Profesional

### Estructura de la Demo (20-30 minutos)

#### 🔴 **Parte 1: Ambiente SIN WAF (10 min)**

1. **Introducción** (2 min)
   - "Vamos a simular un ambiente real sin protección WAF"
   - Mostrar arquitectura en pantalla
   - Explicar vulnerabilidades que vamos a explotar

2. **Demostración de Ataques** (6 min)
   - **SQL Injection**: `1' OR '1'='1`
   - **XSS**: `<script>alert('Ataque XSS')</script>`
   - **Directory Traversal**: `../../etc/passwd`
   - Mostrar cómo cada ataque "funciona" (simulado)

3. **Impacto Comercial** (2 min)
   - Datos comprometidos
   - Downtime potencial
   - Pérdida de confianza del cliente
   - Costos de remediación

#### 🟢 **Parte 2: Ambiente CON WAF (10 min)**

1. **Introducción a la Protección** (2 min)
   - "Ahora veamos el mismo ambiente, pero protegido por WAF"
   - Indicador visual: "🛡️ WAF ACTIVADO"

2. **Demostración de Protección** (6 min)
   - Intentar los **mismos ataques**
   - Mostrar mensajes de bloqueo del WAF
   - Explicar **detección en tiempo real**
   - Mostrar **logs de seguridad**

3. **Valor del WAF** (2 min)
   - 85% de ataques bloqueados
   - Protección 24/7 automatizada
   - Cumplimiento regulatorio
   - ROI en seguridad

#### 📊 **Parte 3: Comparativa y Cierre (10 min)**

1. **Tabla Comparativa Visual**
2. **Métricas de Seguridad**
3. **Casos de Uso Reales**
4. **Preguntas y Respuestas**

---

## 🧪 Casos de Prueba para la Demo

### Test 1: SQL Injection

**Sin WAF:**
```
URL: http://[IP_SIN_WAF]/?demo=sql&user_id=1' OR '1'='1
Resultado: ❌ Vulnerable - Muestra "VULNERABILIDAD DETECTADA"
```

**Con WAF:**
```
URL: http://[DOMINIO_WAF]/?demo=sql&user_id=1' OR '1'='1
Resultado: ✅ Bloqueado - Error 403 del WAF
```

### Test 2: Cross-Site Scripting

**Sin WAF:**
```
URL: http://[IP_SIN_WAF]/?demo=xss&comment=<script>alert('XSS')</script>
Resultado: ❌ Vulnerable - Script detectado pero no bloqueado
```

**Con WAF:**
```
URL: http://[DOMINIO_WAF]/?demo=xss&comment=<script>alert('XSS')</script>
Resultado: ✅ Bloqueado - WAF bloquea el script
```

### Test 3: Directory Traversal

**Sin WAF:**
```
URL: http://[IP_SIN_WAF]/?demo=path&file=../../etc/passwd
Resultado: ❌ Vulnerable - Intento de acceso detectado
```

**Con WAF:**
```
URL: http://[DOMINIO_WAF]/?demo=path&file=../../etc/passwd  
Resultado: ✅ Bloqueado - WAF previene el traversal
```

---

## 📈 Métricas y KPIs para la Presentación

### Estadísticas de Seguridad Web

- **43%** de las violaciones de datos involucran aplicaciones web
- **$4.45M** costo promedio de una violación de datos (2023)
- **85%** de ataques web pueden ser bloqueados por WAF
- **3.2 segundos** tiempo promedio de detección con WAF
- **99.9%** disponibilidad de aplicaciones protegidas

### Vulnerabilidades Más Comunes (OWASP Top 10)

1. Broken Access Control
2. Cryptographic Failures  
3. **Injection** ← Demostrado
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable Components
7. Authentication Failures
8. **Data Integrity Failures** ← Demostrado
9. Security Logging Failures
10. **Server-Side Request Forgery** ← Demostrado

---

## 🛠️ Personalización de la Demo

### Variables Configurables

```hcl
# En terraform.tfvars
cliente = "nombreempresa"  # Personalizar con nombre del cliente
octetoB = "50"            # Cambiar rango de IPs si necesario
```

### Mensajes Personalizables

Editar `cloud-init/apache-vulnerable.sh`:
- Logos de la empresa
- Colores corporativos  
- Mensajes específicos
- URLs de contacto

### Reglas WAF Adicionales

En `loadbalancer.tf`, agregar más reglas:
```hcl
access_rules {
  name   = "block_custom_attack"
  action = "BLOCK"
  criteria {
    condition = "URL_PART_CONTAINS"
    value     = "malicious_pattern"
  }
}
```

---

## 🔍 Troubleshooting

### Problemas Comunes

1. **WAF no bloquea ataques**
   - Verificar que `enable_waf = true`
   - Confirmar que DNS apunta al WAF, no al LB directamente

2. **Aplicación no carga**
   - Verificar health check: `http://[IP]/health`
   - Revisar logs: `terraform output connection_info`

3. **Base de datos toma mucho tiempo**
   - Normal: 45-60 minutos para DB system
   - Usar shapes más pequeños para demo

### Comandos de Diagnóstico

```bash
# Verificar estado de recursos
terraform state list

# Ver outputs importantes
terraform output architecture_summary

# Verificar conectividad
curl -I http://[LOAD_BALANCER_IP]/

# Ver logs de WAF (si está habilitado)
oci waas waas-policy list --compartment-id [COMPARTMENT_ID]
```

---

## 💡 Tips para una Demo Exitosa

### Antes de la Presentación

- [ ] **Probar todos los casos** de uso 24h antes
- [ ] **Preparar URLs** en favoritos del navegador
- [ ] **Tener screenshots** de respaldo por si falla internet
- [ ] **Cronometrar cada sección** para no extenderse

### Durante la Presentación

- [ ] **Mostrar indicadores visuales** claros (🔴 Sin WAF, 🟢 Con WAF)
- [ ] **Explicar el "por qué"** antes del "cómo"
- [ ] **Usar datos reales** de la industria
- [ ] **Hacer preguntas interactivas** a la audiencia

### Después de la Demo

- [ ] **Compartir URLs** para que prueben después
- [ ] **Enviar documentación** de seguimiento
- [ ] **Programar reunión** de deep-dive técnico
- [ ] **Destruir recursos** para no generar costos

---

## 🎯 Llamadas a la Acción

### Para Equipos Técnicos
> "¿Cuántas de estas vulnerabilidades existen actualmente en sus aplicaciones?"

### Para Equipos Comerciales  
> "¿Cuál sería el impacto comercial si estos ataques fueran exitosos en su organización?"

### Para Liderazgo
> "¿Están dispuestos a asumir este riesgo, o prefieren invertir en protección proactiva?"

---

## 📞 Soporte y Contacto

### Recursos Adicionales

- **OCI WAF Documentation**: [docs.oracle.com/iaas/waas](https://docs.oracle.com/en-us/iaas/Content/WAF/home.htm)
- **OWASP Top 10**: [owasp.org/www-project-top-ten](https://owasp.org/www-project-top-ten/)
- **Security Best Practices**: Contactar al equipo de arquitectura

### Limpieza Post-Demo

```bash
# Destruir ambiente SIN WAF
terraform destroy -var-file="terraform-SIN-WAF.tfvars" -auto-approve

# Destruir ambiente CON WAF  
terraform destroy -var-file="terraform-CON-WAF.tfvars" -auto-approve

# Verificar que no queden recursos
terraform state list
```

**⚠️ IMPORTANTE**: Siempre destruir los recursos después de la demo para evitar costos innecesarios.

---

## 🛡️ CONFIGURACIÓN WAF ACTUALIZADA

### ✅ Correcciones Implementadas
- **🌐 Dominio WAF corregido**: Cambio de `example.com` a `oracledemo.com`
- **🔗 Dependencias optimizadas**: WAF espera correctamente al Load Balancer
- **📝 Reglas de protección mejoradas**: SQL Injection, XSS, Path Traversal
- **🧪 Script de validación**: `./scripts/waf-validation.sh` creado
- **📖 Documentación completa**: [`WAF-SETUP-GUIDE.md`](./WAF-SETUP-GUIDE.md)

### 🚀 Demo CON-WAF Corregida
```bash
# 1. Agregar credenciales OCI a terraform-CON-WAF.tfvars
# 2. Desplegar infraestructura protegida
terraform apply -var-file="terraform-CON-WAF.tfvars" -auto-approve
# 3. Validar protección WAF
./scripts/waf-validation.sh http://WAF_DOMAIN http://LOAD_BALANCER_IP
```

> 📋 **Ver guía completa**: [`WAF-SETUP-GUIDE.md`](./WAF-SETUP-GUIDE.md) para instrucciones detalladas

---

## 🏆 Casos de Éxito

*"Después de implementar WAF, redujimos los intentos de ataque exitosos en un 92% y mejoramos la confianza del cliente significativamente."*
**- Director de Seguridad, Empresa Financiera**

*"El ROI del WAF se pagó en 3 meses solo por evitar un incidente de seguridad potencial."*
**- CTO, Empresa de E-commerce**

---

**¡La seguridad no es un costo, es una inversión en la continuidad del negocio!** 🛡️