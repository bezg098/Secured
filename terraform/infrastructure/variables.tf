variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-west1"
}

variable "db_password" {
  description = "PostgreSQL password for secured_user"
  type        = string
  sensitive   = true
}

variable "flask_secret_key" {
  description = "Flask secret key for session signing"
  type        = string
  sensitive   = true
}
