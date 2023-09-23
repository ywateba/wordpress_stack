# Define your AWS provider configuration
provider "aws" {
  region = "us-east-1" # Update with your desired AWS region
}

# Create a VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create subnets (for your EC2 instances)
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
}

# Create a security group for your EC2 instances
resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Example security group for EC2 instances"

  # Define your security group rules here (e.g., SSH, HTTP, HTTPS, MySQL)
  # ...
}

# Create an EFS volume
resource "aws_efs_file_system" "example_efs" {
  creation_token = "example-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
}

# Create a mount target for the EFS volume in one of the subnets
resource "aws_efs_mount_target" "example_efs_mount_target" {
  file_system_id = aws_efs_file_system.example_efs.id
  subnet_id      = aws_subnet.subnet_a.id
  security_groups = [aws_security_group.example_sg.id]
}

# Launch Configuration for EC2 instances
resource "aws_launch_configuration" "example_lc" {
  name_prefix                 = "example-lc-"
  image_id                    = "ami-xxxxxxxxxxxx" # Specify your desired EC2 AMI ID
  instance_type               = "t2.micro"          # Specify your desired instance type
  security_groups             = [aws_security_group.example_sg.name]
  key_name                    = "your-key-pair"    # Replace with your SSH key pair
  associate_public_ip_address = true
  iam_instance_profile        = "your-iam-role"     # Replace with your IAM role
  user_data                   = <<-EOF
    #!/bin/bash
    # Add your EC2 instance setup script here
    # Mount the EFS volume, install software, etc.
    EOF
}

# Auto Scaling Group
resource "aws_autoscaling_group" "example_asg" {
  name_prefix                 = "example-asg-"
  launch_configuration        = aws_launch_configuration.example_lc.name
  min_size                    = 2 # Minimum number of instances
  max_size                    = 4 # Maximum number of instances
  desired_capacity            = 2 # Number of instances to launch initially
  vpc_zone_identifier         = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  # Use this block for scaling policies (e.g., based on CPU utilization)
  # ...
}

# Elastic Load Balancer (ELB)
resource "aws_lb" "example_lb" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  enable_deletion_protection = false # Disable for testing purposes

  enable_http2 = true

  # Define listener configuration here (e.g., HTTP listener)
  # ...
}

# MySQL RDS instance
resource "aws_db_instance" "example_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "exampledb"
  username             = "admin"
  password             = "your-password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true # Change to false if you want a final snapshot on deletion
}
