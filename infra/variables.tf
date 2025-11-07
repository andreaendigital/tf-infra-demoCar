# S3 Remote State

variable "bucket_name" {
  type        = string
  description = "Remote state bucket name"
}

variable "name" {
  type        = string
  description = "Tag name for the S3 bucket"
}


# Networking

variable "vpc_cidr" {
  type        = string
  description = "Public Subnet CIDR values"
}

variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
}

variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "eu_availability_zone" {
  type        = list(string)
  description = "Availability Zones"
}


# EC2 Instance


variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
}

variable "sg_enable_ssh_https" {
  description = "Security Group ID that allows SSH and HTTP access"
}




# Load Balancer
variable "lb_name" {
  description = "Name of the Load Balancer"
}

variable "lb_type" {
  description = "Type of Load Balancer (application or network)"
}


variable "subnet_ids" {
  description = "List of subnet IDs for the Load Balancer"
  type        = list(string)
}
