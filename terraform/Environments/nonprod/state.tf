terraform {
  backend "s3" {
    bucket      = "terraform-statefile-bucket-pa"
    key            = "nonprod/terraform-eks.tfstate"
    region    = "us-west-1"
  }
}