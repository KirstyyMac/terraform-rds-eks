## RDS instance
provider "aws" {
    region = var.region

    default_tags {
        tags = {
            Environment = var.environment
            Service = "eks-rds"
            Owner = "InfrastructureTeam"
        }
    }
}

resource "aws_db_instance" "eks_db" {
  allocated_storage = 20
  db_name = "eks-db"
  engine = "aurora-postgresql"
  engine_version = "16.1"
  instance_class = "db.t3.micro"
  manage_master_user_password = true
  username = "application"
  parameter_group_name = "rds-eks-pg"
  deletion_protection = true
  iops =  13000
  storage_type = "io1"
  iam_database_authentication_enabled = true
}

## subnet group - ideally would reference subnet ids directly from VPC terraform stack 
resource "aws_db_subnet_group" "eks_db_subnet_group" {
  name  = "eks-db-subnet-group"
  subnet_ids = var.rds_vpc_subnets
}

## security group
resource "aws_security_group" "eks_rds_sg" {
  name_prefix = "eks-rds-sg-${var.environment}"
  description = "Default security group for EKS PostgreSQL database instance allowing access from private network."
  vpc_id      = var.rds_vpc_id

  ingress {
    from_port = "5432"
    to_port   = "5432"
    protocol  = "tcp"
    cidr_blocks = [
      var.eks_cidr
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
## RDS custom paramter group
resource "aws_db_parameter_group" "rds_eks_pg" {
  name   = "eks-rds-pg"
  family = "aurora-postgresql16"

  parameter {
    name  = "statement_timeout"
    value = "3600000"
  }

  parameter {
    name  = "rds.log_retention_period"
    value = "1440"
  }
}

resource "aws_iam_policy" "eks_apps_rds_policy" {
  name        = "eks-apps-rds-policy"
  path        = "/"
  description = "Grants access to RDS for applications running in EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds-db:connect",
        ]
        Effect   = "Allow"
        Resource = aws_db_instance.eks_db.arn
      },
    ]
  })
}