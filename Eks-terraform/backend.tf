terraform {
  backend "s3" {
    bucket = "elisemomo" # Replace with your actual S3 bucket name
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}
