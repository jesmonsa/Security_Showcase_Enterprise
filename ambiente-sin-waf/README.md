# 🔴 Ambiente Vulnerable - SIN WAF

## 📋 Descripción
Este ambiente está configurado **SIN protecciones WAF** para demostrar vulnerabilidades web comunes y el impacto de ataques exitosos.

## ⚠️ **IMPORTANTE: AMBIENTE VULNERABLE**
- **WAF**: ❌ DESHABILITADO
- **Cloud Guard**: ❌ DESHABILITADO  
- **Propósito**: Demostrar vulnerabilidades activas

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
cd ambiente-sin-waf

# 2. Verificar configuración
cat terraform.tfvars

# 3. Inicializar Terraform
terraform init

# 4. Planear deployment
terraform plan

# 5. Aplicar configuración (45-60 minutos)
terraform apply -auto-approve

# 6. Obtener outputs
terraform output
```

## 📊 Información del Ambiente

### 🌐 Configuración de Red
- **VCN CIDR**: 10.30.0.0/16
- **Cliente**: vulndemo
- **Región**: us-ashburn-1

### 🗄️ Base de Datos
- **Nombre**: VULNDB01
- **PDB**: VULNPDB  
- **Hostname**: vulndb
- **Shape**: VM.Standard.E5.Flex (1 OCPU, 16 GB)

### 💻 Servidores
- **Apache**: VM.Standard.E5.Flex (1 OCPU, 8 GB)
- **Tomcat**: VM.Standard.E5.Flex (1 OCPU, 8 GB)
- **Bastion**: VM.Standard.A1.Flex (1 OCPU, 8 GB)

## 🚨 Vulnerabilidades Disponibles

### 💉 SQL Injection
```bash
# Test básico
curl "http://[LOAD_BALANCER_IP]/?demo=sql&user_id=1'"

# Bypass de autenticación
curl "http://[APACHE_IP]/?demo=sql&user_id=1%27%20OR%20%271%27=%271"
```

### ⚡ Cross-Site Scripting (XSS)
```bash
# XSS básico
curl "http://[APACHE_IP]/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"

# XSS avanzado
curl "http://[APACHE_IP]/?demo=xss&comment=%3Cimg%20src=x%20onerror=alert('XSS')%3E"
```

### 📁 Directory Traversal
```bash
# Acceso a archivos del sistema
curl "http://[APACHE_IP]/?demo=path&file=../../etc/passwd"
curl "http://[APACHE_IP]/?demo=path&file=../../../etc/shadow"
```

## 🔍 URLs Importantes

Después del deployment, obtendrás:
- **Load Balancer**: `terraform output load_balancer_fqdn`
- **Apache Server**: `terraform output apache_public_ip`  
- **Bastion Host**: `terraform output bastion_public_ip`

## 📝 Comandos Útiles

### Verificar Estado
```bash
# Estado general
terraform output architecture_summary

# Información de conexión
terraform output connection_info

# Estado de servicios
curl -I http://[LOAD_BALANCER_IP]
```

### Limpieza
```bash
# Destruir recursos
terraform destroy -auto-approve

# Limpiar archivos temporales
rm -f terraform.tfstate* tfplan*
```

## 🎯 Para la Demo

### URLs Clave
- **Vulnerable (directa)**: http://[APACHE_IP]
- **Load Balancer**: http://[LOAD_BALANCER_IP]

### Scripts de Demo
```bash
# Verificación rápida (desde directorio padre)
../scripts/quick-check.sh http://[APACHE_IP]

# Demo automatizada
../scripts/vulnerability-test.sh http://[APACHE_IP] demo

# Generar reporte
../scripts/generate-report.sh http://[APACHE_IP] "Cliente Demo"
```

## ⏱️ Tiempos Estimados
- **Deployment**: 45-60 minutos
- **Database Creation**: 45-50 minutos (mayor componente)
- **Demo completa**: 5-10 minutos
- **Cleanup**: 10-15 minutos

## 🚀 Next Steps
1. Completar deployment de este ambiente
2. Probar todas las vulnerabilidades
3. Documentar IPs y URLs
4. Proceder con ambiente CON WAF para comparación

**⚠️ Recuerda**: Este ambiente queda corriendo para la demo comparativa.