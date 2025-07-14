terraform {
  backend "s3" {
    bucket         = "palo-alto-challenge-terraform-state-staging"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
