#!/bin/bash

# ========================================
# SCRIPT DE AUTOMATIZACIÓN PARA DEMO WAF
# ========================================
# Este script automatiza el despliegue de la demo WAF vs Sin WAF

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para mostrar ayuda
show_help() {
    echo "========================================="
    echo "   DEMO WAF vs SIN WAF - Automatización"
    echo "========================================="
    echo ""
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponibles:"
    echo "  init              - Inicializar Terraform"
    echo "  deploy-sin-waf    - Desplegar ambiente SIN WAF"
    echo "  deploy-con-waf    - Desplegar ambiente CON WAF"
    echo "  destroy-sin-waf   - Destruir ambiente SIN WAF"
    echo "  destroy-con-waf   - Destruir ambiente CON WAF"
    echo "  status            - Mostrar estado actual"
    echo "  test-urls         - Generar URLs de prueba"
    echo "  cleanup           - Limpiar todos los recursos"
    echo "  help              - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 init"
    echo "  $0 deploy-sin-waf"
    echo "  $0 test-urls"
    echo "  $0 cleanup"
    echo ""
}

# Función para verificar prerequisitos
check_prerequisites() {
    print_status "Verificando prerequisitos..."
    
    # Verificar Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform no está instalado"
        exit 1
    fi
    
    # Verificar OCI CLI
    if ! command -v oci &> /dev/null; then
        print_error "OCI CLI no está instalado"
        exit 1
    fi
    
    # Verificar archivo de variables
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "No se encontró terraform.tfvars"
        print_status "Copiando template..."
        cp terraform.tfvars.example terraform.tfvars
        print_warning "¡Debe editar terraform.tfvars con sus credenciales OCI!"
        exit 1
    fi
    
    print_success "Todos los prerequisitos están disponibles"
}

# Función para inicializar Terraform
init_terraform() {
    print_status "Inicializando Terraform..."
    terraform init
    print_success "Terraform inicializado correctamente"
}

# Función para desplegar ambiente SIN WAF
deploy_sin_waf() {
    print_status "Desplegando ambiente SIN WAF..."
    print_warning "Este proceso puede tomar 45-60 minutos debido a la base de datos"
    
    terraform plan -var-file="terraform-SIN-WAF.tfvars"
    
    read -p "¿Desea continuar con el despliegue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply -var-file="terraform-SIN-WAF.tfvars" -auto-approve
        print_success "Ambiente SIN WAF desplegado correctamente"
        show_urls "SIN-WAF"
    else
        print_warning "Despliegue cancelado por el usuario"
    fi
}

# Función para desplegar ambiente CON WAF
deploy_con_waf() {
    print_status "Desplegando ambiente CON WAF..."
    print_warning "Este proceso puede tomar 45-60 minutos debido a la base de datos"
    
    terraform plan -var-file="terraform-CON-WAF.tfvars"
    
    read -p "¿Desea continuar con el despliegue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply -var-file="terraform-CON-WAF.tfvars" -auto-approve
        print_success "Ambiente CON WAF desplegado correctamente"
        show_urls "CON-WAF"
    else
        print_warning "Despliegue cancelado por el usuario"
    fi
}

# Función para destruir ambiente SIN WAF
destroy_sin_waf() {
    print_warning "Destruyendo ambiente SIN WAF..."
    
    read -p "¿Está seguro de que desea destruir el ambiente SIN WAF? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform destroy -var-file="terraform-SIN-WAF.tfvars" -auto-approve
        print_success "Ambiente SIN WAF destruido correctamente"
    else
        print_warning "Destrucción cancelada por el usuario"
    fi
}

# Función para destruir ambiente CON WAF  
destroy_con_waf() {
    print_warning "Destruyendo ambiente CON WAF..."
    
    read -p "¿Está seguro de que desea destruir el ambiente CON WAF? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform destroy -var-file="terraform-CON-WAF.tfvars" -auto-approve
        print_success "Ambiente CON WAF destruido correctamente"
    else
        print_warning "Destrucción cancelada por el usuario"
    fi
}

# Función para mostrar estado
show_status() {
    print_status "Estado actual de la infraestructura:"
    echo ""
    
    if terraform state list &> /dev/null; then
        echo "Recursos desplegados:"
        terraform state list | head -10
        echo ""
        
        if terraform output &> /dev/null; then
            echo "Información de arquitectura:"
            terraform output architecture_summary
        fi
    else
        print_warning "No hay recursos desplegados actualmente"
    fi
}

# Función para mostrar URLs de prueba
show_urls() {
    local tipo=$1
    echo ""
    print_success "=== URLs para Demo $tipo ==="
    
    if [ "$tipo" = "SIN-WAF" ]; then
        LB_IP=$(terraform output -raw load_balancer_fqdn 2>/dev/null || echo "IP_NO_DISPONIBLE")
        echo ""
        echo "🔴 AMBIENTE SIN WAF - VULNERABLE"
        echo "Base URL: http://$LB_IP/"
        echo ""
        echo "Casos de prueba:"
        echo "1. SQL Injection:"
        echo "   http://$LB_IP/?demo=sql&user_id=1' OR '1'='1"
        echo ""
        echo "2. XSS Attack:"
        echo "   http://$LB_IP/?demo=xss&comment=<script>alert('XSS')</script>"
        echo ""
        echo "3. Directory Traversal:"
        echo "   http://$LB_IP/?demo=path&file=../../etc/passwd"
    elif [ "$tipo" = "CON-WAF" ]; then
        WAF_DOMAIN=$(terraform output -raw waf_domain 2>/dev/null || echo "DOMINIO_NO_DISPONIBLE")
        echo ""
        echo "🟢 AMBIENTE CON WAF - PROTEGIDO"
        echo "Base URL: http://$WAF_DOMAIN/"
        echo ""
        echo "Casos de prueba (serán bloqueados):"
        echo "1. SQL Injection:"
        echo "   http://$WAF_DOMAIN/?demo=sql&user_id=1' OR '1'='1"
        echo ""
        echo "2. XSS Attack:"
        echo "   http://$WAF_DOMAIN/?demo=xss&comment=<script>alert('XSS')</script>"
        echo ""
        echo "3. Directory Traversal:"
        echo "   http://$WAF_DOMAIN/?demo=path&file=../../etc/passwd"
    fi
    
    echo ""
    print_warning "Guarde estas URLs para su presentación!"
}

# Función para generar URLs de prueba
test_urls() {
    print_status "Generando URLs de prueba basadas en el estado actual..."
    
    # Intentar detectar qué ambiente está desplegado
    if terraform output waf_domain &> /dev/null; then
        WAF_STATUS=$(terraform output -raw waf_domain 2>/dev/null)
        if [ "$WAF_STATUS" != "WAF deshabilitado" ]; then
            show_urls "CON-WAF"
        else
            show_urls "SIN-WAF"
        fi
    else
        print_warning "No se detectó ningún ambiente desplegado"
        print_status "Use 'deploy-sin-waf' o 'deploy-con-waf' primero"
    fi
}

# Función para limpieza completa
cleanup_all() {
    print_warning "Realizando limpieza completa de todos los recursos..."
    
    read -p "¿Está seguro de que desea destruir TODOS los recursos? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Destruyendo cualquier ambiente existente..."
        
        # Intentar destruir ambos ambientes
        terraform destroy -var-file="terraform-SIN-WAF.tfvars" -auto-approve 2>/dev/null || true
        terraform destroy -var-file="terraform-CON-WAF.tfvars" -auto-approve 2>/dev/null || true
        
        print_success "Limpieza completada"
        
        # Verificar que no queden recursos
        if [ -f "terraform.tfstate" ]; then
            REMAINING=$(terraform state list 2>/dev/null | wc -l)
            if [ "$REMAINING" -gt 0 ]; then
                print_warning "Quedan $REMAINING recursos en el estado"
                print_status "Ejecute: terraform state list"
            else
                print_success "No quedan recursos desplegados"
            fi
        fi
    else
        print_warning "Limpieza cancelada por el usuario"
    fi
}

# Script principal
main() {
    echo ""
    echo "========================================="
    echo "   🛡️  DEMO WAF vs SIN WAF"
    echo "   Oracle Cloud Infrastructure"
    echo "========================================="
    echo ""
    
    # Verificar que estamos en el directorio correcto
    if [ ! -f "loadbalancer.tf" ]; then
        print_error "Debe ejecutar este script desde el directorio 11_WAF_Security_Demo"
        exit 1
    fi
    
    case "${1:-help}" in
        "init")
            check_prerequisites
            init_terraform
            ;;
        "deploy-sin-waf")
            check_prerequisites
            deploy_sin_waf
            ;;
        "deploy-con-waf")
            check_prerequisites
            deploy_con_waf
            ;;
        "destroy-sin-waf")
            destroy_sin_waf
            ;;
        "destroy-con-waf")
            destroy_con_waf
            ;;
        "status")
            show_status
            ;;
        "test-urls")
            test_urls
            ;;
        "cleanup")
            cleanup_all
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Ejecutar script principal
main "$@"