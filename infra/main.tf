provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com"
  ])
  project = var.project_id
  service = each.key
}

resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "pawa-repo"
  format        = "DOCKER"
}

resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_cloud_run_service" "app" {
  name     = "pawa-app"
  location = var.region
  project  = var.project_id

  template {
    spec {
      containers {
        image = var.image_url
      }
      service_account_name = google_service_account.cloud_run_sa.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

}

resource "google_cloud_run_service_iam_member" "internal_access" {
  service  = google_cloud_run_service.app.name
  location = var.region
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}