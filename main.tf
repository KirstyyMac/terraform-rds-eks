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

resource "aws_db_instance" "eks_rds" {
  allocated_storage = 100
  backup_retention_period = 30
  db_name = "eks-app-db"
  engine = "aurora-postgresql"
  engine_version = "16.1"
  ## Would obviously need to review instance class based on app usage patterns 
  instance_class = "db.t4g.large"
  manage_master_user_password = true
  username = "application"
  parameter_group_name = "rds-eks-pg"
  deletion_protection = true
  iops =  13000
  storage_type = "io1"
  iam_database_authentication_enabled = true
}

## subnet group - ideally would reference subnet ids directly from VPC terraform stack instead of from vars
resource "aws_db_subnet_group" "eks_rds_subnet_group" {
  name  = "eks-db-subnet-group"
  subnet_ids = var.rds_vpc_subnets
}

resource "aws_security_group" "eks_rds_sg" {
  name_prefix = "eks-rds-sg-${var.environment}"
  description = "Default security group for EKS PostgreSQL database instance allowing access from private network."
  vpc_id      = var.rds_vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "eks_rds_ingress_application" {
  security_group_id = aws_security_group.eks_rds_sg.id
  cidr_ipv4         = var.eks_cidr
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "rds_eks_egress" {
  security_group_id = aws_security_group.eks_rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_db_parameter_group" "eks_rds_pg" {
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
        Resource = aws_db_instance.eks_rds.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_rds_policy_app_role" {
  role       = var.eks_apps_role_arn
  policy_arn = aws_iam_policy.eks_apps_rds_policy.arn
}