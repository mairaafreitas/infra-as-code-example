output "pivate_dns" {
  value = aws_instance.instance.private_dns
}

output "eip" {
  value = aws_eip.eip.public_ip
}