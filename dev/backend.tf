terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    key            = "dev/terraform.state"
    bucket         = "class38-terraform-backend-bucket01"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locking"
  }
}
