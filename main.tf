terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.97.0"
    }
  }
}

data "aws_secretmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-2:123456789012:secret:mysecret"
}

data "aws_secretmanager_secret_version" "current" {
  secret_id = data.aws_secretmanager_secret.secret.id
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
  ami                    = "ami-01cd4de4363ab6ee8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [ aws_security_group.security_group.id ]

  user_data = <<-EOF
    #!/bin/bash
    DB_STRING="Server=${jsondecode(data.aws_secretmanager_secret_version.current.secret_string)["Host"]}; DB=${jsondecode(data.aws_secretmanager_secret_version.current.secret_string)["DB"]}; "
    echo $DB_STRING > test.txt
  EOF
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

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id
  name   = "Allow SSH"

  tags = {
    Name = "Allow SSH"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress_rules" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "sg_egress_rules" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

output "pivate_dns" {
  value = aws_instance.instance.private_dns
}

output "eip" {
  value = aws_eip.eip.public_ip
}