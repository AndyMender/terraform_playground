# NOTE: If not defined, Terraform will generate a 'provider' block with default parameters,
# unless some of the parameters are mandatory!
provider "aws" {
  # Europe, Paris
  region = "eu-west-2"
}

### NETWORK RESOURCES ###
resource "aws_vpc" "mender-vpc" {
  # TODO: Does AWS require a specific IP range for each region?
  cidr_block = "10.132.0.0/20"
  # NOTE: Defaults to 'true'
  enable_dns_support = true
}

resource "aws_subnet" "mender-vpc-eu-west2" {
  vpc_id            = aws_vpc.mender-vpc.id
  availability_zone = "euw2-az2"
  cidr_block        = "10.132.0.0/20"
  # NOTE: Defaults to 'false'
  ipv6_native = false
}

# Secondary CIDR range for use in Kubernetes if needed
resource "aws_subnet" "mender-vpc-eu-west2-secondary" {
  vpc_id            = aws_vpc.mender-vpc.id
  availability_zone = "euw2-az1"
  cidr_block        = "192.168.5.0/20"
  # NOTE: Defaults to 'false'
  ipv6_native = false
}


resource "aws_networkfirewall_rule_group" "mender-vpc-firewall-allow-ping" {
  # The maximum number of operating resources that this rule group can use.connection {
  # The docs do not explain what is a good number: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group
  capacity    = 1
  description = "Allow incoming pings"
  name        = "mender-vpc-firewall-main"
  type        = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "mender-vpc-firewall-allow-web" {
  capacity = 1
  name     = "mender-vpc-firewall-allow-web"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      port_sets {
        key = "HTTP_PORTS"
        port_set {
          definition = ["443", "80", "8080"]
        }
      }
    }
    rules_source {
      stateful_rule {
        action = "PASS"
        header {
          destination      = "ANY"
          destination_port = "$HTTP_PORTS"
          protocol         = "TCP"
          direction        = "ANY"
          source_port      = "ANY"
          source           = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["1"]
        }
      }
    }
  }
  tags = {
    Tag1 = "web-server"
  }
}

resource "aws_networkfirewall_firewall_policy" "firewall_policy" {
  name = "firewall-policy"
  firewall_policy {
    # TODO: Guarantees a default deny behavior without an explicit rule_group?
    stateless_default_actions          = ["aws:drop"]
    stateless_fragment_default_actions = ["aws:drop"]
    stateless_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.mender-vpc-firewall-allow-ping.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.mender-vpc-firewall-allow-web.arn
    }
  }
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