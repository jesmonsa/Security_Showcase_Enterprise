# 🚀 Quick Start - Demo de Vulnerabilidades

## ⚡ Inicio Rápido (5 minutos)

### 1️⃣ Verificar que Todo Funciona
```bash
./scripts/quick-check.sh http://193.122.191.160
```
**Resultado esperado:** ✅ Todo listo para demo

### 2️⃣ Ejecutar Demo Completa
```bash
./scripts/vulnerability-test.sh http://193.122.191.160 demo
```
**Duración:** 5-8 minutos con pausas interactivas

### 3️⃣ Generar Reporte Profesional
```bash
./scripts/generate-report.sh http://193.122.191.160 "Nombre Cliente"
```
**Resultado:** Archivo MD con reporte completo

---

## 🎯 URLs de Tu Demo

- **🌐 Aplicación Vulnerable:** http://193.122.191.160
- **🔍 SSH Bastion:** 129.213.152.237
- **📊 Estado:** SIN PROTECCIONES (perfecto para demo)

---

## 🎭 Comandos Clave para Demo Manual

### Reconocimiento
```bash
curl -I http://193.122.191.160
```

### SQL Injection
```bash
curl "http://193.122.191.160/?id=1'"
curl "http://193.122.191.160/?id=1' OR '1'='1"
```

### XSS
```bash
curl "http://193.122.191.160/?search=<script>alert('XSS')</script>"
```

---

## 📋 Archivos de Documentación

- **📖 [README.md](./README.md)** - Documentación completa
- **📋 [INSTRUCTIONS.md](./INSTRUCTIONS.md)** - Pasos detallados
- **🎭 [DEMO-GUIDE.md](./DEMO-GUIDE.md)** - Guía de presentación
- **🛡️ [WAF-SETUP-GUIDE.md](./WAF-SETUP-GUIDE.md)** - **NUEVO**: Configuración WAF corregida
- **🛠️ [scripts/README.md](./scripts/README.md)** - Documentación de scripts

---

## ✅ Tu Setup Está Listo

🎯 **URL funcionando:** http://193.122.191.160  
🛠️ **Scripts funcionando:** ✅ Verificado  
📚 **Documentación completa:** ✅ Creada  
🎭 **Demo lista:** ✅ Para ejecutar  

**¡Ahora tienes todo lo necesario para una demo impactante!** 🚀