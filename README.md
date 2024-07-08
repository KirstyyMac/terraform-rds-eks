### Terraform RDS
This repository will create an RDS that's is ot be used by apps in an EKS cluster on AWS using terraform. 

Run `terraform plan --var-file ./vars/prod.tfvars` to see planned stack

## Assumptions
VPCs (same network)
- EKS cluster VPC: (k8s - 10.2.0.0/16)
- RDS cluster VPC: (data - 10.5.0.0/16)

Application assumes the following IAM role: arn:aws:iam::123456789101:role/application/example-app.

## Considerations
- Would usually go with using a module for something like this in a larger org where things are likely to be redeployed (whether this is one we maintain internally, or an OS one like https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest). It's been a while since working with RDS for me though so wanted to be explicit
- Also if this were real, would likely think more about the resource breakdown across files/modules
- Didn't test deploying this just because of assumed VPC's etc, but obviously would do this to figure out the network/IAM/param niggles
- Would setup some reusable scripts using docker, probably based on three musketeers plan or similar, to standardise deployment across teams and pipelines
- Would setup to store state in an S3 bucket with deletion protection