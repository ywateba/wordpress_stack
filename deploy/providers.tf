# Define your AWS provider configuration


terraform {
  backend "s3" {
    bucket         = "arydevs-learn" # Replace with your S3 bucket name
    key            = "wordpress/state.tfstate"         # Replace with your desired state file name
    region         = "us-east-1"                 # Replace with your desired AWS region
    encrypt        = true                        # Optional: Enable encryption at rest
    # kms_key_id     = "your-kms-key-id"           # Optional: KMS key ID for encryption
    # dynamodb_table = "my-lock-table"             # Optional: Use DynamoDB for state locking
  }
}
provider "aws" {
  region = "us-east-1" # Update with your desired AWS region
}
