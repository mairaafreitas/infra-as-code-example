terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.97.0"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

resource "aws_vpc" "vpc"  {
  cidr_block  = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_instance" "instance" {
  ami           = "ami-01cd4de4363ab6ee8"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "eip" {
  instance   = aws_instance.instance.id
  depends_on = [ aws_internet_gateway.internet_gateway ]
}

resource "aws_ssm_paramenter" "ssm_parameter" {
  name  = "vm_ip"
  type  = "String"
  value = aws_eip.eip.public_ip
}

output "pivate_dns" {
  value = aws_instance.instance.private_dns
}

output "eip" {
  value = aws_eip.eip.public_ip
}