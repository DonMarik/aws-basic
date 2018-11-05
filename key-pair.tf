resource "tls_private_key" "ma-privkey"
{
    algorithm = "RSA" 
    rsa_bits = 4096
}
resource "aws_key_pair" "ma-keypair"
{
    key_name = "${var.key_name}"
    public_key = "${tls_private_key.ma-privkey.public_key_openssh}"
}
output "private_key" {
  value = "${tls_private_key.ma-privkey.private_key_pem}"
  sensitive = true
}
