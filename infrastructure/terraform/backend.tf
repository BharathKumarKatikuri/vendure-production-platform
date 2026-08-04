terraform {
  backend "s3" {
    bucket       = "vendure-production-tfstate-974268348514"
    key          = "vendure-production/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
