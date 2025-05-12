terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.97.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state"
    key            = "states/terraform.tfstate"
    profile        = "default"
    dynamodb_table = "tf-state-locking"
  }

  required_version = "≳ 1.8.1"
}


provider "aws" {
  region  = "us-east-2"
  profile = "default"
}