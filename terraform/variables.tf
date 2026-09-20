variable "aws_region" {
  default = "eu-west-1"
  type    = string
}

variable "ami_id" {
  default = "ami-06468be052a4195a6"
  type    = string
}

variable "instance_type" {
  default = "t2.medium"
  type    = string
}

variable "key_name" {
  default = "gurleen-terraform-key"
  type    = string
}

variable "subnet1_cidr" {
  default = "10.0.1.0/24"
  type    = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the EKS subnets"
  type        = list(string)

  default = [
    "eu-west-1a",
    "eu-west-1b"
  ]
}