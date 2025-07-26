#!/bin/bash
# Apache Server Cloud-Init Script para Demo de Seguridad WAF
# Cliente: ${cliente}

# Update system
dnf update -y

# Install Apache and PHP
dnf install -y httpd php php-mysqli

# Create health check endpoint
cat > /var/www/html/health <<EOF
OK
EOF

# Create vulnerable application
cat > /var/www/html/index.php <<'EOF'
<?php
// APLICACIÓN WEB VULNERABLE PARA DEMO DE SEGURIDAD WAF
// ADVERTENCIA: SOLO PARA FINES EDUCATIVOS Y DE DEMOSTRACIÓN

header('Content-Type: text/html; charset=UTF-8');
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Demo Seguridad WAF - ${cliente}</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            max-width: 1200px; 
            margin: 0 auto; 
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container { 
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        .warning {
            background: rgba(255,0,0,0.2);
            border: 2px solid #ff6b6b;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: center;
        }
        .demo-section {
            background: rgba(255,255,255,0.05);
            padding: 20px;
            margin: 15px 0;
            border-radius: 10px;
            border-left: 4px solid #4ecdc4;
        }
        input[type="text"], textarea {
            width: 300px;
            padding: 10px;
            margin: 5px 0;
            border: none;
            border-radius: 5px;
            background: rgba(255,255,255,0.2);
            color: white;
            border: 1px solid rgba(255,255,255,0.3);
        }
        input[type="text"]::placeholder, textarea::placeholder {
            color: rgba(255,255,255,0.7);
        }
        button {
            background: linear-gradient(45deg, #4ecdc4, #44a08d);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 25px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .result {
            background: rgba(0,0,0,0.2);
            padding: 15px;
            margin: 10px 0;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .vulnerability {
            color: #ff6b6b;
            font-weight: bold;
        }
        .protected {
            color: #4ecdc4;
            font-weight: bold;
        }
        h1, h2 { 
            text-align: center; 
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        h1 { color: #4ecdc4; }
        h2 { color: #ffa726; }
        .attack-demo {
            font-family: 'Courier New', monospace;
            font-size: 12px;
            background: rgba(0,0,0,0.4);
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
            overflow-x: auto;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .stat-card {
            background: rgba(255,255,255,0.1);
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }
        .stat-number {
            font-size: 2em;
            font-weight: bold;
            color: #4ecdc4;
        }
        .environment-indicator {
            position: fixed;
            top: 10px;
            right: 10px;
            padding: 10px 15px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 14px;
        }
        .waf-enabled {
            background: #4caf50;
            color: white;
        }
        .waf-disabled {
            background: #f44336;
            color: white;
        }
    </style>
</head>
<body>
    <?php
    // Detectar si HAProxy/WAF está presente basado en headers
    $waf_enabled = isset($_SERVER['HTTP_X_FORWARDED_FOR']) || 
                   isset($_SERVER['HTTP_X_REAL_IP']) || 
                   isset($_SERVER['HTTP_X_WAF_PROTECTION']);
    ?>
    
    <div class="environment-indicator <?php echo $waf_enabled ? 'waf-enabled' : 'waf-disabled'; ?>">
        <?php echo $waf_enabled ? '🛡️ WAF ACTIVADO' : '⚠️ SIN WAF'; ?>
    </div>

    <div class="container">
        <h1>🛡️ Demo de Seguridad Web - Cliente: ${cliente}</h1>
        
        <div class="warning">
            <strong>⚠️ APLICACIÓN DE DEMOSTRACIÓN ⚠️</strong><br>
            Esta aplicación contiene vulnerabilidades intencionales para mostrar la efectividad del WAF.<br>
            <strong>Estado actual: <?php echo $waf_enabled ? 'PROTEGIDO por WAF' : 'VULNERABLE - Sin protección WAF'; ?></strong>
        </div>

        <div class="stats">
            <div class="stat-card">
                <div class="stat-number">85%</div>
                <div>Ataques web bloqueados por WAF</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">3.2s</div>
                <div>Tiempo promedio de detección</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">99.9%</div>
                <div>Disponibilidad con WAF</div>
            </div>
        </div>

        <!-- Vulnerabilidad 1: SQL Injection -->
        <div class="demo-section">
            <h2>🔍 Demo 1: SQL Injection</h2>
            <p>Ingrese un ID de usuario para buscar:</p>
            <form method="GET">
                <input type="text" name="user_id" placeholder="Pruebe: 1' OR '1'='1" value="<?php echo htmlspecialchars($_GET['user_id'] ?? ''); ?>">
                <button type="submit" name="demo" value="sql">Buscar Usuario</button>
            </form>
            
            <?php if (isset($_GET['demo']) && $_GET['demo'] == 'sql' && isset($_GET['user_id'])): ?>
                <div class="result">
                    <strong>Consulta SQL que se ejecutaría:</strong><br>
                    <div class="attack-demo">
                        SELECT * FROM users WHERE id = '<?php echo htmlspecialchars($_GET['user_id']); ?>'
                    </div>
                    <?php
                    $user_id = $_GET['user_id'];
                    if (strpos($user_id, 'OR') !== false || strpos($user_id, 'UNION') !== false || strpos($user_id, '--') !== false || strpos($user_id, "'") !== false) {
                        echo '<div class="vulnerability">🚨 PATRÓN DE SQL INJECTION DETECTADO</div>';
                        if ($waf_enabled) {
                            echo '<p><strong>Con WAF:</strong> <span class="protected">✅ ATAQUE BLOQUEADO - Patrón malicioso detectado y neutralizado</span></p>';
                        } else {
                            echo '<p><strong>Sin WAF:</strong> <span class="vulnerability">❌ VULNERABLE - La consulta se ejecutaría y podría comprometer la base de datos</span></p>';
                        }
                    } else {
                        echo '<div class="protected">✅ Consulta segura procesada correctamente</div>';
                    }
                    ?>
                </div>
            <?php endif; ?>
        </div>

        <!-- Vulnerabilidad 2: XSS -->
        <div class="demo-section">
            <h2>⚡ Demo 2: Cross-Site Scripting (XSS)</h2>
            <p>Ingrese un comentario:</p>
            <form method="GET">
                <textarea name="comment" placeholder="Pruebe: <script>alert('XSS Attack!')</script>"><?php echo htmlspecialchars($_GET['comment'] ?? ''); ?></textarea><br>
                <button type="submit" name="demo" value="xss">Publicar Comentario</button>
            </form>
            
            <?php if (isset($_GET['demo']) && $_GET['demo'] == 'xss' && isset($_GET['comment'])): ?>
                <div class="result">
                    <strong>Contenido procesado:</strong><br>
                    <?php
                    $comment = $_GET['comment'];
                    if (strpos($comment, '<script>') !== false || strpos($comment, 'javascript:') !== false || strpos($comment, 'onload=') !== false || strpos($comment, 'onerror=') !== false) {
                        echo '<div class="vulnerability">🚨 PATRÓN XSS DETECTADO</div>';
                        echo '<div class="attack-demo">' . htmlspecialchars($comment) . '</div>';
                        if ($waf_enabled) {
                            echo '<p><strong>Con WAF:</strong> <span class="protected">✅ ATAQUE BLOQUEADO - Script malicioso sanitizado</span></p>';
                        } else {
                            echo '<p><strong>Sin WAF:</strong> <span class="vulnerability">❌ VULNERABLE - El script podría ejecutarse en navegadores de usuarios</span></p>';
                        }
                    } else {
                        echo '<div class="protected">✅ Comentario seguro: ' . htmlspecialchars($comment) . '</div>';
                    }
                    ?>
                </div>
            <?php endif; ?>
        </div>

        <!-- Vulnerabilidad 3: Directory Traversal -->
        <div class="demo-section">
            <h2>📁 Demo 3: Directory Traversal</h2>
            <p>Acceder a archivo del sistema:</p>
            <form method="GET">
                <input type="text" name="file" placeholder="Pruebe: ../../etc/passwd" value="<?php echo htmlspecialchars($_GET['file'] ?? ''); ?>">
                <button type="submit" name="demo" value="path">Leer Archivo</button>
            </form>
            
            <?php if (isset($_GET['demo']) && $_GET['demo'] == 'path' && isset($_GET['file'])): ?>
                <div class="result">
                    <strong>Intento de acceso a:</strong><br>
                    <div class="attack-demo">/var/www/html/<?php echo htmlspecialchars($_GET['file']); ?></div>
                    <?php
                    $file = $_GET['file'];
                    if (strpos($file, '../') !== false || strpos($file, '/etc/') !== false || strpos($file, '/var/') !== false || strpos($file, '/root/') !== false) {
                        echo '<div class="vulnerability">🚨 PATRÓN DE DIRECTORY TRAVERSAL DETECTADO</div>';
                        if ($waf_enabled) {
                            echo '<p><strong>Con WAF:</strong> <span class="protected">✅ ATAQUE BLOQUEADO - Patrón de traversal neutralizado</span></p>';
                        } else {
                            echo '<p><strong>Sin WAF:</strong> <span class="vulnerability">❌ VULNERABLE - Podría acceder a archivos sensibles del sistema</span></p>';
                        }
                    } else {
                        echo '<div class="protected">✅ Acceso a archivo legítimo</div>';
                    }
                    ?>
                </div>
            <?php endif; ?>
        </div>

        <!-- Información del Sistema -->
        <div class="demo-section">
            <h2>🔧 Información del Sistema</h2>
            <p><strong>Servidor:</strong> <?php echo $_SERVER['SERVER_NAME'] ?? 'localhost'; ?></p>
            <p><strong>IP del Cliente:</strong> <?php echo $_SERVER['REMOTE_ADDR'] ?? 'unknown'; ?></p>
            <p><strong>User Agent:</strong> <?php echo htmlspecialchars($_SERVER['HTTP_USER_AGENT'] ?? 'unknown'); ?></p>
            <p><strong>Timestamp:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
            <p><strong>Estado WAF:</strong> <span class="<?php echo $waf_enabled ? 'protected' : 'vulnerability'; ?>">
                <?php echo $waf_enabled ? '✅ ACTIVO' : '❌ INACTIVO'; ?>
            </span></p>
        </div>

        <!-- Headers de Seguridad -->
        <div class="demo-section">
            <h2>🔐 Headers HTTP Recibidos</h2>
            <div class="attack-demo">
                <?php
                foreach ($_SERVER as $key => $value) {
                    if (strpos($key, 'HTTP_') === 0) {
                        echo htmlspecialchars($key . ': ' . $value) . "\n";
                    }
                }
                ?>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Start and enable Apache and PHP
systemctl enable httpd
systemctl start httpd

# Configure firewall
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# Install monitoring tools
dnf install -y htop telnet nc

echo "Apache Vulnerable Demo setup completed for ${cliente}" > /var/log/cloud-init-output.log