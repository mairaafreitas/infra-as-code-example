prefix = "dev-terraform"
vpc_cidr_block = "10.0.0.0/16"
subnet_cidr_blocks = [ "10.0.0.0/24", "10.0.1.0/24" ]
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