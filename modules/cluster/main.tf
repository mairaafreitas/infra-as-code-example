
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

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.prefix}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
  alarm_name          = "${var.prefix}-scale-out-alarm"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "60"
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 30
  evaluation_periods  = 3

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
  
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "${var.prefix}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_in_alarm.arn]
  alarm_name          = "${var.prefix}-scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = "20"
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 30
  evaluation_periods  = 3

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
  
}