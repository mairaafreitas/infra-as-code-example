output "private_dns" {
  value = module.cluster.private_dns
}

output "eip" {
  value = aws_eip.eip.public_ip
}