terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      # NOTE: Allow patch version updates, but no changes to major and minor versions via '~>'
      # ('~>' applies to right-most version specified)
      version = "~> 3.0.2"
    }
  
    random = {
      source  = "hashicorp/random"
      # NOTE: Multiple ','-separated version conditions are allowed
      version = "~> 3.1.0"
    }
  }
  # NOTE: Versions 1.x are allowed. Below is set as the lowest compatible version.
  required_version = "~> 1.7"
}
