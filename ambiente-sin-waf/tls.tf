# TLS Private Key Generation (RSA 4096)
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to local file (optional)
resource "local_file" "private_key" {
  count           = var.ssh_key_pair_name != null ? 1 : 0
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.ssh_key_pair_name}.pem"
  file_permission = "0600"
}

# Save public key to local file (optional)
resource "local_file" "public_key" {
  count           = var.ssh_key_pair_name != null ? 1 : 0
  content         = tls_private_key.ssh_key.public_key_openssh
  filename        = "${path.module}/${var.ssh_key_pair_name}.pub"
  file_permission = "0644"
}