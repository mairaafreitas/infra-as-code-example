terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.97.0"
    }
  }
  required_version = "≳ 1.0.0"

  backend "s3" {
    bucket         = "terraform-state"
    key            = "states/terraform.dev.tfstate"
    profile        = "default"
    dynamodb_table = "tf-state-locking"
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "default"
}