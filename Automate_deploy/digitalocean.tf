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
  default =  "dop_v1_e125177c5854d4e4eb3909188542e9f6df1a0720f7b3c81541925f6fbfd688b5"
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

# Create a droplet in digitalOcean
# we can later change the size / ram / cpu of the droplet if we see with monitoring alert that the resorces are too low!
resource "digitalocean_droplet" "claranet" {
    image  = "centos-7-x64"  #choose centos OS instead of ubuntu because its more stable for server enviroment
    name   = "claranet"
    region = "fra1"
    size   = "s-1vcpu-1gb"
    monitoring = "true"
    backups = "true"  #enable automatic backup of the droplet / we can also later enable backup linux with Rsync
    ssh_keys = [digitalocean_ssh_key.default.fingerprint]

    # Install python on the droplet using remote-exec to execute ansible playbooks to configure the services
    provisioner "remote-exec" {
        inline = [ #yum do not require refreshing packages or we can also use aptitude
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

#we can configure some allert using the monitor allert for improve fault-tolerance
resource "digitalocean_monitor_alert" "cpu_alert" {
    alerts {
      email = ["riccardosale2001@gmail.com"]
      slack {
        channel   = "Production Alerts"
        url       = "testurl"
      }
    }
    window      = "5m"
    type        = "v1/insights/droplet/cpu"
    compare     = "GreaterThan"
    value       = 90
    enabled     = true
    entities    = [digitalocean_droplet.claranet.id]
    description = "Alert about CPU usage"
}