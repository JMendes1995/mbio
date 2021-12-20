resource "aws_s3_bucket" "tf-modules-17122021" {
  bucket = "tf-modules-17122021"
  acl    = "private"
}


resource "aws_s3_bucket" "kops_cluster" {
  bucket = "cluster.mbio.com"
  acl    = "private"
}