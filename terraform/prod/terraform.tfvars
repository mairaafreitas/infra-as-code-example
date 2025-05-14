prefix = "prod-terraform"
vpc_cidr_block = "172.16.0.0/16"
subnet_cidr_blocks = [ "172.16.0.0/24", "172.16.1.0/24" ]
instance_count = 2

scale_in = {
  cooldown = 60
  scale_adjustment = -1
  threshold = 20
}

scale_out = {
    cooldown = 60
    scale_adjustment = 1
    threshold = 70
}