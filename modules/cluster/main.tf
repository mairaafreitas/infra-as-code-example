
data "aws_secretmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-2:123456789012:secret:mysecret"
}

data "aws_secretmanager_secret_version" "current" {
  secret_id = data.aws_secretmanager_secret.secret.id
}

resource "aws_launch_template" "template" {
  name = "${var.prefix}-template"
  image_id               = "ami-01cd4de4363ab6ee8"
  instance_type          = "t2.micro"

  user_data = base64encode(
  <<-EOF
    #!/bin/bash
    DB_STRING="Server=${jsondecode(data.aws_secretmanager_secret_version.current.secret_string)["Host"]}; DB=${jsondecode(data.aws_secretmanager_secret_version.current.secret_string)["DB"]}; "
    echo $DB_STRING > test.txt
  EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_group_ids
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-node"
    }
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name= "${var.prefix}-autoscaling-group"
  desired_capacity     = 2
  max_size             = 1
  min_size             = 3
  vpc_zone_identifier = var.subnet_ids
  
  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}
