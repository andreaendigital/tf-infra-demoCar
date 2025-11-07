terraform {
  backend "s3" {
    bucket         = "infraCar-terraform-state"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    #profile        = "terraform-user"
    encrypt        = true
  }
}
