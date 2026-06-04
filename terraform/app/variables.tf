variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-west1"
}

variable "image_tag" {
  description = "Docker image tag (commit SHA set by CI/CD)"
  type        = string
  default     = "latest"
}
