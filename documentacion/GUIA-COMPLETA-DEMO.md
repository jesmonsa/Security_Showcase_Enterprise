# 🛡️ Guía Completa: Demo de Vulnerabilidades Web

## 📋 Índice
1. [Descripción General](#descripción-general)
2. [Arquitectura de la Demo](#arquitectura-de-la-demo)
3. [Preparación Inicial](#preparación-inicial)
4. [Deployment de Ambientes](#deployment-de-ambientes)
5. [Ejecución de la Demo](#ejecución-de-la-demo)
6. [Comandos y Validaciones](#comandos-y-validaciones)
7. [Limpieza y Mantenimiento](#limpieza-y-mantenimiento)
8. [Troubleshooting](#troubleshooting)

---

## 📖 Descripción General

Esta demo profesional muestra la **diferencia crítica** entre tener y no tener un Web Application Firewall (WAF) protegiendo aplicaciones web en Oracle Cloud Infrastructure.

### 🎯 Objetivos
- **Posicionar la importancia del WAF** en la estrategia de seguridad
- **Demostrar valor comercial** tangible de la inversión en seguridad
- **Educar sobre vulnerabilidades** web comunes (OWASP Top 10)
- **Mostrar capacidades técnicas** de OCI WAF en tiempo real

### 🏗️ Componentes de la Demo
- **🔴 Ambiente Vulnerable**: Sin protecciones WAF
- **🟢 Ambiente Protegido**: Con WAF completo de Oracle
- **🤖 Scripts Automatizados**: Para deployment y testing
- **📊 Reportes Profesionales**: Para seguimiento post-demo

---

## 🏛️ Arquitectura de la Demo

### 📁 Estructura de Directorios
```
11_Security_Showcase_Enterprise/
├── ambiente-sin-waf/           # 🔴 Ambiente vulnerable
│   ├── *.tf                    # Archivos Terraform
│   ├── terraform.tfvars        # Variables sin WAF
│   ├── cloud-init/             # Scripts de configuración
│   └── README.md               # Documentación específica
├── ambiente-con-waf/           # 🟢 Ambiente protegido  
│   ├── *.tf                    # Archivos Terraform
│   ├── terraform.tfvars        # Variables con WAF
│   ├── cloud-init/             # Scripts de configuración
│   └── README.md               # Documentación específica
├── demo-scripts/               # 🤖 Scripts de automatización
│   ├── deploy-sin-waf.sh       # Deployment ambiente vulnerable
│   ├── deploy-con-waf.sh       # Deployment ambiente protegido
│   └── demo-comparativo.sh     # Demo completa comparativa
├── documentacion/              # 📚 Documentación completa
└── scripts/                    # 🧪 Scripts de testing
```

### 🌐 Arquitectura de Red

#### Ambiente SIN WAF (10.30.0.0/16)
```
┌─────────────────────────────────────┐
│          Internet                   │
├─────────────────────────────────────┤
│          Load Balancer              │
│             ↓                       │
│    Apache Server (VULNERABLE)       │
│             ↓                       │
│         Oracle Database             │
└─────────────────────────────────────┘
```

#### Ambiente CON WAF (10.31.0.0/16)
```
┌─────────────────────────────────────┐
│          Internet                   │
├─────────────────────────────────────┤
│         Oracle WAF 🛡️               │
│             ↓                       │
│          Load Balancer              │
│             ↓                       │
│    Apache Server (PROTECTED)        │
│             ↓                       │
│         Oracle Database             │
└─────────────────────────────────────┘
```

---

## 🚀 Preparación Inicial

### 📋 Prerequisitos
```bash
# 1. Verificar Terraform/OpenTofu
terraform version  # >= 1.4.0

# 2. Verificar credenciales OCI
ls -la ~/.oci/oci_api_key.pem

# 3. Verificar conectividad OCI
oci iam region list --auth api_key

# 4. Clonar o acceder al proyecto
cd 11_Security_Showcase_Enterprise
```

### ⚙️ Configuración Inicial
```bash
# Verificar estructura de directorios
ls -la
# Debe mostrar: ambiente-sin-waf/ ambiente-con-waf/ demo-scripts/ documentacion/

# Verificar scripts de deployment
ls -la demo-scripts/
chmod +x demo-scripts/*.sh  # Si es necesario
```

---

## 🏗️ Deployment de Ambientes

### 🔴 Paso 1: Deployment Ambiente SIN WAF

```bash
# Ejecutar deployment automatizado
./demo-scripts/deploy-sin-waf.sh

# El script realiza:
# ✅ Verificación de prerequisitos
# ✅ Inicialización de Terraform
# ✅ Plan de deployment
# ✅ Aplicación de configuración (45-60 min)
# ✅ Extracción de información importante
# ✅ Generación de archivo de referencia
```

#### Durante el Deployment
- **Tiempo estimado**: 45-60 minutos
- **Componente más lento**: Oracle Database System (45-50 min)
- **Monitoreo**: El script muestra progreso en tiempo real

#### Al Finalizar
```bash
# El script genera automáticamente:
deployment-info-sin-waf.txt    # Información completa de acceso

# URLs importantes:
# Load Balancer: http://[IP_LB]
# Apache Directo: http://[IP_APACHE] 
# Bastion SSH: ssh -i private_key opc@[IP_BASTION]
```

### 🟢 Paso 2: Deployment Ambiente CON WAF

```bash
# Ejecutar deployment automatizado
./demo-scripts/deploy-con-waf.sh

# El script realiza:
# ✅ Verificación de prerequisitos  
# ✅ Inicialización de Terraform
# ✅ Plan de deployment
# ✅ Aplicación de configuración + WAF (45-60 min)
# ✅ Configuración de políticas WAF
# ✅ Extracción de información importante
# ✅ Instrucciones de configuración DNS
```

#### Durante el Deployment
- **Tiempo estimado**: 45-60 minutos
- **Componentes adicionales**: WAF + Políticas de seguridad
- **Configuración WAF**: Automática con reglas OWASP Top 10

#### Al Finalizar
```bash
# El script genera automáticamente:
deployment-info-con-waf.txt    # Información completa de acceso

# URLs importantes:
# WAF Domain: http://wafshowcase-waf-demo.oracledemo.com
# Load Balancer: http://[IP_LB]
# Apache Directo: http://[IP_APACHE] (bypass WAF)

# IMPORTANTE: Configurar DNS local
echo "[IP_LB] wafshowcase-waf-demo.oracledemo.com" | sudo tee -a /etc/hosts
```

---

## 🎭 Ejecución de la Demo

### 📋 Preparación Pre-Demo (5 minutos)

```bash
# 1. Verificar que ambos ambientes están activos
curl -I http://[IP_APACHE_SIN_WAF]     # Debe retornar 200
curl -I http://wafshowcase-waf-demo.oracledemo.com  # Debe retornar 200

# 2. Verificar URLs en archivos de referencia
cat deployment-info-sin-waf.txt
cat deployment-info-con-waf.txt

# 3. Preparar navegador con tabs abiertos:
# - Ambiente SIN WAF: http://[IP_APACHE_SIN_WAF]
# - Ambiente CON WAF: http://wafshowcase-waf-demo.oracledemo.com
```

### 🎯 Demo Ejecutiva (15-20 minutos)

#### 🔴 Parte 1: Ambiente SIN WAF (8 minutos)

```bash
# 1. Introducción (2 min)
echo "Vamos a simular un ambiente real sin protección WAF"
curl -I http://[IP_APACHE_SIN_WAF]

# 2. Demostración de Ataques (5 min)
# SQL Injection
curl "http://[IP_APACHE_SIN_WAF]/?demo=sql&user_id=1'"
curl "http://[IP_APACHE_SIN_WAF]/?demo=sql&user_id=1%27%20OR%20%271%27=%271"

# XSS
curl "http://[IP_APACHE_SIN_WAF]/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"

# Directory Traversal  
curl "http://[IP_APACHE_SIN_WAF]/?demo=path&file=../../etc/passwd"

# 3. Impacto Comercial (1 min)
echo "💰 Costo promedio de violación: $4.45M USD"
echo "⏱️ Tiempo de detección: 287 días"
echo "📉 Pérdida de confianza: 65%"
```

#### 🟢 Parte 2: Ambiente CON WAF (8 minutos)

```bash
# 1. Introducción a la Protección (2 min)
echo "Ahora veamos el mismo ambiente, pero protegido por WAF"
curl -I http://wafshowcase-waf-demo.oracledemo.com

# 2. Demostración de Protección (5 min)  
# Mismos ataques - DEBEN retornar 403
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=sql&user_id=1'"
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=sql&user_id=1%27%20OR%20%271%27=%271"
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=path&file=../../etc/passwd"

# 3. Valor del WAF (1 min)
echo "✅ 85% de ataques bloqueados"
echo "⚡ 3.2 segundos tiempo de detección"  
echo "🛡️ Protección 24/7 automatizada"
echo "💰 ROI positivo en 3-6 meses"
```

### 🧪 Demo Técnica Detallada (25-30 minutos)

Para audiencias técnicas, usar scripts automatizados:

```bash
# Demo automatizada completa
./scripts/vulnerability-test.sh http://[IP_APACHE_SIN_WAF] demo

# Comparación lado a lado
./demo-scripts/demo-comparativo.sh

# Generación de reportes
./scripts/generate-report.sh http://[IP_APACHE_SIN_WAF] "Cliente Sin WAF"
./scripts/generate-report.sh http://wafshowcase-waf-demo.oracledemo.com "Cliente Con WAF"
```

---

## ⚙️ Comandos y Validaciones

### 🔍 Comandos de Verificación

#### Estado de Ambientes
```bash
# Ambiente SIN WAF
cd ambiente-sin-waf
terraform output architecture_summary
terraform output connection_info

# Ambiente CON WAF  
cd ambiente-con-waf
terraform output architecture_summary
terraform output waf_status
terraform output waf_domain
```

#### Tests de Conectividad
```bash
# Verificar ambientes activos
curl -I http://[IP_APACHE_SIN_WAF]                           # 200 OK
curl -I http://wafshowcase-waf-demo.oracledemo.com          # 200 OK

# Verificar headers de seguridad
curl -v http://[IP_APACHE_SIN_WAF] 2>&1 | grep -E "(Server|X-)"
curl -v http://wafshowcase-waf-demo.oracledemo.com 2>&1 | grep -E "(Server|X-)"
```

### 🚨 Tests de Vulnerabilidad

#### SQL Injection
```bash
# SIN WAF (vulnerable)
curl "http://[IP_APACHE_SIN_WAF]/?demo=sql&user_id=1'"
# Debe mostrar: PATRÓN DE SQL INJECTION DETECTADO

# CON WAF (protegido)  
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=sql&user_id=1'"
# Debe retornar: HTTP 403 Forbidden
```

#### Cross-Site Scripting (XSS)
```bash
# SIN WAF (vulnerable)
curl "http://[IP_APACHE_SIN_WAF]/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"
# Debe mostrar: PATRÓN XSS DETECTADO

# CON WAF (protegido)
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"  
# Debe retornar: HTTP 403 Forbidden
```

#### Directory Traversal
```bash
# SIN WAF (vulnerable)
curl "http://[IP_APACHE_SIN_WAF]/?demo=path&file=../../etc/passwd"
# Debe mostrar: PATRÓN DE DIRECTORY TRAVERSAL DETECTADO

# CON WAF (protegido)
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=path&file=../../etc/passwd"
# Debe retornar: HTTP 403 Forbidden
```

### 📊 Scripts de Validación Automatizada

```bash
# Verificación rápida
./scripts/quick-check.sh http://[IP_APACHE_SIN_WAF]
./scripts/quick-check.sh http://wafshowcase-waf-demo.oracledemo.com

# Demo automatizada
./scripts/vulnerability-test.sh http://[IP_APACHE_SIN_WAF] demo
./scripts/vulnerability-test.sh http://wafshowcase-waf-demo.oracledemo.com demo

# Validación específica WAF
./scripts/waf-validation.sh http://wafshowcase-waf-demo.oracledemo.com http://[IP_APACHE_SIN_WAF]

# Generar reportes profesionales  
./scripts/generate-report.sh http://[IP_APACHE_SIN_WAF] "Ambiente Vulnerable"
./scripts/generate-report.sh http://wafshowcase-waf-demo.oracledemo.com "Ambiente Protegido"
```

---

## 🧹 Limpieza y Mantenimiento

### 🗑️ Limpieza Post-Demo

```bash
# Destruir ambiente SIN WAF
cd ambiente-sin-waf
terraform destroy -auto-approve

# Destruir ambiente CON WAF  
cd ambiente-con-waf
terraform destroy -auto-approve

# Limpiar configuración DNS local
sudo sed -i '/wafshowcase-waf-demo.oracledemo.com/d' /etc/hosts

# Limpiar archivos temporales
rm -f deployment-info-*.txt
rm -f security-report-*.md
```

### 🔄 Mantenimiento de Ambientes

```bash
# Verificar estado de recursos
cd ambiente-sin-waf
terraform state list

cd ambiente-con-waf  
terraform state list

# Actualizar configuraciones (si necesario)
terraform plan
terraform apply

# Backup de configuraciones importantes
cp terraform.tfvars terraform.tfvars.backup.$(date +%Y%m%d)
```

---

## 🔧 Troubleshooting

### ❗ Problemas Comunes

#### 1. Credenciales OCI
```bash
# Verificar archivo de clave privada
ls -la ~/.oci/oci_api_key.pem

# Verificar conectividad
oci iam region list --auth api_key

# Actualizar rutas en terraform.tfvars si necesario
sed -i 's|/home/opc|/home/jesmonsa|g' */terraform.tfvars
```

#### 2. Límites de Servicio
```bash  
# Verificar límites en OCI Console
# - Compute shapes disponibles
# - Database system limits  
# - WAF policy limits
# - Load balancer limits

# Mensaje común: "Out of capacity"
# Solución: Cambiar shape o región
```

#### 3. WAF No Funciona
```bash
# Verificar configuración DNS
nslookup wafshowcase-waf-demo.oracledemo.com

# Verificar entrada en /etc/hosts
grep wafshowcase /etc/hosts

# Re-agregar si necesario
echo "[IP_LB] wafshowcase-waf-demo.oracledemo.com" | sudo tee -a /etc/hosts

# Verificar WAF policy
cd ambiente-con-waf
terraform output waf_ocid
terraform output waf_status
```

#### 4. Database Toma Mucho Tiempo
```bash
# Normal: 45-60 minutos para Oracle DB System
# Monitorear progreso:
cd ambiente-*/
terraform show | grep db_system

# En OCI Console: Database > DB Systems
# Verificar estado: PROVISIONING -> AVAILABLE
```

#### 5. Aplicación No Carga
```bash
# Verificar health check
curl http://[IP]/health

# Verificar logs cloud-init
ssh -i private_key opc@[IP_APACHE]
sudo tail -f /var/log/cloud-init-output.log

# Verificar servicio Apache
sudo systemctl status httpd
sudo systemctl restart httpd
```

### 📞 Comandos de Diagnóstico

```bash
# Estado general Terraform
terraform state list
terraform output

# Conectividad de red
ping [IP_TARGET]
telnet [IP_TARGET] 80
curl -v http://[IP_TARGET]

# DNS resolution
nslookup [DOMAIN]
dig [DOMAIN]

# Logs del sistema
ssh -i private_key opc@[IP]
sudo journalctl -u httpd -f
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log
```

---

## 📞 Soporte y Recursos

### 📚 Documentación Adicional
- **OCI WAF**: [docs.oracle.com/iaas/waas](https://docs.oracle.com/en-us/iaas/Content/WAF/home.htm)
- **OWASP Top 10**: [owasp.org/www-project-top-ten](https://owasp.org/www-project-top-ten/)
- **Terraform OCI Provider**: [registry.terraform.io/providers/oracle/oci](https://registry.terraform.io/providers/oracle/oci/latest/docs)

### 🎯 Casos de Uso por Audiencia

#### C-Level / Ejecutivos
- Enfoque en ROI y costo de violaciones
- Métricas de negocio (tiempo, dinero, reputación)
- Comparación visual simple SIN vs CON WAF

#### Equipos Técnicos  
- Detalles de configuración WAF
- Reglas específicas y personalizaciones
- Integración con otros servicios OCI

#### Ventas / Preventas
- Demo dramatizada con pausas
- Casos de uso reales de la industria
- Llamadas a la acción claras

---

**🎯 ¡Demo profesional lista para impactar a cualquier audiencia!**

*Tiempo total de preparación: 2-3 horas*  
*Tiempo total de demo: 15-30 minutos según audiencia*  
*Impacto: Demostración tangible del valor de OCI WAF* 🛡️