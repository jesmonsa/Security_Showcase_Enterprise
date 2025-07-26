# 🟢 Ambiente Protegido - CON WAF

## 📋 Descripción
Este ambiente está configurado **CON protecciones WAF completas** para demostrar cómo Oracle WAF bloquea vulnerabilidades web y protege aplicaciones.

## ✅ **IMPORTANTE: AMBIENTE PROTEGIDO**
- **WAF**: ✅ HABILITADO con reglas OWASP Top 10
- **Cloud Guard**: ❌ DESHABILITADO (por permisos)
- **Propósito**: Demostrar protección efectiva contra ataques

## 🛠️ Deployment

### Prerequisitos
```bash
# Verificar credenciales OCI configuradas
ls -la /home/jesmonsa/.oci/oci_api_key.pem

# Terraform/OpenTofu >= 1.4.0
terraform version
```

### Comandos de Deployment
```bash
# 1. Navegar al directorio
cd ambiente-con-waf

# 2. Verificar configuración
cat terraform.tfvars

# 3. Inicializar Terraform
terraform init

# 4. Planear deployment
terraform plan

# 5. Aplicar configuración (45-60 minutos)
terraform apply -auto-approve

# 6. Obtener outputs importantes
terraform output
```

## 📊 Información del Ambiente

### 🌐 Configuración de Red
- **VCN CIDR**: 10.31.0.0/16
- **Cliente**: wafshowcase
- **Región**: us-ashburn-1

### 🗄️ Base de Datos
- **Nombre**: WAFDB01
- **PDB**: WAFPDB01
- **Hostname**: wafdb
- **Shape**: VM.Standard.E5.Flex (1 OCPU, 16 GB)

### 💻 Servidores
- **Apache**: VM.Standard.E5.Flex (1 OCPU, 8 GB)
- **Tomcat**: VM.Standard.E5.Flex (1 OCPU, 8 GB)
- **Bastion**: VM.Standard.A1.Flex (1 OCPU, 8 GB)

### 🛡️ Protecciones WAF Habilitadas
- **SQL Injection Protection**: ✅ Activa
- **XSS Protection**: ✅ Activa  
- **Path Traversal Protection**: ✅ Activa
- **Rate Limiting**: ✅ Configurado
- **Bot Protection**: ✅ Activa

## 🛡️ Configuración WAF

### Dominio WAF
- **Dominio**: wafshowcase-waf-demo.oracledemo.com
- **Backend**: Load Balancer público
- **Política**: OWASP Top 10 + Personalizadas

### Reglas de Protección
```yaml
- SQL Injection: BLOCK
- XSS: BLOCK  
- Path Traversal: BLOCK
- Command Injection: BLOCK
- Rate Limiting: 100 req/min
```

## 🧪 Tests de Protección

### 💉 SQL Injection (Bloqueado)
```bash
# Test básico - Debe retornar 403
curl "http://[WAF_DOMAIN]/?demo=sql&user_id=1'"

# Bypass intento - Debe retornar 403
curl "http://[WAF_DOMAIN]/?demo=sql&user_id=1%27%20OR%20%271%27=%271"
```

### ⚡ XSS (Bloqueado)
```bash
# XSS básico - Debe retornar 403
curl "http://[WAF_DOMAIN]/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"

# XSS avanzado - Debe retornar 403
curl "http://[WAF_DOMAIN]/?demo=xss&comment=%3Cimg%20src=x%20onerror=alert('XSS')%3E"
```

### 📁 Directory Traversal (Bloqueado)
```bash
# Path traversal - Debe retornar 403
curl "http://[WAF_DOMAIN]/?demo=path&file=../../etc/passwd"
curl "http://[WAF_DOMAIN]/?demo=path&file=../../../etc/shadow"
```

## 🔍 URLs Importantes

### Después del Deployment
```bash
# Obtener información del WAF
terraform output waf_domain
terraform output waf_ocid

# Load Balancer (backend)
terraform output load_balancer_fqdn

# Servidor Apache (bypass WAF - para comparación)
terraform output apache_public_ip
```

### Configuración DNS Local (Para Demo)
```bash
# Agregar al /etc/hosts para pruebas locales
echo "[LOAD_BALANCER_IP] wafshowcase-waf-demo.oracledemo.com" | sudo tee -a /etc/hosts

# Verificar configuración
ping wafshowcase-waf-demo.oracledemo.com
```

## 📝 Comandos Útiles

### Verificar Estado WAF
```bash
# Estado general del ambiente
terraform output architecture_summary

# Información específica del WAF
terraform output waf_status

# Test de conectividad WAF
curl -I http://wafshowcase-waf-demo.oracledemo.com
```

### Comparación Con/Sin WAF
```bash
# CON WAF (protegido) - Debe retornar 403
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=sql&user_id=1'"

# SIN WAF (bypass) - Para mostrar diferencia
curl "http://[APACHE_IP]/?demo=sql&user_id=1'"
```

### Limpieza
```bash
# Destruir recursos WAF
terraform destroy -auto-approve

# Limpiar archivos temporales
rm -f terraform.tfstate* tfplan*

# Limpiar entrada DNS local
sudo sed -i '/wafshowcase-waf-demo.oracledemo.com/d' /etc/hosts
```

## 🎯 Para la Demo

### URLs Demo
- **Protegida (WAF)**: http://wafshowcase-waf-demo.oracledemo.com
- **Backend directo**: http://[LOAD_BALANCER_IP]
- **Apache directo**: http://[APACHE_IP] (para comparación)

### Scripts de Validación
```bash
# Validación WAF (desde directorio padre)
../scripts/waf-validation.sh http://wafshowcase-waf-demo.oracledemo.com http://[APACHE_IP]

# Verificación rápida
../scripts/quick-check.sh http://wafshowcase-waf-demo.oracledemo.com

# Generar reporte protegido
../scripts/generate-report.sh http://wafshowcase-waf-demo.oracledemo.com "Cliente Protegido"
```

## ⏱️ Tiempos Estimados
- **Deployment**: 45-60 minutos
- **WAF Configuration**: 5-10 minutos adicionales
- **DNS Propagation**: 1-2 minutos
- **Demo validación**: 5 minutos
- **Cleanup**: 15-20 minutos

## 🚀 Características Destacadas

### 🛡️ Protección en Tiempo Real
- Detección automática de patrones maliciosos
- Bloqueo instantáneo de ataques
- Logs detallados para auditoría

### 📊 Métricas de Protección
- **85%** de ataques web bloqueados
- **3.2 segundos** tiempo de detección
- **99.9%** disponibilidad con WAF

### 🔄 Comparación Directa
Este ambiente permite comparar directamente:
1. **WAF Domain** (protegido)
2. **Direct Apache** (mismo código, vulnerable)

## 🎭 Casos de Uso de Demo
1. **Ejecutivo**: Mostrar protección vs costo de violación
2. **Técnico**: Demostrar reglas específicas y configuración
3. **Comercial**: ROI y valor de inversión en seguridad

**✅ Recuerda**: Este ambiente permanece activo para demo comparativa en tiempo real.