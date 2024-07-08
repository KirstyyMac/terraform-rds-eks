output "eks_rds_endpoint" {
    value = aws_db_instance.eks_db.endpoint
}

output "eks_rds_master_username" {
    value = aws_db_instance.eks_db.username
}

## Expect this to output the secret ARN for the database username
output "eks_rds_password_secret" {
    value = aws_db_instance.eks_db.master_user_secret
}