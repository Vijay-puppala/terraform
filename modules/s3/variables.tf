variable "name_prefix" {
  description = "Prefix used to build the bucket name when bucket_name is not set."
  type        = string
}

variable "bucket_suffix" {
  description = "Purpose of the bucket, used in the generated name (e.g. \"data\", \"logs\")."
  type        = string
  default     = "data"
}

variable "bucket_name" {
  description = "Explicit globally-unique bucket name. Overrides the generated name."
  type        = string
  default     = null
}

variable "versioning_enabled" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS. When null, SSE-S3 (AES256) is used."
  type        = string
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "Days after which noncurrent object versions are permanently deleted."
  type        = number
  default     = 90
}

variable "force_destroy" {
  description = "Allow Terraform to delete the bucket even if it contains objects."
  type        = bool
  default     = false
}
