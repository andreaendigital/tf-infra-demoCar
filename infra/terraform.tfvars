# S3 bucket for remote state, created manually
bucket_name = "infraCar-remote-state-bucket"
name        = "infraCar"

# VPC configuration (Free Tier compatible CIDR blocks)
vpc_cidr = "10.0.0.0/16"
vpc_name = "infraCar-eu-central-vpc"

# Public subnets (for ALB and Jenkins EC2)
cidr_public_subnet = ["10.0.1.0/24", "10.0.2.0/24"]

# Private subnets (for RDS or backend services)
cidr_private_subnet = ["10.0.3.0/24", "10.0.4.0/24"]

# Availability Zones in us-east-1 (Free Tier region)
eu_availability_zone = ["us-east-1a", "us-east-1b"]

# EC2 configuration
public_key = "-"
ec2_ami_id = "ami-0157af9aea2eef346" # Amazon Linux 2023 AMI (Free Tier eligible)

