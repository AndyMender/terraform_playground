# NOTE: Direct provider features include:
# - Running Docker on a remote 'host' (via SSH with optional 'ssh_opts', or TCP + TLS)
# - Pulling Docker images from a private registry via 'registry_auth'
#   and an associated Terraform 'data' block called "docker_registry_image"
#   (credentials can be handled via a separate config file or a credentials helper tool)
# - Passing a custom config via a "docker_service" 'resource' block
provider "docker" {}

# NOTE: 'random_pet' is a reserved Terraform resource name, 'petname' is just a field label
resource "random_pet" "petname" {
  # NOTE: 'length' defines the number of repeating blocks only. Block length depends on the randomized word.
  length    = 2
  separator = "-"
}

data "docker_registry_image" "nginx" {
  name = "nginx:1.29"
}

resource "docker_image" "nginx" {
  name         = data.docker_registry_image.nginx.name
  # NOTE: Allows tracking container content changes as opposed to just tracking the image tag
  pull_triggers = [data.docker_registry_image.nginx.sha256_digest]
  # NOTE: To avoid keeping the base image locally - useful in bare metal deployments
  # keep_locally = false
}

# TODO: Use a dedicated name for each project
locals {
  container_name = "tutorial"
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  # NOTE: Alternatively, one can use the 'format()' built-in function
  name  = "${local.container_name}-${random_pet.petname.id}"
  ports {
    internal = 80
    external = 8080
  }
}
