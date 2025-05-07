
data "aws_secretmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-2:123456789012:secret:mysecret"
}

data "aws_secretmanager_secret_version" "current" {
  secret_id = data.aws_secretmanager_secret.secret.id
}

resource "aws_instance" "instances" {
  count                  = var.instance_count
  ami                    = "ami-01cd4de4363ab6ee8"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  user_data = <<-EOF
    #!/bin/bash
    DB_STRING="Server=${jsondecode(data.aws_secretmanager_secret_version.current.secret_string)["Host"]}; DB=${jsondecode(data.aws_secretmanager_secret_version.current.secret_string)["DB"]}; "
    echo $DB_STRING > test.txt
  EOF

  tags = {
    Name = "${var.prefix}-node-${count.index}"
  }
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
