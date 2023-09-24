
resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = "wordpress-bucket" # Replace with your desired S3 bucket name
  acl    = "private" # You can adjust the ACL as needed for your security requirements
}

resource "aws_s3_object" "wordpress_private_key" {
  bucket       = aws_s3_bucket.wordpress_bucket.id
  key          = "wordpress/keypair/private.key"
  source       = "../local/wordpress-keypair" # Replace with the path to your private key
  content_type = "application/octet-stream"
  etag         = filemd5("../local/wordpress-keypair") # Optional but recommended
}

resource "aws_s3_object" "wordpress_public_key" {
  bucket       = aws_s3_bucket.wordpress_bucket.id
  key          = "wordpress/keypair/public.key"
  source       = "../local/wordpress-keypair.pub" # Replace with the path to your private key
  content_type = "application/octet-stream"
  etag         = filemd5("../local/wordpress-keypair.pub") # Optional but recommended
}





