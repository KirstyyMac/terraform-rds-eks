variable "region" {
    type = string
    description = "AWS region for all resources"
    default = "ap-southeast-2"
}

variable "environment" {
    type = string
    description = "Environment to deploy stack into"
}

## Ideally would import these values from the Terraform VPC stack
variable "rds_vpc_subnets" {
    type = list(string)
    description = "Subnets to be used in the creation of the RDS subnet group"
}

variable "eks_cidr" {
    type = string
    description = "CIDR block for the EKS VPC network"
}

variable "rds_vpc_id" {
    type = string
    description = "VPC ID for the RDS VPC"
}

variable "eks_apps_role_arn" {
    type = string
    description = "Role ARN used by EKS applications to access RDS"
}