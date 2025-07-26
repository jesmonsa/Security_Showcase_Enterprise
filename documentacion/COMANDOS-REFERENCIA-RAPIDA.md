# 🚀 Comandos de Referencia Rápida

## 📋 Deployment Rápido

### 🔴 Ambiente SIN WAF
```bash
# Deployment automatizado
./demo-scripts/deploy-sin-waf.sh

# Manual
cd ambiente-sin-waf
terraform init
terraform plan
terraform apply -auto-approve
terraform output
```

### 🟢 Ambiente CON WAF  
```bash
# Deployment automatizado
./demo-scripts/deploy-con-waf.sh

# Manual
cd ambiente-con-waf  
terraform init
terraform plan
terraform apply -auto-approve
terraform output

# Configurar DNS local
echo "[IP_LB] wafshowcase-waf-demo.oracledemo.com" | sudo tee -a /etc/hosts
```

---

## 🧪 Tests de Vulnerabilidad

### 💉 SQL Injection
```bash
# SIN WAF (vulnerable)
curl "http://[IP_APACHE_SIN_WAF]/?demo=sql&user_id=1'"
curl "http://[IP_APACHE_SIN_WAF]/?demo=sql&user_id=1%27%20OR%20%271%27=%271"

# CON WAF (protegido - debe retornar 403)
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=sql&user_id=1'"
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=sql&user_id=1%27%20OR%20%271%27=%271"
```

### ⚡ Cross-Site Scripting (XSS)
```bash
# SIN WAF (vulnerable)
curl "http://[IP_APACHE_SIN_WAF]/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"
curl "http://[IP_APACHE_SIN_WAF]/?demo=xss&comment=%3Cimg%20src=x%20onerror=alert('XSS')%3E"

# CON WAF (protegido - debe retornar 403)
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=xss&comment=%3Cimg%20src=x%20onerror=alert('XSS')%3E"
```

### 📁 Directory Traversal
```bash
# SIN WAF (vulnerable)
curl "http://[IP_APACHE_SIN_WAF]/?demo=path&file=../../etc/passwd"
curl "http://[IP_APACHE_SIN_WAF]/?demo=path&file=../../../etc/shadow"

# CON WAF (protegido - debe retornar 403)
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=path&file=../../etc/passwd"
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=path&file=../../../etc/shadow"
```

---

## 🔍 Verificación y Estado

### 📊 Estado de Ambientes
```bash
# SIN WAF
cd ambiente-sin-waf
terraform output architecture_summary
terraform output connection_info

# CON WAF
cd ambiente-con-waf
terraform output architecture_summary  
terraform output waf_status
terraform output waf_domain
```

### 🌐 Tests de Conectividad
```bash
# Verificar ambientes activos
curl -I http://[IP_APACHE_SIN_WAF]                    # Debe retornar 200
curl -I http://wafshowcase-waf-demo.oracledemo.com    # Debe retornar 200

# Verificar headers de seguridad
curl -v http://[IP_APACHE_SIN_WAF] 2>&1 | grep -E "(Server|X-)"
curl -v http://wafshowcase-waf-demo.oracledemo.com 2>&1 | grep -E "(Server|X-)"
```

### 🔧 Métodos HTTP Peligrosos
```bash
# Verificar métodos permitidos
curl -X OPTIONS http://[IP_APACHE_SIN_WAF] -v
curl -X PUT http://[IP_APACHE_SIN_WAF] -v 
curl -X DELETE http://[IP_APACHE_SIN_WAF] -v
```

---

## 🤖 Scripts Automatizados

### 🧪 Testing Automatizado
```bash
# Verificación rápida pre-demo
./scripts/quick-check.sh http://[IP_APACHE_SIN_WAF]
./scripts/quick-check.sh http://wafshowcase-waf-demo.oracledemo.com

# Demo automatizada completa
./scripts/vulnerability-test.sh http://[IP_APACHE_SIN_WAF] demo
./scripts/vulnerability-test.sh http://wafshowcase-waf-demo.oracledemo.com demo

# Validación específica WAF
./scripts/waf-validation.sh http://wafshowcase-waf-demo.oracledemo.com http://[IP_APACHE_SIN_WAF]
```

### 📊 Generación de Reportes
```bash
# Reportes individuales
./scripts/generate-report.sh http://[IP_APACHE_SIN_WAF] "Ambiente Vulnerable"
./scripts/generate-report.sh http://wafshowcase-waf-demo.oracledemo.com "Ambiente Protegido"

# Demo comparativo completo
./demo-scripts/demo-comparativo.sh
```

---

## 🎭 Demo en Vivo

### 📋 Preparación (5 minutos)
```bash
# 1. Verificar conectividad
curl -I http://[IP_APACHE_SIN_WAF]
curl -I http://wafshowcase-waf-demo.oracledemo.com

# 2. Obtener URLs de archivos de info
cat deployment-info-sin-waf.txt | grep "Apache Directo"
cat deployment-info-con-waf.txt | grep "WAF Domain"

# 3. Preparar navegador con tabs abiertos
```

### 🎯 Demo Ejecutiva (15 minutos)
```bash
# PARTE 1: SIN WAF (8 min)
curl -I http://[IP_APACHE_SIN_WAF]
curl "http://[IP_APACHE_SIN_WAF]/?demo=sql&user_id=1'"
curl "http://[IP_APACHE_SIN_WAF]/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"

# PARTE 2: CON WAF (7 min)  
curl -I http://wafshowcase-waf-demo.oracledemo.com
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=sql&user_id=1'"
curl "http://wafshowcase-waf-demo.oracledemo.com/?demo=xss&comment=%3Cscript%3Ealert('XSS')%3C/script%3E"
```

### 🧪 Demo Técnica (25 minutos)
```bash
# Usar scripts automatizados con pausas
./scripts/vulnerability-test.sh http://[IP_APACHE_SIN_WAF] demo
./scripts/vulnerability-test.sh http://wafshowcase-waf-demo.oracledemo.com demo
./demo-scripts/demo-comparativo.sh
```

---

## 🗑️ Limpieza

### 🧹 Limpieza Rápida
```bash
# Destruir ambientes
cd ambiente-sin-waf && terraform destroy -auto-approve
cd ambiente-con-waf && terraform destroy -auto-approve

# Limpiar DNS local
sudo sed -i '/wafshowcase-waf-demo.oracledemo.com/d' /etc/hosts

# Limpiar archivos temporales
rm -f deployment-info-*.txt security-report-*.md demo-summary-*.txt
```

### 🔄 Limpieza Selectiva
```bash
# Solo SIN WAF
cd ambiente-sin-waf
terraform destroy -auto-approve

# Solo CON WAF
cd ambiente-con-waf
terraform destroy -auto-approve
sudo sed -i '/wafshowcase-waf-demo.oracledemo.com/d' /etc/hosts
```

---

## 🔧 Troubleshooting Rápido

### ❗ Problemas Comunes
```bash
# Credenciales OCI
ls -la ~/.oci/oci_api_key.pem
oci iam region list --auth api_key

# DNS WAF no funciona
grep wafshowcase /etc/hosts
echo "[IP_LB] wafshowcase-waf-demo.oracledemo.com" | sudo tee -a /etc/hosts

# Aplicación no carga
curl http://[IP]/health
ssh -i private_key opc@[IP] 'sudo systemctl status httpd'

# Database toma mucho tiempo (normal: 45-60 min)
cd ambiente-*/
terraform show | grep db_system
```

### 📞 Comandos de Diagnóstico
```bash
# Estado Terraform
terraform state list
terraform output

# Conectividad de red  
ping [IP]
telnet [IP] 80
curl -v http://[IP]

# Logs del sistema
ssh -i private_key opc@[IP]
sudo tail -f /var/log/httpd/access_log
sudo journalctl -u httpd -f
```

---

## 📚 Información de Referencia

### 🌐 URLs de Documentación
- **OCI WAF**: [docs.oracle.com/iaas/waas](https://docs.oracle.com/en-us/iaas/Content/WAF/home.htm)
- **OWASP Top 10**: [owasp.org/www-project-top-ten](https://owasp.org/www-project-top-ten/)
- **Terraform OCI**: [registry.terraform.io/providers/oracle/oci](https://registry.terraform.io/providers/oracle/oci/latest/docs)

### 💰 Métricas de Impacto
- **Costo promedio de violación**: $4.45M USD
- **Tiempo promedio de detección**: 287 días
- **Pérdida de confianza del cliente**: 65%
- **WAF bloquea**: 85% de ataques web
- **Tiempo de detección con WAF**: 3.2 segundos
- **Disponibilidad con WAF**: 99.9%

### 🎯 Mensajes Clave por Audiencia

#### C-Level / Ejecutivos
```
"¿Están dispuestos a asumir un riesgo de $4.45M o invertir en protección proactiva?"
"El WAF paga su inversión al prevenir una sola violación de datos."
```

#### Equipos Técnicos
```
"85% de ataques web bloqueados automáticamente con reglas OWASP Top 10."
"Detección en 3.2 segundos vs 287 días sin protección."
```

#### Equipos Comerciales
```
"ROI positivo en 3-6 meses al prevenir violaciones y multas regulatorias."
"99.9% disponibilidad garantizada con protección WAF."
```

---

**🎯 Comandos listos para copy-paste en cualquier demo** 🚀