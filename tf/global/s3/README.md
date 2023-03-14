# Introduction

Create an s3 bucket for org .tfstate files...
Think good and hard about the name of the bucket and table, because these
changes will cascade throughout the code base.

# Configuring

1. `terraform init`
2. `terraform plan`
    * Create a bucket to store state in, versioned, encrypted, and sans public access
    * Create a DynamoDB locking table
3. `terraform apply`
4. Update terraform.tf, uncommenting the backend config
5. `terraform init`

