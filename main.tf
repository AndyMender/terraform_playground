provider "docker" {}

# NOTE: 'random_pet' is a reserved Terraform resource name, 'petname' is just a field label
resource "random_pet" "petname" {
  # NOTE: 'length' defines the number of repeating blocks only. Block length depends on the randomized word.
  length    = 2
  separator = "-"
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  # NOTE: Alternatively, one can use the 'format()' built-in function
  name  = "tutorial-${random_pet.petname.id}"
  ports {
    internal = 80
    external = 8080
  }
}
