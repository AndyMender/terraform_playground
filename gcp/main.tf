provider "google" {
  project     = "mender-gcp-demo"
  region      = "eu-west1"
}

resource "google_compute_network" "mender-vpc" {
  name = "mender-vpc"
}

