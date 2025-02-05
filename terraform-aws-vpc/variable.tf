##  define a list of strings that essentially hold the CIDR ranges for each subnet

variable "public_subnets_cidr_value" {
  type = list(string)
  description = "Public Subnet CIDR Value"
  default = [ "192.168.1.0/24", "192.168.2.0/24" ]
}

variable "private_subnet_cidr_value" {
  type = list(string)
  description = "Private Subnet CIDR Value"
  default = [ "192.168.10.0/24", "192.168.20.0/24" ]
}

## variable to store the list of availability zones

variable "azs" {
  type = list(string)
  description = "Availability Zones"
  default = [ "us-east-2a", "us-east-2b" ]
}