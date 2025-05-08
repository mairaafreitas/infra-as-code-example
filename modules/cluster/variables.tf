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