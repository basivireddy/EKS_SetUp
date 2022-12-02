terraform {
  backend "s3" {
    bucket      = "terraformstatefile1130198"
    key            = "nonprod/terraform-eks.tfstate"
    region    = "us-east-1"
  }
}
