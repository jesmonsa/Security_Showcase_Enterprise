# 🔒 Guía de Limpieza de Historial Git — BFG Repo Cleaner

> **Objetivo:** Eliminar del historial completo de commits los archivos
> `terraform-CON-WAF.tfvars` y `terraform-SIN-WAF.tfvars` que contenían
> credenciales reales de OCI.

---

## ⚠️ Contexto

Eliminar un archivo con `git rm` o desde la UI de GitHub solo lo borra del
último commit. El archivo sigue accesible en el historial por su SHA.
BFG Repo Cleaner reescribe todo el historial para eliminarlo completamente.

---

## Prerrequisitos

- Java 8+ instalado (`java -version`)
- Git instalado
- Descargar BFG: https://rtyley.github.io/bfg-repo-cleaner/
  - Archivo: `bfg-1.14.0.jar` (o la última versión)

---

## Paso a Paso

### 1. Revocar la API Key comprometida (HACER PRIMERO)

Antes de limpiar el historial, rota la credencial expuesta:

```
OCI Console → Identity & Security → Users
→ Tu usuario → API Keys
→ Eliminar la key con fingerprint: a6:a4:22:4d:c8:84:d7:3d:81:da:eb:d6:49:85:aa:f3
→ Agregar una nueva API Key y actualizar tu ~/.oci/config
```

### 2. Clonar el repositorio en modo bare (mirror)

```bash
# Crea un directorio de trabajo temporal
mkdir ~/git-cleanup && cd ~/git-cleanup

# Clona en modo mirror (incluye TODO el historial)
git clone --mirror https://github.com/jesmonsa/Security_Showcase_Enterprise.git

cd Security_Showcase_Enterprise.git
```

### 3. Ejecutar BFG para borrar los archivos del historial

```bash
# Desde el directorio ~/git-cleanup (donde está el .jar)
java -jar bfg-1.14.0.jar \
  --delete-files terraform-CON-WAF.tfvars \
  Security_Showcase_Enterprise.git

java -jar bfg-1.14.0.jar \
  --delete-files terraform-SIN-WAF.tfvars \
  Security_Showcase_Enterprise.git
```

> BFG mostrará un reporte de cuántos commits fueron modificados.

### 4. Limpiar referencias y comprimir el repositorio

```bash
cd Security_Showcase_Enterprise.git

git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### 5. Force push al repositorio remoto

```bash
git push --force
```

> **⚠️ Nota:** El force push reescribe el historial público. Si otras
> personas tienen el repo clonado, necesitarán hacer `git fetch --all`
> y `git reset --hard origin/main`.

### 6. Verificar que los archivos ya no existen en el historial

```bash
# Este comando NO debe devolver resultados
git log --all --full-history -- "**/terraform-CON-WAF.tfvars"
git log --all --full-history -- "**/terraform-SIN-WAF.tfvars"
```

---

## Verificación final desde GitHub

Despues del force push, verifica en GitHub:

1. Ve a: `https://github.com/jesmonsa/Security_Showcase_Enterprise/commits/main`
2. Revisa commits anteriores — los archivos `.tfvars` ya no deben aparecer
3. Intenta acceder al SHA antiguo directamente:
   `https://github.com/jesmonsa/Security_Showcase_Enterprise/commit/7193a197959b4d426bb43ba9786df52fefe2d0ec`
   — ya no debe mostrar el contenido de las credenciales

---

## Prevención futura

El `.gitignore` ya fue actualizado para bloquear `*.tfvars`.
Siempre usa el flujo:

```bash
# Correcto ✔️
cp terraform-CON-WAF.tfvars.example terraform-CON-WAF.tfvars
# Editar terraform-CON-WAF.tfvars con tus credenciales reales
# El archivo queda local, nunca va al repo

# Incorrecto ❌
git add terraform-CON-WAF.tfvars  # .gitignore lo bloqueara
```

---

## Recursos

- BFG Repo Cleaner: https://rtyley.github.io/bfg-repo-cleaner/
- GitHub — Remover datos sensibles: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
- OCI — Gestionar API Keys: https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcredentials.htm
