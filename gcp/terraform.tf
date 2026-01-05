terraform {
  required_providers {
    google = {
      # N: Shorthand provider names will default to 'registry.terraform.io' to fully resolve
      source = "hashicorp/google"
      # NOTE: Allow patch version updates, but no changes to major and minor versions via '~>'
      # ('~>' applies to right-most version specified)
      version = "~> 7.14.0"
    }
  }
  # NOTE: Versions 1.x are allowed. Below is set as the lowest compatible version.
  required_version = "~> 1.7"
}