terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "xiomaraupao"
}

module "image_processor" {
  source      = "../../modules/image_processor"
  environment = var.environment
  region      = var.region
  vpc_cidr    = var.vpc_cidr
}
