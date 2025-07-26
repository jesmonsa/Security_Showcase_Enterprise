# 🚨 Ambiente Vulnerable - Oracle 23ai SIN Protecciones

## ⚠️ ADVERTENCIA CRÍTICA DE SEGURIDAD

```
🚨🚨🚨 ESTE AMBIENTE ES DELIBERADAMENTE INSEGURO 🚨🚨🚨

- NUNCA usar en producción
- NUNCA almacenar datos reales
- NUNCA exponer a internet sin supervisión
- DESTRUIR inmediatamente después de demo
- SOLO para fines de demostración y entrenamiento
```

---

## 📋 Descripción

Este ambiente implementa **DELIBERADAMENTE** todas las malas prácticas de seguridad en Oracle Cloud Infrastructure para crear un contraste dramático con el ambiente seguro.

### 🎯 **Propósito**
- Demostrar **qué NO hacer** en la nube
- Mostrar vulnerabilidades **reales y explotables**
- Crear **contraste dramático** con mejores prácticas
- Cuantificar **impacto financiero** de falta de seguridad

---

## 🏗️ Arquitectura Vulnerable

### 🔴 **Componentes Inseguros por Capa**

#### **1. IAM - Permisos Excesivos**
```
❌ Un solo compartment para todos los recursos
❌ Todos los usuarios con permisos de administrador
❌ Grupos dinámicos con acceso excesivo
❌ Sin rotación de credenciales
❌ Sin MFA obligatorio
```

#### **2. Red - Completamente Expuesta**
```
❌ Base de datos en subnet PÚBLICA
❌ Puerto Oracle 1521 abierto a internet (0.0.0.0/0)
❌ Security Lists permisivas para TODO el tráfico
❌ Sin WAF, sin protección DDoS
❌ Sin Flow Logs, sin monitoreo de red
❌ Sin Bastion Service - SSH directo
```

#### **3. Oracle 23ai - SIN Database Firewall**
```
❌ Database Firewall: DESHABILITADO
❌ Data Safe: DESHABILITADO  
❌ Password débil: Welcome123!
❌ Acceso público directo
❌ Sin cifrado con customer-managed keys
❌ Backups sin cifrado adicional
❌ Sin IP whitelisting
```

#### **4. Compute - Sin Hardening**
```
❌ SSH con password habilitado
❌ Instancias con IP pública directa
❌ SELinux deshabilitado
❌ Firewall del SO deshabilitado
❌ Sin Vulnerability Scanning
❌ Servicios innecesarios habilitados
❌ Credenciales hardcodeadas en archivos
```

#### **5. Aplicación - OWASP Top 10 Vulnerable**
```
❌ SQL Injection sin protección
❌ XSS sin filtrado de input
❌ Path Traversal habilitado
❌ Information Disclosure activo
❌ Secretos hardcodeados en código
❌ Debug mode habilitado
❌ Headers de seguridad ausentes
❌ HTTP sin HTTPS enforcement
```

#### **6. Monitoreo - Completamente Ciego**
```
❌ Cloud Guard: DESHABILITADO
❌ Audit logging: MÍNIMO
❌ Sin alertas de seguridad
❌ Sin SIEM integration
❌ Sin vulnerability scanning automático
❌ Retención de logs: Solo 30 días
```

---

## 🚀 Quick Start

### **1. Prerequisitos**
```bash
# Terraform/OpenTofu >= 1.4.0
terraform version

# Credenciales OCI configuradas
ls -la ~/.oci/oci_api_key.pem

# Conectividad OCI verificada
oci iam region list --auth api_key
```

### **2. Configuración**
```bash
# Copiar variables de ejemplo
cp terraform.tfvars.example terraform.tfvars

# IMPORTANTE: Editar terraform.tfvars con tus credenciales
# REQUERIDO: acknowledge_insecure_deployment = true
# REQUERIDO: demo_disclaimer_accepted = true
```

### **3. Deployment (60-90 minutos)**
```bash
# Deployment automatizado con advertencias
./deploy-vulnerable-environment.sh

# O manual
terraform init
terraform plan
terraform apply
```

### **4. Destrucción (CRÍTICA)**
```bash
# DESTRUIR inmediatamente después de demo
terraform destroy -auto-approve
```

---

## 🧪 Tests de Vulnerabilidad

### **Aplicación Web Vulnerable**

#### **SQL Injection**
```bash
# Test básico
curl "http://[IP]/?demo=sql&user_id=1'"

# Test con bypass
curl "http://[IP]/?demo=sql&user_id=1' OR '1'='1"

# Resultado esperado: VULNERABLE - Patrón detectado
```

#### **Cross-Site Scripting (XSS)**
```bash
# Test de XSS
curl "http://[IP]/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"

# Resultado esperado: VULNERABLE - Script sin filtrar
```

#### **Path Traversal**
```bash
# Test de directory traversal
curl "http://[IP]/?demo=path&file=../../etc/passwd"

# Resultado esperado: VULNERABLE - Archivos del sistema accesibles
```

#### **Information Disclosure**
```bash
# Información del servidor expuesta
curl "http://[IP]/server-info"
curl "http://[IP]/health.php"

# Credenciales expuestas
curl "http://[IP]/config.php"
curl "http://[IP]/.env.backup"
```

### **Oracle 23ai Database - Sin Database Firewall**

#### **Conectividad Directa**
```bash
# Test de puerto abierto
telnet [DB_IP] 1521

# Test de conexión directa (si tienes sqlplus)
sqlplus admin/Welcome123!@[DB_IP]:1521/VULNDB23
```

#### **SQL Injection a Nivel DB**
```bash
# A través de aplicación web - llega directo a DB
curl "http://[IP]/?demo=sql&user_id=1'; DROP TABLE users; --"

# Sin Database Firewall, queries maliciosas pasan sin filtro
```

### **Network Security Testing**

#### **Port Scanning**
```bash
# Scan básico
nmap -p 22,80,443,1521 [IP]

# Scan completo (toma tiempo)
nmap -p- [IP]

# Resultado esperado: Múltiples puertos abiertos
```

#### **SSH Brute Force (Ético)**
```bash
# Test de password débil (solo en ambiente controlado)
hydra -l opc -p Welcome123! ssh://[IP]

# Resultado esperado: VULNERABLE si password auth habilitado
```

---

## 📊 Métricas de Impacto Demostradas

### **💰 Costo Financiero de Vulnerabilidades**
- **Costo promedio de violación**: $4.45 millones USD
- **Tiempo de detección**: 287 días promedio
- **Pérdida de clientes**: 65% promedio
- **Multas regulatorias**: $10M+ USD potencial
- **Tiempo de recuperación**: 280 días promedio

### **🎯 Comparación con Ambiente Seguro**
| Métrica | Vulnerable | Seguro | Diferencia |
|---------|------------|--------|------------|
| Tiempo detección | 287 días | 3.2 segundos | 99.99% mejora |
| Ataques bloqueados | 0% | 85% | +85% protección |
| Compliance | 0% | 95%+ | Cumplimiento total |
| Costo protección | $0 | $3,360/año | ROI 132,340% |

---

## 🎭 Uso en Demos

### **Demo Ejecutiva (15 min)**
1. **Mostrar vulnerabilidades** (5 min)
   - Ejecutar tests SQL injection, XSS
   - Mostrar acceso directo a base de datos
   
2. **Impacto financiero** (5 min)
   - $4.45M costo de violación
   - 287 días para detectar
   
3. **Solución Oracle** (5 min)
   - Oracle 23ai + Database Firewall
   - Cloud Guard + Data Safe
   - ROI 132,340%

### **Demo Técnica (30 min)**
1. **Por capas** (20 min)
   - IAM, Network, Compute, Database, App
   - Mostrar vulnerabilidades específicas
   
2. **Oracle 23ai sin Database Firewall** (5 min)
   - SQL injection llega directo a DB
   - Sin filtrado de queries
   
3. **Comparación** (5 min)
   - Mismo test en ambiente seguro
   - Mostrar bloqueo por Database Firewall

### **Demo Comercial (20 min)**
1. **Problema** (5 min)
   - Mostrar vulnerabilidades activas
   
2. **Impacto de negocio** (10 min)
   - Casos reales de violaciones
   - Costos cuantificados
   
3. **Solución Oracle** (5 min)
   - Únicos con Database Firewall en 23ai
   - Ecosystem completo OCI Security

---

## 🔧 Troubleshooting

### **Problemas Comunes**

#### **Credenciales OCI**
```bash
# Verificar archivo de clave
ls -la ~/.oci/oci_api_key.pem

# Test de conectividad
oci iam region list --auth api_key
```

#### **Variables No Configuradas**
```bash
# Verificar acknowledgment
grep "acknowledge_insecure_deployment" terraform.tfvars
grep "demo_disclaimer_accepted" terraform.tfvars

# Ambos deben ser = true
```

#### **Database Toma Mucho Tiempo**
```bash
# Normal: 45-60 minutos para Oracle DB System
# Monitorear en OCI Console: Database > DB Systems
# Estado debe cambiar: PROVISIONING -> AVAILABLE
```

#### **Aplicación No Responde**
```bash
# Verificar health check
curl http://[IP]/health.php

# Verificar servicio Apache
ssh -i modules/unprotected-compute/vulnerable_private_key.pem opc@[IP]
sudo systemctl status httpd
```

---

## 📚 Archivos Importantes

### **Configuración**
- `terraform.tfvars.example` - Template de configuración
- `variables.tf` - Definición de variables
- `main.tf` - Orquestación principal

### **Módulos Inseguros**
- `modules/insecure-iam/` - IAM con permisos excesivos
- `modules/exposed-network/` - Red completamente abierta
- `modules/vulnerable-database/` - Oracle 23ai SIN protecciones
- `modules/unprotected-compute/` - Compute sin hardening
- `modules/vulnerable-application/` - App con OWASP Top 10
- `modules/monitoring-disabled/` - Sin observabilidad

### **Scripts**
- `deploy-vulnerable-environment.sh` - Deployment automatizado
- `../comparison-scripts/vulnerability-tests/test-all-vulnerabilities.sh` - Tests automatizados

---

## 💡 Lecciones Aprendidas

### **Vulnerabilidades Más Críticas**
1. **Oracle 23ai sin Database Firewall** - SQL injection directo a DB
2. **Base de datos pública** - Puerto 1521 abierto a internet
3. **Credenciales débiles** - Welcome123! en múltiples lugares
4. **Sin monitoreo** - Ataques pasan desapercibidos 287 días

### **Impacto en Compliance**
- **PCI DSS**: Falla todos los requisitos
- **SOX**: Sin controles adecuados
- **GDPR**: Sin protección de datos
- **HIPAA**: PHI completamente expuesto

### **Por Qué Oracle 23ai + Database Firewall es Crítico**
- **Único en el mercado** - AWS RDS/Azure SQL no tienen equivalente
- **Protección en tiempo real** - Bloquea SQL injection a nivel DB
- **Sin impacto en performance** - Filtering transparente
- **Compliance automático** - Cumple regulaciones automáticamente

---

## 🚨 Recordatorios Finales

### **CRÍTICO**
- ✅ Este ambiente SERÁ comprometido por atacantes reales
- ✅ Destruir inmediatamente después de demo
- ✅ NUNCA usar con datos de producción
- ✅ Monitorear costos - puede ser caro

### **Para la Demo**
- ✅ Preparar screenshots como backup
- ✅ Probar todos los comandos antes de demo en vivo
- ✅ Tener métricas financieras listas
- ✅ Personalizar mensajes según audiencia

### **Contraste con Ambiente Seguro**
- ✅ Desplegar ambiente seguro para comparación
- ✅ Mostrar mismos tests - deben fallar en seguro
- ✅ Documentar diferencias dramáticas
- ✅ Cuantificar ROI de seguridad

---

**🔥 La demostración más impactante del valor de Oracle 23ai Database Firewall y OCI Security 🔥**

*Contraste garantizado que convence a cualquier audiencia* 💰🛡️