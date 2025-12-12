provider "google" {
  project = "mender-gcp-demo"
  region  = "eu-west1"
  zone    = "eu-west1-a"
}

resource "google_project" "mender_project" {
  name       = "Mender Cloud Project"
  project_id = "mender-gcp-demo"
  # TODO: Below is an example org ID - has to be replaced by the real value when registering on GCP
  org_id     = "1234567"
}

resource "google_compute_network" "mender_vpc" {
  name = "mender-vpc"
}
