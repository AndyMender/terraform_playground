provider "google" {
  project = "mender-gcp-demo"
  region  = "eu-west1"
  zone    = "eu-west1-a"
}

resource "google_compute_network" "mender_vpc" {
  name = "mender-vpc"
}

