module "network" {
  source = "./modules/network"
  vpc_cidr_block = var.vpc_cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
  prefix = var.prefix
}

module "cluster" {
  source             = "./modules/cluster"
  prefix             = var.prefix
  subnet_ids         = module.network.subnet_id
  instance_count     = var.instance_count
  security_group_ids = [module.network.security_group_ids]
  vpc_id             = module.network.vpc_id
  user_data          =   <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    public_ip=$(curl -s http://checkip.amazonaws.com)
    echo "<h1>Hello from ${public_ip}</h1>" | tee /usr/share/nginx/html/index.html > dev/null
    systemctl restart nginx
  EOF
  desired_capacity = 1
  max_size         = 3
  min_size         = 1
  scale_out = var.scale_out
  scale_in  = var.scale_in

}