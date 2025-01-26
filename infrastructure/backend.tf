terraform {
  backend "s3" {
    bucket = var.tf_s3_bucket
    key    = "terraform.tfstate"
    region = var.region
  }
}