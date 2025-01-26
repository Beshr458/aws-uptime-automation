terraform {
  backend "s3" {
    bucket = "beshr-irland-tf"
    key    = "uptime-automation"
    region = "eu-west-1"
  }
}