provider aws {
  region = "eu-central-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    encrypt = true
    bucket = "tf-modules-17122021"
    region = "eu-central-1"
    key     = "task3.tfstate"
    profile = "default"
  }
}
