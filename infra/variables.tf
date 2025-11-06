# S3 Remote State

variable "bucket_name" {
  type        = string
  description = "Remote state bucket name"
}

variable "name" {
  type        = string
  description = "Tag name for the S3 bucket"
}

variable "environment" {
  type        = string
  description = "Environment name"
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

variable "public_key" {
  type        = string
  description = "Public SSH key to associate with the EC2 instance"
}

variable "ec2_ami_id" {
  type        = string
  description = "AMI ID to use for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "tag_name" {
  type        = string
  description = "Tag name for the EC2 instance"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
}

variable "sg_enable_ssh_https" {
  description = "Security Group ID that allows SSH and HTTP access"
}

variable "enable_public_ip_address" {
  description = "Whether to associate a public IP address with the EC2 instance"
  type        = bool
}
variable "ec2_sg_name_for_python_api" {
  description = "Security Group ID for Python API access"
}

# Load Balancer
variable "lb_name" {
  description = "Name of the Load Balancer"
}

variable "lb_type" {
  description = "Type of Load Balancer (application or network)"
}

variable "is_external" {
  description = "Whether the Load Balancer is public-facing"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Load Balancer"
  type        = list(string)
}

variable "lb_target_group_arn" {
  description = "ARN of the target group to attach EC2 instance"
}

variable "ec2_instance_id" {
  description = "ID of the EC2 instance to attach to the target group"
}

variable "lb_listner_port" {
  description = "Port for the Load Balancer listener (e.g., 80)"
}

variable "lb_listner_protocol" {
  description = "Protocol for the Load Balancer listener (e.g., HTTP)"
}

variable "lb_listner_default_action" {
  description = "Default action type for the listener (e.g., forward)"
}

variable "lb_target_group_attachment_port" {
  description = "Port used to attach EC2 instance to the target group"
}


# Load Balancer Target Group

variable "lb_target_group_name" {
  description = "Name of the Load Balancer target group"
}

variable "lb_target_group_port" {
  description = "Port used by the target group (e.g., 5000 for Flask API)"
}

variable "lb_target_group_protocol" {
  description = "Protocol used by the target group (e.g., HTTP)"
  
}