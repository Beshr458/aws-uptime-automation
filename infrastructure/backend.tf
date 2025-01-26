terraform {
  backend "s3" {
    bucket = "beshr-ireland-tf"
    key    = "uptime-automation"
    region = "eu-west-1"
  }
}