# Variables
variable "region" {
  default = "us-west-1"
}

variable "ssh_public_key" {
  description = "public key so we can ssh into the new instance"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrQpZWyNaepKv4wtrAJ7P8qSIWH4JiI/YB3lmhMtcWFkVLjlVwDI/pKuuax9gdCfX87PlaWM4UY6zrRew9I5yOdOgvnqrm6cYorFLJX3oQFzGRU3P6WCzU7rXJk0vu6ZmNE2k6H1vU/phhkhVAoWJp5AxVB1HQ3FDIOnGA5yj0i1dlSs9f7nW0ChO3r9XI3IbVxhSQrxGjtchFD/N4lh+/Kc1Urw4sJ6QMFRpgoReaiNB0HbpCM2Cvi2FlRB9c4oZ7OiJK3oq/3TBk6UK3WJJUtD52+6t8PvtaeNVxqdzTJDjAZn6aIPUh8PkkYRJWr80Ji5seNJUfWFBmCZR02HBy+ZX2EXLm8Q9ho6Fcqp0NShqazIo4BoXy712fALU0R1Lyf2Y5bcOpL53QQlUG4idYg6nbRjzBsX93K2N9QH0iBQi6BPSfuaT8jMwaAFB3fBfPESV9+IMRIUjQ9g+GppCsBVelaZB+YXEMJYN94zLsJX48rzyhOnnEmVnD+YbmJzEx7uGLBY/ZUJkxu0Q2RyBuzFTAXcLfg5JhVe5+IvzHeITGBR0fFaPoYs8DZO69gOPfpe4OvOee+EmQwvvoKAY/u0kvx7Oq887YCJCoaUOkVaPsfM9Z1xcK2V6Unnr8R1dK456EZnsZsr66GunIAUPEoZsfISQT4eqCsSyh/tw7uw== lmason98@gmail.com"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.5.0"
    }
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

# Resources
resource "aws_default_vpc" "default" {}

resource "aws_security_group" "allow_ssh_http_80" {
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

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = var.ssh_public_key
}

resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_80.id]

  tags = {
    Name = "nginx-hello-world"
  }

  # Add public key so we can ssh into the new instance
  key_name = "ssh-key"

  # Execute this bash script
  user_data = file("sh/install_nginx.sh")
}

# Output
output "aws_instance_public_dns" {
  description = "Public url for new AWS instance"
  value       = aws_instance.nginx.public_dns
}

output "aws_instance_public_ip" {
  description = "Public ip for new AWS instance"
  value       = aws_instance.nginx.public_ip
}
