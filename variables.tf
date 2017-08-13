variable "access_key" {}
variable "secret_key" {}
variable "region" {
 	default = "eu-west-1"
}
variable "public_key_path" {
  description = "Path to the SSH public key to be used for authentication."
	default = "~/.ssh/id_rsa.pub"
}
variable "private_key_path" {
  description = "Path to the SSH private key to be used for provisioning."
  default = "~/.ssh/id_rsa"
}
variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "demo_key"
}
variable "elastic_ip_id" {
  description = "The Allocation ID of the Elastic IP you want to associate with the demo instance"
  default = "<EIP ID>"
}
variable "domain" {
  description = "The domain to which ChargeGrid will be deployed"
  default = "chargegrid.io"
}