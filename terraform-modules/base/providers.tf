provider aws {
  region = "eu-central-1"
}

provider "http" {
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }
  }

  backend "s3" {
    encrypt = true
    bucket = "tf-modules-17122021"
    region = "eu-central-1"
    key     = "base.tfstate"
    profile = "default"
  }
}
