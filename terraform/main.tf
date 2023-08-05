terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {}

resource "digitalocean_ssh_key" "default" {
  name       = "ssh key for ghidra server"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "digitalocean_droplet" "server" {
  image     = "docker-20-04"
  name      = "ghidra"
  region    = "nyc1"
  size      = "s-1vcpu-1gb"
  ssh_keys  = [digitalocean_ssh_key.default.fingerprint]
  user_data = file("cloud-config.yaml")

  lifecycle {
    prevent_destroy = true
  }
}

variable "ALLOWED_IP" {
  type        = string
  description = "IP address to allow ingress to server from."
  sensitive   = true
}

resource "digitalocean_firewall" "server" {
  name = "ghidra-server-firewall"

  droplet_ids = [digitalocean_droplet.server.id]

  # Open ports for Ghidra server
  inbound_rule {
    protocol         = "tcp"
    port_range       = "13100-13102"
    source_addresses = [var.ALLOWED_IP]
  }

  # Open ports for SSH access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.ALLOWED_IP]
  }

  # Allow outbound traffic to anywhere
  dynamic "outbound_rule" {
    # Both TCP and UDP because `dig` uses UDP.
    for_each = ["tcp", "udp"]
    iterator = protocol
    content {
      protocol              = protocol.value
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0"]
    }
  }
}
