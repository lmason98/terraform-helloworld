# Variables
variable "region" {
  default = "us-west-1"
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

resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_80.id]

  tags = {
    Name = "tf-hello-world"
  }

  # TODO: fill this block so remote exec can work
  # connenction {
  #   type =
  #   host =
  #   user =
  #   private_key =
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt install nginx -y",
  #     "sudo systemctl enable nginx",
  #     "sudo systemctl start nginx"
  #   ]
  # }
}

# Output
output "aws_instance_public_dns" {
  value = aws_instance.nginx.public_dns
}
