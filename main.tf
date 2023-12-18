terraform {
  backend "s3" {
    # bucket = "my-bucket"
    key    = "aws-vpc-rds.tfstate"
    region = "eu-central-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  region = "eu-central-1" # specify your region
}