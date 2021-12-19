# Variables
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5.0"
    }
  }

  backend "s3" {
    bucket         = "lmason98-tf-state-210901047"
    key            = "terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "tf_lock"
    encrypt        = true
  }
}

# Providers
provider "aws" {
  region = var.region
}

# Data
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# S3 state
resource "aws_s3_bucket" "tf-state" {
  bucket = var.state_name

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# state locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.locks_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Resources
resource "aws_default_vpc" "default" {}

# DB security
resource "aws_security_group" "db_rules" {
  name   = "only_allow_from_created_instance"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = "5432"
    to_port     = "5432"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance security
resource "aws_security_group" "server_rules" {
  name   = "allow_ssh_http_80"
  vpc_id = aws_default_vpc.default.id

  # Restrict inbound to port 22=ssh and 80=http
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

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# key pair to ssh into new instance
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = var.ssh_public_key
}

# postgres db for the instance
resource "aws_db_instance" "postgres" {
  identifier             = "tf-db"
  allocated_storage      = 10
  engine                 = "postgres"
  port                   = 5432
  instance_class         = "db.t3.micro"
  name                   = "tfdb"
  username               = "root"
  password               = "rootroot"
  vpc_security_group_ids = [aws_security_group.db_rules.id]
}

# ubuntu LTS nginx instance
resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.server_rules.id]

  # Add public key so we can ssh into the new instance
  key_name = "ssh_key"

  # Execute this bash script
  user_data = file("sh/setup.sh")
}
