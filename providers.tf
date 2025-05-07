terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.97.0"
    }
  }
  required_version = "≳ 1.0.0"
}


provider "aws" {
  region  = "us-east-2"
  profile = "default"
}