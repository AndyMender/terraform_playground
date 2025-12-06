# NOTE: Central (root) config defining which components (providers) and which versions are required
# NOTE2: New providers can be authored and submitted by OSS contributors
terraform {
  required_providers {
    docker = {
      # NOTE: Shorthand provider names will default to 'registry.terraform.io' to fully resolve
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
