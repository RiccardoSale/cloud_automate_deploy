# terraform-ansible-digitalocean-deploy
Folder automate deploy!
Automate the deploy of a wordpress application using terraform and ansible.

## How to use
### Clone this repository

```
git clone git
```

You must have terraform and ansible installed.
You need to have an account with digital ocean, and create a personal private token and ssh keys.

Tested on:
Terraform v1.3.6
+ provider.digitalocean 2.14.1

### Digital Ocean Token

To provision the infrastructure where the blog with Wordpress will be installed, it is necessary to have an account in Digital Ocean.
Once we have the account, we must give Terraform access so that it can create the infrastructure for us.
For this it is necessary to generate a token, go to the page: https://cloud.digitalocean.com/account/api/tokens and create it.

### Create variables file
In the root path of the code, modify terraform.tfvars and place the following variables:
```
do_token: must have the token created in the previous step.
ssh_key_private: the path of the private key that will be used to access the server in Digital Ocean.
```
You could use the Digital Ocean Command-line client for choose the:
- name of the image
- disk size / ram size based on the name
- You need to generate two files and place them in the root directory of the project with the command ssh keygen
- files : id_rsa (private key) and id_rsa.pub (public key)

To list all OS available:
```
$ doctl  -t [TOKEN] compute  image list --public
```

To list all server region available:
```
$ doctl  -t [TOKEN] compute  region list
```

To list all sizes available:
```
$ doctl  -t [TOKEN] compute  size list
```

### Configuration files
# mysql
playbooks/roles/mysql/defaults/main.yml contains the following variables that can be modified:

```
wp_mysql_db: wordpress
wp_mysql_user: wordpress
wp_mysql_password: randompassword
```
# wordpress

playbooks/roles/wordpress/defaults/main.yml contains the following variables that can be modified:
```
wp_site_title: claranet
wp_site_user: superadmin
wp_site_password: strongpasshere
wp_site_email: some_email@example.com
```

### How start the deploy process

To deploy just execute the following commands:
```
$ terraform init
$ terraform plan
$ terraform apply
```
We then can access to wordpress site in the address display/ip by ansible.
