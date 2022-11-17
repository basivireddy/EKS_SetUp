terraform {
  backend "s3" {
    bucket      = "terraform-statefile-bucket-pa-test"
    key            = "nonprod/terraform-eks.tfstate"
    region    = "us-west-2"
  }
}