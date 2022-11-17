terraform {
  backend "s3" {
    bucket      = "terraform-statefile-bucket-pa-test"
    key            = "prod/terraform-eks-prod.tfstate"
    region    = "us-west-2"
  }
}