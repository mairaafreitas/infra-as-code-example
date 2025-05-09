variable "prefix" {
    type        = string
}

variable "subnet_ids" {
    type        = list(string)
}

variable "security_group_ids" {
    type        = list(string)
}

variable "instance_count" {
    type        = number
}

variable "vpc_id" {
    type        = string
}

variable "user_data" {
  type = string
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number
}

variable "min_size" {
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
