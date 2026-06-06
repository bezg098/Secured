terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "secured-terraform-state-498301"
    prefix = "secured/infrastructure"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name                    = "cis410-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "cis410-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_vpc_access_connector" "connector" {
  name         = "secured-connector"
  region       = var.region
  subnet {
    name = google_compute_subnetwork.subnet.name
  }
  machine_type  = "e2-micro"
  min_instances = 2
  max_instances = 3
}

resource "google_sql_database_instance" "db" {
  name             = "secured-db"
  database_version = "POSTGRES_15"
  region           = var.region
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }
}

resource "google_sql_database" "secured_db" {
  name     = "secured_db"
  instance = google_sql_database_instance.db.name
}

resource "google_sql_user" "app_user" {
  name     = "secured_user"
  instance = google_sql_database_instance.db.name
  password = var.db_password
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "secured-db-password"
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "db_password_val" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

resource "google_secret_manager_secret" "flask_secret" {
  secret_id = "secured-flask-secret"
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "flask_secret_val" {
  secret      = google_secret_manager_secret.flask_secret.id
  secret_data = var.flask_secret_key
}

resource "google_service_account" "cloud_run_sa" {
  account_id   = "secured-cloudrun-sa"
  display_name = "Secured Cloud Run Service Account"
}

resource "google_project_iam_member" "sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "db_pass_access" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "flask_secret_access" {
  secret_id = google_secret_manager_secret.flask_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

output "vpc_id"             { value = google_compute_network.vpc.id }
output "connector_id"       { value = google_vpc_access_connector.connector.id }
output "db_instance_name"   { value = google_sql_database_instance.db.name }
output "db_connection_name" { value = google_sql_database_instance.db.connection_name }
output "db_private_ip"      { value = google_sql_database_instance.db.private_ip_address }
output "cloud_run_sa_email" { value = google_service_account.cloud_run_sa.email }
output "db_password_secret" { value = google_secret_manager_secret.db_password.secret_id }
output "flask_secret_id"    { value = google_secret_manager_secret.flask_secret.secret_id }