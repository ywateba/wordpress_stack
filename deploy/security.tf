provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
}

resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = "wordpress-bucket" # Replace with your desired S3 bucket name
  acl    = "private" # You can adjust the ACL as needed for your security requirements
}

resource "aws_s3_bucket_object" "wordpress_private_key" {
  bucket       = aws_s3_bucket.wordpress_bucket.id
  key          = "wordpress/keypair/private.key"
  source       = ".local/wordpress-keypair" # Replace with the path to your private key
  content_type = "application/octet-stream"
  etag         = filemd5(".local/wordpress-keypair") # Optional but recommended
}

resource "aws_s3_bucket_object" "wordpress_public_key" {
  bucket       = aws_s3_bucket.wordpress_bucket.id
  key          = "wordpress/keypair/public.key"
  source       = ".local/wordpress-keypair.pub" # Replace with the path to your private key
  content_type = "application/octet-stream"
  etag         = filemd5(".local/wordpress-keypair.pub") # Optional but recommended
}

resource "aws_key_pair" "wordpress_key_pair" {
  key_name   = "wordpress-keypair"
  public_key = file(".local/wordpress-keypair.pub") # Use the path to your public key

}


resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "linode.pem"
  file_permission = "0600"
}

output "private_key" {
  value = tls_private_key.ssh_key.private_key_pem
  sensitive=true
}

output "public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
  sensitive=true
}
