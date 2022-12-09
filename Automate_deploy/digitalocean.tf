terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Claranet"
  public_key = file("id_rsa.pub")
}

variable "do_token" {
  default =  "dop_v1_e0cb939d6de74e898abc8e2fb6ccc2f4b0779e839560abab29c0e6fea55c8c23"
  }

variable "ssh_key_private" {
  default = "id_rsa"
}

variable "droplet_name" {}
variable "droplet_size" {}
variable "droplet_region" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
    token = var.do_token

}

# Create a web server in digitalOcean
resource "digitalocean_droplet" "claranet" {
    image  = "centos-7-x64"
    name   = "claranet"
    region = "fra1"
    size   = "s-1vcpu-1gb"
    monitoring = "true"
    ssh_keys = [digitalocean_ssh_key.default.fingerprint]
    # Install python on the droplet using remote-exec to execute ansible playbooks to configure the services
    provisioner "remote-exec" {
        inline = [ #yum do not require refreshing packages
          "yum install python -y",
        ]

         connection {
            host        = self.ipv4_address
            type        = "ssh"
            user        = "root"
            private_key = file(var.ssh_key_private)
        }
    }

    # Execute playbooks
    provisioner "local-exec" {
        environment = {
            PUBLIC_IP                 = self.ipv4_address
            PRIVATE_IP                = self.ipv4_address_private
            ANSIBLE_HOST_KEY_CHECKING = "False" 
        }

        working_dir = "playbooks/"
        command     = "ansible-playbook -u root --private-key ${var.ssh_key_private} -i ${self.ipv4_address}, wordpress_playbook.yml"
    }
}