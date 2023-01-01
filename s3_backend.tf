# S3 Backend
terraform {
  backend "s3" {
    bucket = "saurav-tf-bucket"
    key    = "path/to/my/key"
    region = "ap-south-1"
  }
}