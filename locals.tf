locals {
  region = "us-east-1"

  common_tags = {
    Name        = "docker-${var.name}"
    Terraform   = "true"
    Environment = "dev"
  }
}
