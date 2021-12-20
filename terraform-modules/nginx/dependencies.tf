data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "tf-modules-17122021"
    key    = "base.tfstate"
    region = "eu-central-1"
  }
}