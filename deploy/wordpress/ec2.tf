
# Create a VPC
resource "aws_vpc" "wordpress_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet within the VPC
resource "aws_subnet" "wordpress_subnet" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Change to your desired availability zone
}

# Create an EFS file system
resource "aws_efs_file_system" "wordpress_efs" {
  creation_token = "wordpress-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = true

  tags = {
    Name = "wordpress_efs_volume"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id = aws_efs_file_system.wordpress_efs.id
  subnet_id      = aws_subnet.wordpress_subnet.id  # Replace with your subnet ID
  security_groups = [aws_security_group.efs_mount.id]
}

resource "aws_security_group" "efs_mount" {
  name        = "efs_mount"
  description = "EFS mount security group"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a security group for EC2 instances
resource "aws_security_group" "wordpress_security_group" {
  name_prefix = "wordpress-ec2-sg-"

  # Define your security group rules here (e.g., allow SSH and Docker traffic)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*linux*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Launch a scalable EC2 instance
resource "aws_launch_configuration" "wordpress_launch_config" {
  name_prefix          = "wordpress-ec2-launch-"
  image_id             =  data.aws_ami.ubuntu.id # Replace with your desired Amazon Linux AMI
  instance_type        = "t2.micro"     # Change to your desired instance type
  security_groups      = [aws_security_group.wordpress_security_group.name]
  key_name             = "wordpress-keypair"   # Replace with your SSH key pair
  user_data = <<-EOF
              #!/bin/bash
              # Install Docker here (and any other setup you need)
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              chkconfig docker on
              EOF
}

resource "aws_autoscaling_group" "wordpress_asg" {
  name_prefix                 = "wordpress-asg-"
  launch_configuration        = aws_launch_configuration.wordpress_launch_config.name
  vpc_zone_identifier         = [aws_subnet.wordpress_subnet.id]
  min_size                    = 1           # Minimum desired instances
  max_size                    = 3            # Maximum desired instances
  desired_capacity            = 2            # Initial number of instances
  health_check_type           = "EC2"
  termination_policies        = ["Default"]
  wait_for_capacity_timeout   = "10m"
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "wordpress_load_balancer" {
  name               = "wordpress-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.wordpress_subnet.id]
  enable_deletion_protection = false
}

# Create a target group
resource "aws_lb_target_group" "wordpress_target_group" {
  name        = "wordpress-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.wordpress_vpc.id
}

# Attach the target group to the ALB
resource "aws_lb_listener" "wordpress_listener" {
  load_balancer_arn = aws_lb.wordpress_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
     
    }
  }
}

# Create an RDS MySQL instance
resource "aws_db_instance" "wordpress_db_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name                 = "mydb"
  username             = "myuser"
  password             = "mypassword"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}
