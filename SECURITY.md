# 🔒 Seguridad - Arquitectura FSC

## 🛡️ Características de Seguridad Implementadas

### Network Security Groups (NSGs)
- **nsg-apache**: HTTP/HTTPS (80/443) desde Internet, SSH (22) desde Internet  
- **nsg-tomcat**: Puerto 8080 solo desde NSG Apache, SSH solo desde NSG Bastion
- **nsg-database**: Puerto 1521 solo desde NSG Tomcat, SSH solo desde NSG Bastion
- **nsg-bastion**: SSH (22) desde Internet para acceso administrativo

### Microsegmentación
✅ **Zero-trust networking**: Cada servicio tiene su propio NSG con reglas específicas  
✅ **Principio de menor privilegio**: Solo puertos necesarios abiertos  
✅ **Aislamiento de capas**: Base de datos solo accesible desde capa de aplicación  
✅ **Bastion host**: Acceso SSH seguro a recursos privados  

### Cifrado
✅ **Volúmenes**: Encriptación en tránsito habilitada (`is_pv_encryption_in_transit_enabled = true`)  
✅ **SSH**: Claves RSA 4096 bits generadas automáticamente  
✅ **HTTPS**: Soporte para certificados SSL/TLS configurables  
✅ **WAF**: Protección adicional con SSL/TLS v1.2 y v1.3  

### Web Application Firewall (WAF)
✅ **Modo DETECT**: Filtrado avanzado de amenazas web  
✅ **Protección DDoS**: Mitigación automática de ataques  
✅ **Reglas personalizables**: Filtros por geografía, IPs, patrones  
✅ **Logging**: Monitoreo completo de tráfico y amenazas  

## 🚨 Consideraciones de Seguridad

### ⚠️ Configuración Inicial
- **Contraseña DB**: Debe cumplir política estricta de Oracle (ver variables.tf)
- **SSH Keys**: Se generan automáticamente o usar claves existentes
- **Certificados HTTPS**: Configurar para producción
- **NSG Rules**: Revisar y ajustar según requirements específicos

### 🔍 Auditoría y Monitoreo
- Todos los recursos incluyen tags para trazabilidad
- Logs de OCI disponibles para análisis forense
- WAF proporciona métricas de seguridad
- NSGs permiten monitoreo granular de tráfico

### 📋 Mejores Prácticas Aplicadas
✅ **Subredes privadas**: Database y Tomcat sin IPs públicas  
✅ **Route tables**: Tráfico privado via NAT Gateway  
✅ **Service Gateway**: Acceso seguro a servicios OCI  
✅ **DRG**: Conectividad híbrida preparada  
✅ **Naming convention**: Recursos identificables y organizados  

## 🔧 Hardening Adicional Recomendado

### Para Producción:
1. **OCI Vault**: Gestión centralizada de secretos y claves
2. **OCI Security Zones**: Políticas de seguridad automatizadas
3. **Cloud Guard**: Detección de amenazas y respuesta automática  
4. **Security Advisor**: Recomendaciones continuas de seguridad
5. **Bastón Service**: Servicio nativo de bastion gestionado
6. **Certificate Service**: Gestión automática de certificados SSL

### Configuración Post-Despliegue:
- Rotar contraseñas por defecto
- Configurar backups automáticos
- Implementar monitoring activo
- Configurar alertas de seguridad
- Revisar logs regularmente

## 📞 Reporte de Vulnerabilidades

Para reportar vulnerabilidades de seguridad:
1. **No crear issues públicos** con detalles de seguridad
2. Contactar directamente al mantenedor
3. Incluir descripción detallada y pasos para reproducir
4. Permitir tiempo razonable para corrección antes de divulgación pública

---
**Nota**: Esta arquitectura está diseñada para entornos de desarrollo y pruebas. Para producción, implementar las medidas de hardening adicionales recomendadas.