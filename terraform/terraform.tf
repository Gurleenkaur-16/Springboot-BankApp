terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.64.0"
    }

    tls = {
      source = "hashicorp/tls"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}