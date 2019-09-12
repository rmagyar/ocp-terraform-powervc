################################################################
# Configure the OpenStack Provider
################################################################

variable "user_name" {
    description = "The user name used to connect to OpenStack"
    default = "" 
}

variable "password" {
    description = "The password for the user"
    default = ""
}

variable "tenant_name" {
    description = "The name of the project (a.k.a. tenant) used"
    default = ""
}

variable "domain_name" {
    description = "The domain to be used"
    default = "Default"
}

variable "auth_url" {
    description = "The endpoint URL used to connect to OpenStack"
    default = ""
}

variable "insecure" {
  default = "true" # OS_INSECURE
}

################################################################
# Configure the Instance details
################################################################
variable "prefix" {
    description = "Prefix to use in reource names"
    default = ""
}

variable "image_name" {
    description = "The NAME of the image to be used for deploy operations"
    default = ""
}

variable "master" {
    type = "map"
    # only one node is supported
    default = {
        flavor_name = "" //Flavor name used to create master
        fixed_ip_v4 = ""
    }
}

variable "worker" {
    type = "map"
    default = {
        nodes  = "2"
        flavor_name = "" //Flavor name used to create workers
    }
}

variable "network_name" {
    description = "The name of the network to be used for deploy operations"
    default = ""
}

variable "rhel_username" {
    default = ""
}

variable "keypair_name" {
  # Set this variable to the name of an already generated
  # keypair to use it instead of creating a new one.
  default = ""
}

variable "public_key_file" {
    description = "Path to public key file"
    # if empty, will default to ${path.cwd}/id_rsa.pub
    default     = ""
}

variable "private_key_file" {
    description = "Path to private key file"
    # if empty, will default to ${path.cwd}/id_rsa
    default     = ""
}

variable "private_key" {
    description = "content of private ssh key"
    # if empty string will read contents of file at var.private_key_file
    default = ""
}

variable "public_key" {
    description = "Public key"
    # if empty string will read contents of file at var.public_key_file
    default     = ""
}

