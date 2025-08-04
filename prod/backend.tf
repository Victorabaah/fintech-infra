terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    key            = "prod/terraform.state"
    bucket         = "class38dominion-vic-terraform-backend"
    region         = "us-east-2"
    dynamodb_table = "terraform-vic-state-locks"
  }
}
