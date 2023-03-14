terraform {
  backend "s3" {
    # NOTE: Do you need to update dynamodb_table, bucket, and key?
    dynamodb_table = "avpn-locks"
    bucket         = "a50-avpn-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}
