variable "prefix" {
  type  = string  
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_blocks" {
  type = list(string)
}

variable "instance_count" {
    type = number
}

variable "scale_out" {
  type = object({
    scale_adjustment = number
    cooldown         = number
    threshold        = number 
  })
}

variable "scale_in" {
  type = object({
    scale_adjustment = number
    cooldown         = number
    threshold        = number 
  })
}