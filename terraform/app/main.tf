terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "secured-terraform-state-498301"   # replace with your GCS bucket
    prefix = "secured/app"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Read outputs from infrastructure/ state
data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = "secured-terraform-state-498301"
    prefix = "secured/infrastructure"
  }
}

# ── Artifact Registry ─────────────────────────────────────────────────────────

resource "google_artifact_registry_repository" "repo" {
  repository_id = "secured"
  format        = "DOCKER"
  location      = var.region
}

# ── Cloud Run ─────────────────────────────────────────────────────────────────

resource "google_cloud_run_v2_service" "app" {
  name     = "secured-app"
  location = var.region

  template {
    service_account = data.terraform_remote_state.infra.outputs.cloud_run_sa_email

    vpc_access {
      connector = data.terraform_remote_state.infra.outputs.connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/secured/secured-app:${var.image_tag}"

      env {
        name  = "DB_USER"
        value = "secured_user"
      }
      env {
        name  = "DB_NAME"
        value = "secured_db"
      }
      env {
        name  = "DB_HOST"
        value = data.terraform_remote_state.infra.outputs.db_private_ip
      }
      env {
        name = "DB_PASS"
        value_source {
          secret_key_ref {
            secret  = data.terraform_remote_state.infra.outputs.db_password_secret
            version = "latest"
          }
        }
      }
      env {
        name = "FLASK_SECRET_KEY"
        value_source {
          secret_key_ref {
            secret  = data.terraform_remote_state.infra.outputs.flask_secret_id
            version = "latest"
          }
        }
      }

      resources {
        limits = { cpu = "1", memory = "512Mi" }
      }
    }
  }
}

# Allow public access to Cloud Run
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "app_url" {
  value = google_cloud_run_v2_service.app.uri
}
