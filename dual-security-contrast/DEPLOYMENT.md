# 🚀 Guía de Despliegue - Arquitectura de Contraste de Seguridad

## 📋 Prerrequisitos

### 1. Herramientas Requeridas
```bash
# Terraform (versión >= 1.0)
terraform --version

# Oracle CLI (opcional pero recomendado)
oci --version

# Git (para clonar repositorio)
git --version
```

### 2. Configuración OCI
- Cuenta Oracle Cloud Infrastructure activa
- Usuario con permisos administrativos
- Tenancy OCID, User OCID, Fingerprint y Private Key
- Región principal seleccionada

### 3. Límites de Servicio
Verificar límites disponibles en OCI Console:
- Compute instances: mínimo 10
- VCN: mínimo 2
- Load Balancer: mínimo 2
- Database: mínimo 2

## 🔧 Configuración Inicial

### Paso 1: Clonar y Posicionarse en el Directorio
```bash
cd /home/jesmonsa/proyectos/01-oci-terraform-foundations/11_Security_Showcase_Enterprise/
cd dual-security-contrast
```

### Paso 2: Configurar Credenciales OCI

#### Opción A: Variables de Entorno (Recomendado)
```bash
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export TF_VAR_user_ocid="ocid1.user.oc1..aaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export TF_VAR_fingerprint="xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
export TF_VAR_private_key_path="/path/to/your/oci_api_key.pem"
export TF_VAR_region="us-ashburn-1"
export TF_VAR_home_region="us-ashburn-1"
```

#### Opción B: Archivo terraform.tfvars
```bash
# Copiar el template
cp terraform.tfvars.example terraform.tfvars

# Editar con sus credenciales
nano terraform.tfvars
```

### Paso 3: Configurar Variables Específicas

#### Variables Obligatorias Mínimas
```bash
# Configuración básica
export TF_VAR_notification_email="admin@company.com"
export TF_VAR_db_admin_password="SecurePassword123!"

# Configuración de red
export TF_VAR_vcn_cidr_block="10.0.0.0/16"
```

#### Variables de Seguridad (Opcionales pero Recomendadas)
```bash
# Habilitar todas las características de seguridad
export TF_VAR_enable_database_firewall=true
export TF_VAR_enable_data_safe=true
export TF_VAR_enable_cloud_guard=true
export TF_VAR_enable_vulnerability_scanning=true
export TF_VAR_enable_waf=true
export TF_VAR_enable_ddos_protection=true
```

## 🏗️ Despliegue de Ambientes

### Ambiente Seguro (Oracle 23ai + Database Firewall)

#### Paso 1: Inicializar Terraform
```bash
cd secure-environment
terraform init
```

#### Paso 2: Planificar Despliegue
```bash
terraform plan -out=secure.tfplan
```

#### Paso 3: Aplicar Configuración
```bash
# Despliegue completo (30-45 minutos)
terraform apply secure.tfplan

# O aplicar directamente con confirmación
terraform apply -auto-approve
```

#### Paso 4: Verificar Despliegue
```bash
# Ver outputs principales
terraform output

# Ver estado específico de seguridad
terraform output security_architecture_summary

# Ver información de conexión
terraform output secure_connection_information
```

### Ambiente Vulnerable (Para Contraste)

#### Paso 1: Posicionarse en Ambiente Vulnerable
```bash
cd ../vulnerable-environment
terraform init
```

#### Paso 2: Desplegar Ambiente Vulnerable
```bash
terraform plan -out=vulnerable.tfplan
terraform apply vulnerable.tfplan
```

## 📊 Verificación del Despliegue

### 1. Verificación Automática
```bash
# Desde ambiente seguro
cd secure-environment
terraform output deployment_information

# Verificar Cloud Guard
terraform output monitoring_security_configuration
```

### 2. Verificación Manual en OCI Console

#### Cloud Guard
1. Navegar a: Security → Cloud Guard
2. Verificar estado: **ENABLED**
3. Revisar targets configurados

#### Database Firewall
1. Ir a: Oracle Database → Data Safe
2. Verificar: Database Firewall **ENABLED**
3. Revisar reglas configuradas

#### Network Security
1. Navegar a: Networking → Virtual Cloud Networks
2. Verificar VCN segura creada
3. Revisar NSGs y Security Lists

### 3. Pruebas de Conectividad

#### SSH a Bastion (Ambiente Seguro)
```bash
# Obtener IP del Bastion
terraform output bastion_public_ip

# Conectar usando clave privada generada
ssh -i ~/.ssh/terraform_rsa opc@<BASTION_IP>
```

#### Acceso a Base de Datos
```bash
# Desde instancia de aplicación
sqlplus admin/<PASSWORD>@<DB_CONNECTION_STRING>
```

## 🔐 Configuración de Seguridad Post-Despliegue

### 1. Configurar Alertas de Email
```bash
# Verificar suscripción de email
oci ons subscription list --compartment-id <COMPARTMENT_OCID>

# Confirmar suscripción en email recibido
```

### 2. Configurar Database Firewall Rules
```sql
-- Conectar a base de datos Oracle 23ai
-- Configurar reglas de firewall personalizadas
EXEC DBMS_SQL_FIREWALL.ENABLE_SQL_FIREWALL;
```

### 3. Revisar Cloud Guard Policies
1. OCI Console → Security → Cloud Guard
2. Revisar "Problems" detectados
3. Configurar auto-remediation si es necesario

## 📈 Monitoreo y Dashboards

### 1. Dashboards Principales
- **Cloud Guard**: Security → Cloud Guard → Dashboard
- **Log Analytics**: Observability → Log Analytics
- **Monitoring**: Observability → Monitoring
- **Data Safe**: Oracle Database → Data Safe

### 2. Métricas Clave a Monitorear
- Cloud Guard problems por severidad
- Database Firewall blocked attempts
- Failed authentication attempts
- Network anomalies
- Vulnerability scan results

## 🧪 Pruebas de Demostración

### 1. Prueba de SQL Injection (Ambiente Seguro)
```bash
# Esta prueba debería FALLAR (bloqueada por Database Firewall)
curl -X POST https://<SECURE_LB_IP>/api/login \
  -d "username=admin' OR '1'='1&password=any"
```

### 2. Prueba de SQL Injection (Ambiente Vulnerable)
```bash
# Esta prueba debería PASAR (vulnerabilidad crítica)
curl -X POST https://<VULNERABLE_LB_IP>/api/login \
  -d "username=admin' OR '1'='1&password=any"
```

### 3. Verificar Detección de Amenazas
```bash
# Generar eventos de seguridad para testing
# Cloud Guard detectará automáticamente configuraciones inseguras
```

## 🗑️ Limpieza de Recursos

### Destruir Ambiente Vulnerable
```bash
cd vulnerable-environment
terraform destroy -auto-approve
```

### Destruir Ambiente Seguro
```bash
cd secure-environment
terraform destroy -auto-approve
```

### Verificar Limpieza Completa
```bash
# Verificar que no quedan recursos
oci iam compartment list --compartment-id <TENANCY_OCID> | grep -i secure
oci iam compartment list --compartment-id <TENANCY_OCID> | grep -i vulnerable
```

## 🚨 Solución de Problemas

### Errores Comunes

#### 1. "Out of host capacity"
```bash
# Cambiar shape o región
export TF_VAR_instance_shape="VM.Standard.E4.Flex"
export TF_VAR_region="us-phoenix-1"
```

#### 2. "Service limit exceeded"
```bash
# Verificar límites
oci limits quota list --compartment-id <TENANCY_OCID>

# Solicitar incremento si es necesario
```

#### 3. "Database creation failed"
```bash
# Verificar password complexity
export TF_VAR_db_admin_password="ComplexPassword123!"

# Verificar disponibilidad de DBSystem en AD
```

#### 4. "Cloud Guard not enabled"
```bash
# Habilitar Cloud Guard manualmente primero
oci cloud-guard configuration update --status ENABLED --reporting-region <REGION>
```

### Logs de Diagnóstico
```bash
# Ver logs detallados de Terraform
export TF_LOG=DEBUG
terraform apply

# Ver logs de recursos específicos
terraform show
```

## 📞 Soporte

### Información de Contacto
- **Issues del Repositorio**: Crear issue en GitHub
- **Documentación OCI**: https://docs.oracle.com/en-us/iaas/
- **Terraform OCI Provider**: https://registry.terraform.io/providers/oracle/oci/

### Recursos Adicionales
- [OCI Cloud Guard Documentation](https://docs.oracle.com/en-us/iaas/cloud-guard/)
- [Oracle Database Firewall Guide](https://docs.oracle.com/en/database/oracle/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

---

**⚡ Tiempo estimado de despliegue completo: 45-60 minutos (ambiente seguro) + 30-45 minutos (ambiente vulnerable)**