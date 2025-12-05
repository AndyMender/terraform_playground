terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      # NOTE: Allow patch version updates, but no changes to major and minor versions via '~>'
      version = "~> 3.0.2"
    }
  
    random = {
      source  = "hashicorp/random"
      # NOTE: Multiple ','-separated version conditions are allowed
      version = "~> 3.1.0"
    }
  }
  required_version = "~> 1.7"
}
