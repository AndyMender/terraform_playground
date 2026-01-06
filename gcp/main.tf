# NOTE: If not defined, Terraform will generate a 'provider' block with default parameters,
# unless some of the parameters are mandatory!
provider "google" {
  project = "mender-gcp-demo"
  region  = "eu-west1"
  zone    = "eu-west1-a"
}

resource "google_project" "mender-project" {
  name = "Mender Cloud Project"
  # NOTE: hyphen-separated clear-text project ID, not the project number!
  project_id = "mender-gcp-demo"
  # TODO: Below is an example org ID - has to be replaced by the real value when registering on GCP
  org_id = "1234567"
}

### NETWORK RESOURCES ###
resource "google_compute_network" "mender-vpc" {
  name = "mender-vpc"
  # NOTE: Automatic subnets are a bad idea, because they instantly exhaust CIDR ranges
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mender-vpc-eu-west1" {
  name          = "mender-vpc-eu-west1"
  ip_cidr_range = "10.132.0.0/20"
  network       = google_compute_network.mender-vpc.id
  # NOTE: This is the default stack_type
  stack_type = "IPV4_ONLY"
  # NOTE: Enables access to Google Cloud APIs from private-only Compute Engine VMs (ones without a public IP address)
  private_ip_google_access = true
  # Extra private subnet, for instance for use in the Kubernetes cluster
  secondary_ip_range {
    range_name    = "mender-vpc-eu-west1-secondary"
    ip_cidr_range = "192.168.5.0/20"
  }

  # Extra logging into Cloud Logging to track and alert on hostile connection attempts
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# NOTE: Several firewall rules are required,
# since Terraform instantly links any 'allow' and 'deny' rules to provided tags

resource "google_compute_firewall" "mender-vpc-firewall-default-deny" {
  name    = "mender-vpc-firewall-default-deny"
  network = google_compute_network.mender-vpc.name

  # Allow anonymous pings
  deny {
    protocol = "all"
  }
}

resource "google_compute_firewall" "mender-vpc-firewall-allow-ping" {
  name = "mender-vpc-firewall-allow-ping"
  network = google_compute_network.mender-vpc.name

  allow {
    protocol = "icmp"
  }
}

# TODO: Add ALLOW ruleset for SSH traffic if needed
resource "google_compute_firewall" "mender-vpc-firewall-allow-web" {
  name    = "mender-vpc-firewall-allow-web"
  network = google_compute_network.mender-vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443"]
  }

  target_tags = ["web-server"]
}

# TODO: Configure later
# resource "google_artifact_registry_repository" "mender-docker-repo" {
#   location      = "eu-west1"
#   repository_id = "mender-docker-repo"
#   description   = "Main Docker repository for app deployments"
#   format        = "DOCKER"
#   cleanup_policy_dry_run = false
#   cleanup_policies {
#     id     = "delete-untagged"
#     action = "DELETE"
#     condition {
#       tag_state    = "UNTAGGED"
#     }
#   }
#   cleanup_policies {
#     id     = "keep-new-untagged"
#     action = "KEEP"
#     condition {
#       tag_state    = "UNTAGGED"
#       newer_than   = "7d"
#     }
#   }
#   cleanup_policies {
#     id     = "delete-prerelease"
#     action = "DELETE"
#     condition {
#       tag_state    = "TAGGED"
#       tag_prefixes = ["alpha", "v0"]
#       older_than   = "30d"
#     }
#   }
#   cleanup_policies {
#     id     = "keep-tagged-release"
#     action = "KEEP"
#     condition {
#       tag_state             = "TAGGED"
#       tag_prefixes          = ["release"]
#       package_name_prefixes = ["webapp", "mobile"]
#     }
#   }
#   cleanup_policies {
#     id     = "keep-minimum-versions"
#     action = "KEEP"
#     most_recent_versions {
#       package_name_prefixes = ["webapp", "mobile", "sandbox"]
#       keep_count            = 5
#     }
#   }
# }
