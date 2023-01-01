terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
  profile = "default"
}



# Create S3 Bucket
resource "aws_s3_bucket" "tf_bucket" {
  bucket = "saurav-tf-bucket"
  tags = {
    Name = "tf backend"
  }
}

resource "aws_s3_bucket_acl" "tf_acl" {
  bucket = aws_s3_bucket.tf_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tf_versioning" {
  bucket = aws_s3_bucket.tf_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}