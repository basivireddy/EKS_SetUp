terraform {
  backend "s3" {
    bucket      = "terraform-statefile-bucket-pa"
    key            = "prod/terraform-eks-prod.tfstate"
    region    = "us-west-1"
  }
}