# ========================================
# MÓDULO APLICACIÓN VULNERABLE - OWASP Top 10
# Aplicación web con vulnerabilidades intencionadas
# ========================================

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.21.0"
    }
  }
}

# ========================================
# CONFIGURACIÓN DE APLICACIÓN VULNERABLE
# ========================================

# Crear script de configuración de aplicación vulnerable
resource "oci_core_instance_configuration" "vulnerable_app_config" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.environment}-vulnerable-app-config"
  
  instance_details {
    instance_type = "compute"
    
    launch_details {
      compartment_id = var.compartment_ocid
      shape         = "VM.Standard.E4.Flex"
      
      shape_config {
        ocpus         = 1
        memory_in_gbs = 8
      }
      
      metadata = {
        user_data = base64encode(templatefile("${path.module}/app-vulnerable-setup.sh", {
          database_connection = var.database_connection
          enable_sql_injection = var.enable_sql_injection
          enable_xss_vulnerabilities = var.enable_xss_vulnerabilities
          enable_path_traversal = var.enable_path_traversal
          hardcode_secrets = var.hardcode_secrets
          disable_input_validation = var.disable_input_validation
          enable_verbose_errors = var.enable_verbose_errors
          disable_https_enforcement = var.disable_https_enforcement
        }))
      }
    }
  }
  
  freeform_tags = merge(var.common_tags, {
    Name = "${var.environment}-vulnerable-app-config"
    Type = "vulnerable-application"
    Security = "OWASP_TOP_10_VULNERABLE"
  })
}

# ========================================
# APLICACIÓN WEB VULNERABLE - ARCHIVOS
# ========================================

# Script principal de la aplicación vulnerable
resource "local_file" "vulnerable_web_app" {
  filename = "${path.module}/vulnerable-web-app.php"
  content  = templatefile("${path.module}/templates/vulnerable-app.php.tpl", {
    database_connection = var.database_connection
    enable_sql_injection = var.enable_sql_injection
    enable_xss = var.enable_xss_vulnerabilities
    enable_path_traversal = var.enable_path_traversal
    hardcode_secrets = var.hardcode_secrets
    show_verbose_errors = var.enable_verbose_errors
  })
  
  file_permission = "0644"
}

# Configuración de Apache vulnerable
resource "local_file" "vulnerable_apache_config" {
  filename = "${path.module}/vulnerable-apache.conf"
  content = templatefile("${path.module}/templates/apache-vulnerable.conf.tpl", {
    disable_https_enforcement = var.disable_https_enforcement
    enable_server_info = true
    disable_security_headers = true
  })
  
  file_permission = "0644"
}

# Script de configuración de base de datos vulnerable
resource "local_file" "vulnerable_db_setup" {
  filename = "${path.module}/vulnerable-db-setup.sql"
  content = templatefile("${path.module}/templates/vulnerable-db.sql.tpl", {
    create_vulnerable_tables = true
    insert_sample_data = true
    create_admin_users = true
  })
  
  file_permission = "0644"
}

# ========================================
# REMOTE EXECUTION - DESPLEGAR APLICACIÓN
# ========================================

# Null resource para desplegar aplicación vulnerable en instancias
resource "null_resource" "deploy_vulnerable_app" {
  count = length(var.compute_instance_ids)
  
  # Triggers para re-deployment cuando cambien los archivos
  triggers = {
    app_content = local_file.vulnerable_web_app.content
    apache_config = local_file.vulnerable_apache_config.content
    db_setup = local_file.vulnerable_db_setup.content
    instance_id = var.compute_instance_ids[count.index]
  }
  
  # Provisioner para copiar archivos a la instancia
  provisioner "file" {
    source      = local_file.vulnerable_web_app.filename
    destination = "/tmp/vulnerable-app.php"
    
    connection {
      type        = "ssh"
      user        = "opc"
      private_key = file("${path.module}/../unprotected-compute/vulnerable_private_key.pem")
      host        = var.instance_public_ips[count.index]
      timeout     = "5m"
    }
  }
  
  provisioner "file" {
    source      = local_file.vulnerable_apache_config.filename
    destination = "/tmp/vulnerable-apache.conf"
    
    connection {
      type        = "ssh"
      user        = "opc"
      private_key = file("${path.module}/../unprotected-compute/vulnerable_private_key.pem")
      host        = var.instance_public_ips[count.index]
      timeout     = "5m"
    }
  }
  
  # Provisioner para configurar la aplicación vulnerable
  provisioner "remote-exec" {
    inline = [
      # Instalar aplicación vulnerable
      "sudo cp /tmp/vulnerable-app.php /var/www/html/index.php",
      "sudo cp /tmp/vulnerable-apache.conf /etc/httpd/conf.d/vulnerable.conf",
      
      # INSEGURO: Configurar permisos permisivos
      "sudo chmod 755 /var/www/html/index.php",
      "sudo chown apache:apache /var/www/html/index.php",
      
      # INSEGURO: Crear archivos con secretos expuestos
      "sudo echo '<?php \\$db_password=\"Welcome123!\"; \\$api_key=\"demo-key-123\"; ?>' > /var/www/html/config.php",
      "sudo chmod 644 /var/www/html/config.php",
      
      # INSEGURO: Crear directorio uploads sin restricciones
      "sudo mkdir -p /var/www/html/uploads",
      "sudo chmod 777 /var/www/html/uploads",
      
      # INSEGURO: Habilitar mod_info (información del servidor)
      "sudo echo 'LoadModule info_module modules/mod_info.so' >> /etc/httpd/conf/httpd.conf",
      "sudo echo '<Location \"/server-info\"><SetHandler server-info></SetHandler></Location>' >> /etc/httpd/conf/httpd.conf",
      
      # INSEGURO: Configurar headers inseguros
      "sudo echo 'Header always set Server \"Apache/2.4.6 (CentOS) - Vulnerable Demo\"' >> /etc/httpd/conf/httpd.conf",
      "sudo echo 'Header unset X-Frame-Options' >> /etc/httpd/conf/httpd.conf",
      "sudo echo 'Header unset X-Content-Type-Options' >> /etc/httpd/conf/httpd.conf",
      
      # Reiniciar Apache con configuración vulnerable
      "sudo systemctl restart httpd",
      
      # INSEGURO: Crear logs con información sensible
      "sudo echo \"[$(date)] Vulnerable application deployed with hardcoded secrets\" >> /var/log/vulnerable-app.log",
      "sudo echo \"[$(date)] Database connection: ${var.database_connection}\" >> /var/log/vulnerable-app.log",
      "sudo chmod 644 /var/log/vulnerable-app.log",
      
      # INSEGURO: Crear backup file con credenciales
      "sudo echo 'DB_USER=admin' > /var/www/html/.env.backup",
      "sudo echo 'DB_PASS=Welcome123!' >> /var/www/html/.env.backup",
      "sudo echo 'API_SECRET=demo-secret-key' >> /var/www/html/.env.backup",
      "sudo chmod 644 /var/www/html/.env.backup"
    ]
    
    connection {
      type        = "ssh"
      user        = "opc"
      private_key = file("${path.module}/../unprotected-compute/vulnerable_private_key.pem")
      host        = var.instance_public_ips[count.index]
      timeout     = "10m"
    }
  }
  
  depends_on = [
    local_file.vulnerable_web_app,
    local_file.vulnerable_apache_config
  ]
}

# ========================================
# HEALTH CHECK VULNERABLE
# ========================================

# Health check que expone información del sistema
resource "null_resource" "setup_vulnerable_health_check" {
  count = length(var.compute_instance_ids)
  
  provisioner "remote-exec" {
    inline = [
      # INSEGURO: Health check que expone información del sistema
      "sudo cat > /var/www/html/health.php << 'EOF'",
      "<?php",
      "// VULNERABLE HEALTH CHECK - EXPOSES SYSTEM INFORMATION",
      "header('Content-Type: application/json');",
      "echo json_encode([",
      "    'status' => 'vulnerable',",
      "    'timestamp' => date('Y-m-d H:i:s'),",
      "    'server_info' => \\$_SERVER,",
      "    'php_version' => phpversion(),",
      "    'database_connection' => '${var.database_connection}',",
      "    'environment_variables' => \\$_ENV,",
      "    'system_info' => [",
      "        'os' => php_uname(),",
      "        'load_average' => sys_getloadavg(),",
      "        'memory_usage' => memory_get_usage(true)",
      "    ],",
      "    'security_status' => 'DISABLED',",
      "    'vulnerabilities' => [",
      "        'sql_injection' => 'ENABLED',",
      "        'xss' => 'ENABLED',",
      "        'path_traversal' => 'ENABLED',",
      "        'information_disclosure' => 'ENABLED'",
      "    ]",
      "], JSON_PRETTY_PRINT);",
      "?>",
      "EOF",
      
      "sudo chmod 644 /var/www/html/health.php"
    ]
    
    connection {
      type        = "ssh"
      user        = "opc"
      private_key = file("${path.module}/../unprotected-compute/vulnerable_private_key.pem")
      host        = var.instance_public_ips[count.index]
      timeout     = "5m"
    }
  }
  
  depends_on = [null_resource.deploy_vulnerable_app]
}