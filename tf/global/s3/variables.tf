variable "bucket_name" {
  description = "TF state bucket"
  type        = string
  default     = "a50-avpn-state"
}

variable "bucket_key" {
  description = "TF state path for the bucket"
  type        = string
  default     = "global/s3/terraform.tfstate"
}

variable "lock_table" {
  description = "DynamoDB state locking table"
  type        = string
  default     = "avpn-locks"
}

